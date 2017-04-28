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

    titleView.layer.borderColor = UIColor(colorLiteralRed: 200/256, green: 200/256, blue: 204/256, alpha: 1.0).cgColor
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

    let back = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    back.setImage(UIImage.init(named: "back"), for: UIControlState.normal)
    back.imageView?.contentMode = .scaleAspectFit
    back.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    back.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    back.addTarget(self, action: #selector(backToCollect(_:)), for:UIControlEvents.touchUpInside)
    backButton.customView = back

    imageButton.layer.borderColor = UIColor(colorLiteralRed: 200/256, green: 200/256, blue: 204/256, alpha: 1.0).cgColor
    imageButton.layer.borderWidth = 1.0
    imageButton.layer.cornerRadius = 0
    imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    imageButton.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
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
    ref.child("collects/\(collectTimestamp!)/entries/\(timestamp!)/title").setValue(titleView.text!)

    entry.setValue(titleView.text!, forKey: "title")
    delegate.updateEntry(entryTimestamp: timestamp, entry: entry)

    super.viewWillDisappear(animated)
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
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.present(self.imagePicker, animated: false, completion: nil)
      }))
    }
    alert.add(AlertAction(title: "Photo library", style: .normal, handler: { (action) -> Void in
      self.imagePicker.delegate = self
      self.imagePicker.sourceType = .photoLibrary
      self.present(self.imagePicker, animated: false, completion: nil)
    }))
    alert.add(AlertAction(title: "Upload from url", style: .normal, handler: { (action) -> Void in
      self.promptUrl()
    }))

    alert.visualStyle.actionSheetPreferredFont = UIFont(name: "Times New Roman", size: 18)!
    alert.visualStyle.actionSheetNormalFont = UIFont(name: "Times New Roman", size: 18)!
    alert.visualStyle.normalTextColor = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
    alert.visualStyle.backgroundColor = UIColor.white
    alert.visualStyle.cornerRadius = 0

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
        let request = URLRequest.init(url: URL.init(string: imageURL)!)
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
      if URL.init(string: textField.text!) != nil {
        self.clearImage()
        self.uploadUrl(textField.text!)
      } else {
        self.imageFailure()
      }
    }))
    alert.visualStyle.textFieldFont = UIFont(name: "Times New Roman", size: 18)!
    alert.visualStyle.textFieldHeight = 30
    alert.visualStyle.alertNormalFont = UIFont(name: "Times New Roman", size: 18)!
    alert.visualStyle.normalTextColor = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
    alert.visualStyle.backgroundColor = UIColor.white
    alert.visualStyle.cornerRadius = 0

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
    let fail = AlertController(title: "", message: "", preferredStyle: .alert)
    fail.add(AlertAction(title: "That didn't work", style: .normal))
    fail.visualStyle.alertNormalFont = UIFont(name: "Times New Roman", size: 18)!
    fail.visualStyle.normalTextColor = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
    fail.present()
  }

  func uploadUrl(_ url: String) {
    entry.setObject(url, forKey: "image" as NSCopying)
    delegate.updateEntry(entryTimestamp: timestamp, entry: entry)
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
