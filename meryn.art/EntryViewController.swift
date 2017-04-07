//
//  EntryViewController.swift
//  meryn.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit
import Alamofire

class EntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

  @IBOutlet var imageView: UIImageView!
  @IBOutlet var titleView: UITextField!
  @IBOutlet var descView: UITextView!
  @IBOutlet var retakeButton: UIButton!

  let imagePicker = UIImagePickerController()
  var entryId: Int? = nil
    
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    imagePicker.delegate = self
    imagePicker.allowsEditing = false
    if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
      imagePicker.sourceType = .Camera
    } else {
      imagePicker.sourceType = .PhotoLibrary
    }
    
    self.presentViewController(self.imagePicker, animated: false, completion: nil)
    self.descView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
    self.descView.layer.borderWidth = 1.0
    self.descView.layer.cornerRadius = 5
    
    retakeButton.layer.cornerRadius = 5
    retakeButton.layer.borderWidth = 1
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    self.title = "";
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
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.image = pickedImage
      uploadImage(pickedImage)
    }
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func postEntry() {
    self.navigationItem.rightBarButtonItem?.title = "Posting..."
    self.navigationItem.rightBarButtonItem?.enabled = false
    publishEntry(self.titleView.text!, description: self.descView.text)
  }
  
  @IBAction func returnToCamera() {
    self.presentViewController(self.imagePicker, animated: false, completion: nil)
  }

  func uploadImage(image: UIImage) {
    let headers = [
      "Authorization": "foo",
      "Accept": "application/json"
    ]
    let parameters = [
      "title": title
    ]
    let url = "http://google.com"
    Alamofire.upload(.POST, url,
      headers: headers,
      multipartFormData: { formData in
        formData.appendBodyPart(data: "ImageShot".dataUsingEncoding(NSUTF8StringEncoding)!, name: "entry_type")
        formData.appendBodyPart(data: UIImageJPEGRepresentation(image, 0.9)!, name: "image_data", fileName: "upload.jpg", mimeType: "image/jpeg")
      },
      encodingCompletion: { encodingResult in
        switch encodingResult {
        case .Success(let upload, _, _):
          upload.validate().responseJSON { response in
            if (response.result.isSuccess) {
              let dict = response.result.value as! NSDictionary
              self.entryId = (dict["id"] as! Int)
              self.navigationItem.rightBarButtonItem?.enabled = true
            } else {
              debugPrint(response)
            }
          }
        case .Failure(let encodingError):
          debugPrint(encodingError)
        }
      })
    self.navigationItem.rightBarButtonItem?.enabled = false
  }

  func publishEntry(title: String, description: String) {
    let headers = [
      "Authorization": "foo",
      "Accept": "application/json"
    ]
    let parameters = [
      "title": title
    ]
    let url = "http://google.com"
    Alamofire.request(.PUT, url, headers: headers, parameters: parameters)
      .validate()
      .responseJSON { response in
        if (response.result.isSuccess) {
          self.navigationController?.popViewControllerAnimated(true);
        }
      }
  }

}
