//
//  EntryViewController.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit
import Firebase
import SDCAlertView
import AlamofireImage
import AnimatedGIFImageSerialization

protocol EntryDelegate {

  func updateEntry(entryTimestamp: String, entry: NSDictionary)

}

class EntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

  @IBOutlet var cameraImageView: UIImageView!
  @IBOutlet var imageButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var titleView: UITextView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var backButton: UIBarButtonItem!

  let imagePicker = UIImagePickerController()
  var timestamp: String!
  var collectTimestamp: String!
  var entry: NSMutableDictionary!
  var readonly: Bool!
  var ref: FIRDatabaseReference!
  var storageRef: FIRStorageReference!
  var delegate: EntryDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.

    imagePicker.delegate = self

    titleView.layer.borderColor = UIColor.gray.cgColor
    titleView.layer.borderWidth = 1.0
    titleView.layer.cornerRadius = 0
    titleView.text = entry.value(forKey: "title") as? String

    ref = FIRDatabase.database().reference()
    storageRef = FIRStorage.storage().reference()

    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tap)

    if readonly {
      titleView.isEditable = false
    }

    let swipeToCollect = UISwipeGestureRecognizer(target: self, action: #selector(backToCollect(_:)))
    swipeToCollect.direction = .right
    view.addGestureRecognizer(swipeToCollect)

    backButton.customView = CollectsButton(image: "back", target: self, action: #selector(backToCollect(_:)))

    imageView.layer.borderColor = UIColor.gray.cgColor
    imageView.layer.borderWidth = 1.0
    imageView.layer.cornerRadius = 0

    imageButton.contentHorizontalAlignment = .fill
    imageButton.contentVerticalAlignment = .fill
    if let imageURL = entry.object(forKey: "image") as? String, imageURL.characters.count > 0 {
      imageView.af_setImage(withURL: URL(string: imageURL)!)
      cameraImageView.isHidden = true
      activityIndicator.startAnimating()
    } else {
      cameraImageView.isHidden = false
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    saveEntry()

    super.viewWillDisappear(animated)
  }

  func saveEntry() {
    ref.child("collects/\(collectTimestamp!)/entries/\(timestamp!)/title").setValue(titleView.text!)
    entry.setValue(titleView.text!, forKey: "title")
    delegate.updateEntry(entryTimestamp: timestamp, entry: entry)
  }

  func dismissKeyboard() {
    view.endEditing(true)
  }

  // MARK: - UIImagePickerControllerDelegate Methods

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      let newImage = resizedImage(image)
      let (_, fileExt) = fileInfo(UIImagePNGRepresentation(newImage)!)
      var data: Data

      // try any upload as an animated gif first
      do {
        data = try AnimatedGIFImageSerialization.animatedGIFData(with: newImage)
      } catch {
        if fileExt == "jpg" {
          data = UIImageJPEGRepresentation(newImage, 1.0)!
        } else {
          data = UIImagePNGRepresentation(newImage)!
        }
      }
      uploadImage(data)
    }

    dismiss(animated: true, completion: nil)
  }

  func resizedImage(_ image: UIImage) -> UIImage {
    let oldWidth = image.size.width
    let oldHeight = image.size.height

    if oldWidth < 500 && oldHeight < 500 {
      return image
    }

    let scaleFactor = (oldWidth > oldHeight) ? 500 / oldWidth : 500 / oldHeight

    let newHeight = oldHeight * scaleFactor
    let newWidth = oldWidth * scaleFactor

    UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func backToCollect(_ sender: Any) {
    performSegue(withIdentifier: "unwindToCollect", sender: self)
  }

  @IBAction func addImage(_ button: UIButton) {
    if (readonly) {
      return
    }
    let alert = AlertController(title: "", message: "", preferredStyle: .actionSheet)
    alert.add(AlertAction(title: "Cancel", style: .preferred))
    if entry.value(forKey: "image") != nil {
      alert.add(AlertAction(title: "Clear image", style: .normal, handler: { (action) -> Void in
        self.clearImage()
      }))
    }
    if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
      alert.add(AlertAction(title: "Take photo", style: .normal, handler: { (action) -> Void in
        self.imagePicker.sourceType = .camera
        self.present(self.imagePicker, animated: false, completion: nil)
      }))
    }
    alert.add(AlertAction(title: "Photo library", style: .normal, handler: { (action) -> Void in
      self.imagePicker.sourceType = .photoLibrary
      self.present(self.imagePicker, animated: false, completion: nil)
    }))
    alert.add(AlertAction(title: "Upload from url", style: .normal, handler: { (action) -> Void in
      self.promptUrl()
    }))
    alert.visualStyle = CollectsAlertVisualStyle(alertStyle: .actionSheet)
    alert.present()
  }

  func clearImage() {
    if let imageURL = entry.value(forKey: "image") as? String {
      ref.child("collects/\(self.collectTimestamp!)/entries/\(self.timestamp!)/image").removeValue()
      if let filename = entry.value(forKey: "filename") as? String {
        ref.child("collects/\(self.collectTimestamp!)/entries/\(self.timestamp!)/filename").removeValue()
        let task = storageRef.child("images/\(filename)")
        task.delete(completion: { error in
          if let error = error {
            print(error.localizedDescription)
          }
        })
        entry.removeObject(forKey: "filename")
      }
      entry.removeObject(forKey: "image")
      cameraImageView.isHidden = false

      imageView.af_cancelImageRequest()
      imageView.image = nil

      if imageURL.characters.count > 0 {
        let request = URLRequest(url: URL(string: imageURL)!)
        let imageDownloader = UIImageView.af_sharedImageDownloader
        // Clear the URLRequest from the in-memory cache
        let _ = imageDownloader.imageCache?.removeImage(for: request, withIdentifier: nil)
        // Clear the URLRequest from the on-disk cache
        imageDownloader.sessionManager.session.configuration.urlCache?.removeCachedResponse(for: request)
      }
    }
  }

  func promptUrl() {
    let alert = AlertController(title: "", message: "", preferredStyle: .alert)
    alert.addTextField(withHandler: { (textField) -> Void in
      textField.autocapitalizationType = UITextAutocapitalizationType.none
    })
    alert.add(AlertAction(title: "Cancel", style: .normal))
    alert.add(AlertAction(title: "Upload url", style: .normal, handler: { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      if URL(string: textField.text!) != nil {
        self.clearImage()
        self.uploadUrl(textField.text!)
      } else {
        self.imageFailure()
      }
    }))
    alert.visualStyle = CollectsAlertVisualStyle(alertStyle: .alert)
    alert.present()
  }

  func fileInfo(_ data: Data) -> (String, String) {
    var values = [UInt8](repeating:0, count:1)
    data.copyBytes(to: &values, count: 1)

    switch (values[0]) {
    case 0xFF:
      return ("image/jpeg", "jpg")
    case 0x89:
      return ("image/png", "png")
    case 0x47:
      return ("image/gif", "gif")
    case 0x49, 0x4D:
      return ("image/tiff", "tiff")
    default:
      return ("", "")
    }
  }

  func imageFailure() {
    let alert = AlertController(title: "", message: "", preferredStyle: .alert)
    alert.add(AlertAction(title: "That didn't work", style: .normal))
    alert.visualStyle = CollectsAlertVisualStyle(alertStyle: .alert)
    alert.present()
  }

  func uploadUrl(_ url: String) {
    entry.setObject(url, forKey: "image" as NSCopying)
    saveEntry()
    ref.child("collects/\(collectTimestamp!)/entries/\(timestamp!)/image").setValue(url)
    cameraImageView.isHidden = true
    imageView.isHidden = false
    imageView.af_setImage(withURL: URL(string: url)!)
  }

  func uploadImage(_ data: Data) {
    let (contentType, fileExt) = fileInfo(data)
    if fileExt != "" {
      clearImage()
      imageView.isHidden = true
      cameraImageView.isHidden = true
      activityIndicator.startAnimating()

      let imageMetadata = FIRStorageMetadata()
      imageMetadata.contentType = contentType
      let filename = "\(timestamp!).\(fileExt)"
      let task = storageRef.child("images/\(filename)")
      task.put(data, metadata: imageMetadata, completion: { (_ metadata: FIRStorageMetadata?, _ error: Error?) in
        self.activityIndicator.stopAnimating()
        if error != nil {
          self.imageView.isHidden = false
          if self.imageView.image == nil {
            self.cameraImageView.isHidden = false
          }
        } else {
          self.entry.setObject(filename, forKey: "filename" as NSCopying)
          self.ref.child("collects/\(self.collectTimestamp!)/entries/\(self.timestamp!)/filename").setValue(filename)
          let downloadURL = metadata?.downloadURL()!.absoluteString
          self.uploadUrl(downloadURL!)
        }
      })
    } else {
      imageFailure()
    }
  }
  
}
