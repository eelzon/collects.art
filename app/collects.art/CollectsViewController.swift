//
//  CollectsViewController.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit
import Firebase
import SDCAlertView
import Alamofire
import AlamofireImage
import SESlideTableViewCell

class CollectsTableViewCell: SESlideTableViewCell {

  @IBOutlet var titleLabel: UILabel!

}

class CollectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, SESlideTableViewCellDelegate, CollectDelegate, RibbonDelegate {

  @IBOutlet weak var addButton: UIBarButtonItem!
  @IBOutlet weak var userButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var offlineView: UIWebView!

  let blue = UIColor(colorLiteralRed: 0, green: 0, blue: 238/256, alpha: 1.0)
  let purple = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
  let font = UIFont(name: "Times New Roman", size: 18)!
  var collects: NSMutableDictionary! = NSMutableDictionary()
  var timestamps: NSMutableArray! = NSMutableArray()
  let manager = NetworkReachabilityManager()
  var ref: FIRDatabaseReference!
  var storageRef: FIRStorageReference!
  var uid: String!
  var ribbon: String!
  var slidOpenIndexPath: IndexPath!

  override func viewDidLoad() {
    super.viewDidLoad()

    setReachability()

    if !manager!.isReachable {
      self.lockDown()
    } else {
      self.setAuth()
    }

    let add = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    add.setImage(UIImage.init(named: "add"), for: .normal)
    add.imageView?.contentMode = .scaleAspectFit
    add.contentHorizontalAlignment = .fill
    add.contentVerticalAlignment = .fill
    add.addTarget(self, action: #selector(createCollect(_:)), for: .touchUpInside)
    addButton.customView = add

    let attributes = [NSFontAttributeName: UIFont(name: "Times New Roman", size:18)!, NSForegroundColorAttributeName: purple]
    navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
    navigationItem.rightBarButtonItem?.tintColor = purple
    navigationItem.leftBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
    navigationItem.leftBarButtonItem?.tintColor = purple

    tableView.scrollsToTop = true
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  func setAuth() {
    offlineView.isHidden = false
    activityIndicator.startAnimating()
    tableView.isHidden = true

    ref = FIRDatabase.database().reference()
    storageRef = FIRStorage.storage().reference()

    tableView.scrollsToTop = true

    // Using Cloud Storage for Firebase requires the user be authenticated. Here we are using
    // anonymous authentication.
    if FIRAuth.auth()?.currentUser == nil {
      FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
        if error != nil {
          self.lockDown()
        } else {
          self.uid = user!.uid
          self.getCollects()
          self.getRibbons()
          self.getTemplates()
        }
      })
    } else {
      uid = FIRAuth.auth()!.currentUser!.uid
      //uploadRibbons()
      getCollects()
      getRibbons()
      getTemplates()
    }
  }

