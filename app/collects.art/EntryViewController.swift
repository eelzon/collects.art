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

  @IBOutlet var imageView: UIImageView!
  @IBOutlet var titleView: UITextView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var cameraButton: UIBarButtonItem!

  let imagePicker = UIImagePickerController()
  var timestamp: String!
  var collectTimestamp: String!
  var entry: NSDictionary!
  var readonly: Bool!
  var ref: FIRDatabaseReference!
  var storageRef: FIRStorageReference!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    titleView.layer.borderColor = UIColor.black.cgColor
    titleView.layer.borderWidth = 1.0
    titleView.layer.cornerRadius = 0
    titleView.text = entry.value(forKey: "title") as? String
    
    ref = FIRDatabase.database().reference()
    storageRef = FIRStorage.storage().reference()
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tap)
    
    if readonly {
      cameraButton.isEnabled = false
      titleView.isEditable = false
    }
    
    if let imageURL = entry.value(forKey: "image") as? String {
      imageView.af_setImage(withURL: URL(string: imageURL)!)
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
    self.ref.child("collects/\(collectTimestamp!)/entries/\(timestamp!)/title").setValue(titleView.text!)
    super.viewWillDisappear(animated)
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
  */
  
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
    let alert = AlertController(title: "", message: "", preferredStyle: .actionSheet)
    alert.add(AlertAction(title: "Cancel", style: .preferred))
    if (entry.value(forKey: "image") as? String) != nil {
      alert.add(AlertAction(title: "Clear image", style: .normal, handler: { (action) -> Void in
        self.ref.child("collects/\(self.collectTimestamp!)/entries/\(self.timestamp!)/image").setValue(false)
        self.imageView.image = nil
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
    
    alert.visualStyle.actionSheetPreferredFont = UIFont(name: "Times New Roman", size: 16)!
    alert.visualStyle.actionSheetNormalFont = UIFont(name: "Times New Roman", size: 16)!
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
        let data = try! Data(contentsOf: url)
        self.uploadImage(data)
      }
    }))
    alert.visualStyle.textFieldFont = UIFont(name: "Times New Roman", size: 16)!
    alert.visualStyle.textFieldHeight = 30
    alert.visualStyle.alertNormalFont = UIFont(name: "Times New Roman", size: 16)!
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
      return ("image/jpeg", "jpg")
    }
  }

  func uploadImage(_ data: Data) {
    activityIndicator.startAnimating()
    let (contentType, fileExt) = fileInfo(data)
    let metadata = FIRStorageMetadata()
    metadata.contentType = contentType
    print(metadata)
    storageRef.child("images/\(timestamp!).\(fileExt)").put(data, metadata: metadata).observe(.success) { (snapshot) in
      let downloadURL = snapshot.metadata?.downloadURL()!.absoluteString
      self.ref.child("collects/\(self.collectTimestamp!)/entries/\(self.timestamp!)/image").setValue(downloadURL!)
      self.entry.setValue(downloadURL, forKey: "image")
      self.imageView?.af_setImage(withURL: URL(string: downloadURL!)!)
      self.activityIndicator.stopAnimating()
    }
  }
  
}
