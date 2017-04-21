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

class EntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

  @IBOutlet var cameraImageView: UIImageView!
  @IBOutlet var imageButton: UIButton!
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
    imageButton.imageView!.contentMode = .scaleAspectFit
    imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    imageButton.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    if let image = entry.object(forKey: "image") as? UIImage {
      imageButton.setImage(image, for: UIControlState.normal)
      cameraImageView.isHidden = true
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

    let defaults = UserDefaults.standard
    if let entriesData = defaults.data(forKey: "entries") {
      let entries = (NSKeyedUnarchiver.unarchiveObject(with: entriesData) as! NSDictionary).mutableCopy() as! NSMutableDictionary
      entry.setValue(titleView.text!, forKey: "title")
      entries.setValue(entry, forKey: timestamp)
      let encodedEntries = NSKeyedArchiver.archivedData(withRootObject: entries)
      defaults.set(encodedEntries, forKey: "entries")
    }

    super.viewWillDisappear(animated)
  }

  func dismissKeyboard() {
    view.endEditing(true)
  }

  // MARK: - UIImagePickerControllerDelegate Methods

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      let (_, fileExt) = fileInfo(UIImagePNGRepresentation(image)!)
      var data: Data
      if fileExt == "gif" {
        data = try! AnimatedGIFImageSerialization.animatedGIFData(with: image)
      } else if fileExt == "jpg" {
        data = UIImageJPEGRepresentation(image, 1.0)!
      } else {
        data = UIImagePNGRepresentation(image)!
      }
      uploadImage(data)
    }

    dismiss(animated: true, completion: nil)
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
        self.ref.child("collects/\(self.collectTimestamp!)/entries/\(self.timestamp!)/image").removeValue()
        self.entry.removeObject(forKey: "image")
        self.imageButton.setImage(nil, for: UIControlState.normal)
        self.cameraImageView.isHidden = false
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

  func promptUrl() {
    let alert = AlertController(title: "", message: "", preferredStyle: .alert)
    alert.addTextField(withHandler: { (textField) -> Void in
      textField.autocapitalizationType = UITextAutocapitalizationType.none;
    });
    alert.add(AlertAction(title: "Cancel", style: .normal))
    alert.add(AlertAction(title: "Upload url", style: .normal, handler: { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      if let url = URL.init(string: textField.text!) {
        do {
          let data = try Data(contentsOf: url)
          self.uploadImage(data)
        } catch {
          self.imageFailure()
        }
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

  func uploadImage(_ data: Data) {
    let (contentType, fileExt) = fileInfo(data)
    if fileExt != "" {
      imageButton.imageView?.isHidden = true
      cameraImageView.isHidden = true
      backButton.isEnabled = false
      activityIndicator.startAnimating()

      let imageMetadata = FIRStorageMetadata()
      imageMetadata.contentType = contentType
      let task = storageRef.child("images/\(timestamp!).\(fileExt)")
      task.put(data, metadata: imageMetadata, completion: { (_ metadata: FIRStorageMetadata?, _ error: Error?) in
        self.activityIndicator.stopAnimating()
        self.backButton.isEnabled = true
        if error != nil {
          self.imageButton.imageView?.isHidden = false
          if self.imageButton.imageView?.image == nil {
            self.cameraImageView.isHidden = false
          }
        } else {
          let downloadURL = metadata?.downloadURL()!.absoluteString
          self.ref.child("collects/\(self.collectTimestamp!)/entries/\(self.timestamp!)/image").setValue(downloadURL!)
          let data = try! Data(contentsOf: URL(string: downloadURL!)!)
          let image = UIImage(data: data)
          image?.af_inflate()
          self.entry.setObject(image!, forKey: "image" as NSCopying)
          self.imageButton.setImage(image, for: UIControlState.normal)
        }
      })
    } else {
      imageFailure()
    }
  }
  
}
