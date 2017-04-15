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

class EntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

  @IBOutlet var imageView: UIImageView!
  @IBOutlet var titleView: UITextField!
  @IBOutlet var descView: UITextView!
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

    descView.layer.borderColor = UIColor.black.cgColor
    descView.layer.borderWidth = 1.0
    descView.layer.cornerRadius = 0
    
    ref = FIRDatabase.database().reference()
    storageRef = FIRStorage.storage().reference()
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tap)
    
    if readonly {
      cameraButton.isEnabled = false
      titleView.isEnabled = false
      descView.isEditable = false
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
    let updatedEntry: [String: Any] = ["title": titleView.text!, "image": entry.value(forKey: "image")!, "description": descView.text];

    self.ref.child("collects/\(collectTimestamp)/entries/\(timestamp)").setValue(updatedEntry)
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
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      uploadImage(pickedImage)
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func returnToCamera() {
    imagePicker.delegate = self
    imagePicker.allowsEditing = false
    self.present(self.imagePicker, animated: false, completion: nil)
  }

  @IBAction func backToCollect(_ sender: Any) {
    performSegue(withIdentifier: "unwindToCollect", sender: self)
  }
  
  @IBAction func addImage(_ button: UIButton) {
    let alert = AlertController(title: "", message: "", preferredStyle: .actionSheet)
    alert.add(AlertAction(title: "Cancel", style: .preferred))
    if (entry.value(forKey: "image") as? String) != nil {
      alert.add(AlertAction(title: "Clear image", style: .normal, handler: { (action) -> Void in
        self.ref.child("collects/\(self.collectTimestamp)/entries/\(self.timestamp)/image").setValue(false)
        self.imageView.image = nil
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
    
    alert.visualStyle.actionSheetPreferredFont = UIFont(name: "Times New Roman", size: 16)!
    alert.visualStyle.alertNormalFont = UIFont(name: "Times New Roman", size: 16)!
    alert.visualStyle.normalTextColor = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
    alert.visualStyle.backgroundColor = UIColor.white
    alert.visualStyle.cornerRadius = 0
    
    alert.present()
  }

  func uploadImage(_ image: UIImage) {
    activityIndicator.startAnimating()
    let data: Data = UIImagePNGRepresentation(image)!
    storageRef.child("images/\(timestamp).jpg").put(data, metadata: nil) { (metadata, error) in
      guard let metadata = metadata else {
        // TODO offline / etc Uh-oh, an error occurred!
        return
      }
      // Metadata contains file metadata such as size, content-type, and download URL.
      let downloadURL = metadata.downloadURL()!.absoluteString
      self.ref.child("entries/\(self.timestamp)/image").setValue(downloadURL)
      self.imageView?.af_setImage(withURL: URL(string: downloadURL)!)
      self.activityIndicator.stopAnimating()
    }
  }
  
}
