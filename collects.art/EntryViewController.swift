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

  let imagePicker = UIImagePickerController()
  var timestamp: NSString!
  var entry: NSDictionary!
  var ref: FIRDatabaseReference!
  var storageRef: FIRStorageReference!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tap)

    // Do any additional setup after loading the view.
    imagePicker.delegate = self
    imagePicker.allowsEditing = false

    titleView.layer.borderColor = UIColor.black.cgColor
    titleView.layer.borderWidth = 1.0
    titleView.layer.cornerRadius = 0

    descView.layer.borderColor = UIColor.black.cgColor
    descView.layer.borderWidth = 1.0
    descView.layer.cornerRadius = 0
    
    ref = FIRDatabase.database().reference()
    storageRef = FIRStorage.storage().reference()
    
    getEntry()
  }
  
  func getEntry() {
    activityIndicator.startAnimating()
    ref.child("entries/\(timestamp!)").observeSingleEvent(of: .value, with: { (snapshot) in
      if snapshot.exists() {
        if let value = snapshot.value as? NSDictionary {
          self.entry = value
        }
      }
      if let imageURL = self.entry.value(forKey: "image") as? String {
        self.imageView.af_setImage(withURL: URL(string: imageURL)!)
      }
      self.activityIndicator.stopAnimating()
    })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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

  @IBAction func postEntry() {
    self.navigationItem.rightBarButtonItem?.title = "Posting..."
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    publishEntry(self.titleView.text!, description: self.descView.text)
  }

  @IBAction func returnToCamera() {
    self.present(self.imagePicker, animated: false, completion: nil)
  }

  @IBAction func backToCollect(_ sender: Any) {
    performSegue(withIdentifier: "unwindToCollect", sender: self)
  }
  
  @IBAction func addImage(_ button: UIButton) {
    let alert = AlertController(title: "", message: "", preferredStyle: .actionSheet)
    alert.add(AlertAction(title: "Cancel", style: .preferred))
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
    

//    let headers = [
//      "Authorization": "foo",
//      "Accept": "application/json"
//    ]
//    let parameters = [
//      "title": title
//    ]
//    let url = "http://google.com"
//    Alamofire.upload(.POST, url,
//      headers: headers,
//      multipartFormData: { formData in
//        formData.appendBodyPart(data: "ImageShot".dataUsingEncoding(NSUTF8StringEncoding)!, name: "entry_type")
//        formData.appendBodyPart(data: UIImageJPEGRepresentation(image, 0.9)!, name: "image_data", fileName: "upload.jpg", mimeType: "image/jpeg")
//      },
//      encodingCompletion: { encodingResult in
//        switch encodingResult {
//        case .Success(let upload, _, _):
//          upload.validate().responseJSON { response in
//            if (response.result.isSuccess) {
//              let dict = response.result.value as! NSDictionary
//              self.entryId = (dict["id"] as! Int)
//              self.navigationItem.rightBarButtonItem?.enabled = true
//            } else {
//              debugPrint(response)
//            }
//          }
//        case .Failure(let encodingError):
//          debugPrint(encodingError)
//        }
//      })
    //self.navigationItem.rightBarButtonItem?.isEnabled = false
  }

  func publishEntry(_ title: String, description: String) {
//    let headers = [
//      "Authorization": "foo",
//      "Accept": "application/json"
//    ]
//    let parameters = [
//      "title": title
//    ]
//    let url = "http://google.com"
//    Alamofire.request(.PUT, url, headers: headers, parameters: parameters)
//      .validate()
//      .responseJSON { response in
//        if (response.result.isSuccess) {
//          self.navigationController?.popViewControllerAnimated(true);
//        }
//      }
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0{
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y != 0{
        self.view.frame.origin.y += keyboardSize.height
      }
    }
  }

}