  func getCollects() {
    tableView.isHidden = false
    addButton.isEnabled = true
    userButton.isEnabled = true
    ref.child("users/\(uid!)/collects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
      if snapshot.exists(), let value = snapshot.value as? NSDictionary {
        UserDefaults.standard.set(value, forKey: "collects")
        self.setCollects(dict: value)
      } else {
        self.setCollects(dict: UserDefaults.standard.object(forKey: "collects") as! NSDictionary)
      }
    }) { (error) in
      print(error.localizedDescription)
      self.setCollects(dict: UserDefaults.standard.object(forKey: "collects") as! NSDictionary)
    }
  }

  func setCollects(dict: NSDictionary) {
    activityIndicator.stopAnimating()
    collects = dict.mutableCopy() as! NSMutableDictionary
    let array = (self.collects.allKeys as NSArray).reverseObjectEnumerator().allObjects
    timestamps = NSMutableArray.init(array: array)
    tableView.reloadData()
  }

  func setUserRibbon() {
    // close ribbon popover if open
    dismiss(animated: true, completion: {})

    ribbon = UserDefaults.standard.object(forKey: "ribbon") as? String
    if ribbon == nil {
      let ribbons = UserDefaults.standard.object(forKey: "ribbons") as! NSArray
      let index = Int(arc4random_uniform(UInt32(ribbons.count)))
      ribbon = ribbons.object(at: index) as? String
      UserDefaults.standard.set(ribbon, forKey: "ribbon")
    }

    self.ref.child("users/\(self.uid!)/ribbon").setValue(ribbon!)

    do {
      let data = try Data(contentsOf: URL(string: ribbon!)!)
      let image = UIImage(data: data)
      image?.af_inflate()

      let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
      button.setImage(image, for: .normal)
      button.imageView?.contentMode = .scaleAspectFit
      button.addTarget(self, action: #selector(openRibbons(_:)), for: .touchUpInside)
      userButton.customView = button
    } catch {
      print(error.localizedDescription)
    }
  }

  func getRibbons() {
    if UserDefaults.standard.object(forKey: "ribbons") == nil {
      ref.child("ribbons").observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists(), let value = snapshot.value as? NSDictionary {
          let ribbons = NSMutableArray()
          for ribbon in value {
            ribbons.add((ribbon.value as! NSDictionary).value(forKey: "url")!)
          }
          UserDefaults.standard.set(ribbons, forKey: "ribbons")
          self.setUserRibbon()
        }
      })
    } else {
      setUserRibbon()
    }
  }

  func getTemplates() {
    if UserDefaults.standard.object(forKey: "templates") == nil {
      ref.child("templates").observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists(), let value = snapshot.value as? NSDictionary {
          let templates = NSMutableArray()
          for template in value {
            templates.add(template.value as! NSDictionary)
          }
          UserDefaults.standard.set(templates, forKey: "templates")
        }
      })
    }
  }

  func openRibbons(_ sender:Any) {
    performSegue(withIdentifier: "segueToRibbons", sender: self)
  }

  @IBAction func openSite(_ sender: Any) {
    // close popovers if open
    dismiss(animated: true, completion: {})
    UIApplication.shared.openURL(URL.init(string: "https://collectable.art")!)
  }

  // proud of this lil script, so it gets to stay :)
  func uploadRibbons() {
    UserDefaults.standard.removeObject(forKey: "ribbons")
    UserDefaults.standard.removeObject(forKey: "ribbon")

    let fileManager = FileManager.default
    let path = "/Users/nozlee/Desktop/7on7/ribbons/ribbons/"
    let files = fileManager.enumerator(atPath: path)
    let metadata = FIRStorageMetadata()
    metadata.contentType = "image/gif"
    while let file = files?.nextObject() as? String {
      let imagePath = (path as NSString).appendingPathComponent(file)
      if fileManager.fileExists(atPath: imagePath) {
        if let data = NSData.init(contentsOfFile: imagePath) as Data? {
          storageRef.child("ribbons").child(file).put(data, metadata: metadata).observe(.success) { (snapshot) in
            let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
            // Write the download URL to the Realtime Database
            self.ref.child("ribbons/\(self.sanitizeString(string: file))").setValue(["file": file, "url": downloadURL])
          }
        }
      }
    }
  }

  func sanitizeString(string : String) -> String {
    let blacklist = CharacterSet(charactersIn: ".$[]#")
    let components = string.components(separatedBy: blacklist)
    return components.joined(separator: "")
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: true)

    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)

    super.viewWillDisappear(animated)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return timestamps.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let timestamp = timestamps[indexPath.row] as! String
    let collect = collects[timestamp] as! NSDictionary

    let cell = tableView.dequeueReusableCell(withIdentifier: "CollectsTableViewCell") as! CollectsTableViewCell

    cell.titleLabel?.text = collect.value(forKey: "title") as? String

    cell.removeAllRightButtons()
    cell.delegate = self
    cell.showsRightSlideIndicator = false

    let publishTitle = collect.object(forKey: "published") as? NSNumber == 0 ? "set public" : "set private"
    cell.addRightButton(withText: publishTitle, textColor: UIColor.white, backgroundColor: blue, font: font)

    let readonlyTitle = collect.object(forKey: "readonly") as? NSNumber == 0 ? "close collect" : "open collect"
    cell.addRightButton(withText: readonlyTitle, textColor: UIColor.white, backgroundColor: purple, font: font)

    cell.addRightButton(withText: "delete", textColor: UIColor.white, backgroundColor: UIColor.gray, font: font)

    return cell
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.separatorInset = UIEdgeInsets.zero
    cell.layoutMargins = UIEdgeInsets.zero
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func slideTableViewCell(_ cell: SESlideTableViewCell!, didTriggerRightButton buttonIndex: NSInteger) {
    let indexPath = tableView.indexPath(for: cell)!
    let timestamp = timestamps[indexPath.row] as! String
    let dict = collects[timestamp] as! NSDictionary
    let collect = dict.mutableCopy() as! NSMutableDictionary

    if buttonIndex == 0 {
      let published = !(collect.object(forKey: "published") as? NSNumber == 0 ? false : true)
      collect.setObject(published, forKey: "published" as NSCopying)
      collects[timestamp] = collect
      ref.child("users/\(uid!)/collects/\(timestamp)/published").setValue(published)
      ref.child("collects/\(timestamp)/published").setValue(published)
    } else if buttonIndex == 1 {
      let readonly = !(collect.object(forKey: "readonly") as? NSNumber == 0 ? false : true)
      collect.setObject(readonly, forKey: "readonly" as NSCopying)
      collects[timestamp] = collect
      ref.child("users/\(uid!)/collects/\(timestamp)/readonly").setValue(readonly)
      ref.child("collects/\(timestamp)/readonly").setValue(readonly)
    } else {
      ref.child("users/\(uid!)/collects/\(timestamp)").removeValue()
      ref.child("collects/\(timestamp)").removeValue()
      timestamps.removeObject(at: indexPath.row)
      collects.removeObject(forKey: timestamp)
    }

    UserDefaults.standard.set(collects, forKey: "collects")
    tableView.reloadData()
  }

  func slideTableViewCell(_ cell: SESlideTableViewCell!, wilShowButtonsOf side: SESlideTableViewCellSide) {
    let indexPath = tableView.indexPath(for: cell)!
    // if there's a previously opened slide menu in another cell, close it
    if slidOpenIndexPath != nil,
      indexPath != slidOpenIndexPath,
      let slidOpenCell = tableView.cellForRow(at: slidOpenIndexPath) as? SESlideTableViewCell {
      slidOpenCell.setSlideState(SESlideTableViewCellSlideState.center, animated: true)
    }
    slidOpenIndexPath = indexPath
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    // if there's any open slide menu, close it before moving
    if slidOpenIndexPath != nil,
      let slidOpenCell = tableView.cellForRow(at: slidOpenIndexPath) as? SESlideTableViewCell {
      slidOpenCell.setSlideState(SESlideTableViewCellSlideState.center, animated: false)
    }
  }

  @IBAction func createCollect(_ button: UIButton) {
    // close popovers if open
    dismiss(animated: true, completion: {})
    let alert = AlertController(title: "", message: "", preferredStyle: .alert)
    alert.addTextField(withHandler: { (textField) -> Void in
      textField.autocapitalizationType = UITextAutocapitalizationType.none
    })
    alert.add(AlertAction(title: "Cancel", style: .normal))
    alert.add(AlertAction(title: "Add collect", style: .normal, handler: { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      if (textField.text?.characters.count)! > 0 {
        self.initCollect(textField.text! as NSString)
      }
    }))
    alert.visualStyle.textFieldFont = font
    alert.visualStyle.textFieldHeight = 30
    alert.visualStyle.alertNormalFont = font
    alert.visualStyle.normalTextColor = purple
    alert.visualStyle.backgroundColor = UIColor.white
    alert.visualStyle.cornerRadius = 0

    alert.present()
  }

  func updateCollect(timestamp: String, collect: NSDictionary) {
    collects.setValue(collect, forKey: timestamp)
    UserDefaults.standard.set(collects, forKey: "collects")
    tableView.reloadData()
  }

  func initCollect(_ title: NSString!) {
    let timestamp = "\(Int(NSDate().timeIntervalSince1970))"

    let collect: [String: Any] = ["title": title!, "readonly": false, "published": false]

    let templateLength = (UserDefaults.standard.object(forKey: "templates") as! NSArray).count
    let templateIndex = Int(arc4random_uniform(UInt32(templateLength))) + 1
    ref.child("collects/\(timestamp)").setValue(["title": title!, "template": templateIndex, "readonly": false, "published": false])
    ref.child("users/\(uid!)/collects/\(timestamp)").setValue(collect)

    collects.setValue(collect, forKey: timestamp)
    timestamps.insert(timestamp, at: 0)
    tableView.reloadData()

    UserDefaults.standard.set(collects, forKey: "collects")
    performSegue(withIdentifier: "segueToCollect", sender: timestamp)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueToCollect" {
      var timestamp: String
      if let indexPath = tableView.indexPathForSelectedRow {
        timestamp = timestamps[indexPath.row] as! String
      } else {
        timestamp = sender as! String
      }
      let destination = segue.destination as! CollectViewController
      destination.collectTitle = (collects.value(forKey: timestamp) as! NSDictionary).value(forKey: "title") as! String
      destination.timestamp = timestamp
      destination.delegate = self
    } else if segue.identifier == "segueToRibbons" {
      if let destination = segue.destination as? RibbonCollectionViewController {
        destination.popoverPresentationController!.delegate = self
        destination.preferredContentSize = CGSize(width: 300, height: 300)
        destination.delegate = self
      }
    } else if segue.identifier == "segueToAbout" {
      segue.destination.popoverPresentationController!.delegate = self
      segue.destination.preferredContentSize = CGSize(width: 300, height: 300)
    }
  }

  @IBAction func unwindToCollects(segue:UIStoryboardSegue) {

  }

  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.none
  }

  func setReachability() {
    let html = "<html><body><h1>oops</h1><p>please connect to the internet</p></body></html>"
    offlineView.loadHTMLString(html, baseURL: nil)

    manager?.listener = { status in
      if status == .notReachable {
        self.lockDown()
      } else {
        self.setAuth()
      }
    }

    manager?.startListening()
  }

  func lockDown() {
    dismiss(animated: true, completion: {})
    activityIndicator.stopAnimating()
    addButton.isEnabled = false
    userButton.isEnabled = false
    tableView.isHidden = true
    offlineView.isHidden = false
  }
  
}
