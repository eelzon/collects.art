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

class CollectsTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  
}

class CollectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {
  
  let purple = UIColor(colorLiteralRed: 0, green: 0, blue: 238/256, alpha: 1.0)
  let blue = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
  let manager = NetworkReachabilityManager(host: "www.rhizome.org")
  var collects: NSMutableDictionary!
  var timestamps: NSMutableArray!
  var ref: FIRDatabaseReference!
  var storageRef: FIRStorageReference!
  var uid: String!
  var ribbon: String!
  @IBOutlet weak var addButton: UIBarButtonItem!
  @IBOutlet weak var userButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var offlineView: UIWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setReachability()
    
    let html = "<html><body><h1>oops</h1><p>please connect to the internet</p></body></html>"
    offlineView.loadHTMLString(html, baseURL: nil)
    
    setAuth()
    
    let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
    button.setImage(UIImage.init(named: "add"), for: UIControlState.normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    button.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    button.addTarget(self, action: #selector(createCollect(_:)), for:UIControlEvents.touchUpInside)
    addButton.customView = button
    
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  func setAuth() {
    activityIndicator.startAnimating()
    tableView.isHidden = true

    ref = FIRDatabase.database().reference()
    storageRef = FIRStorage.storage().reference()
    
    // Using Cloud Storage for Firebase requires the user be authenticated. Here we are using
    // anonymous authentication.
    if FIRAuth.auth()?.currentUser == nil {
      FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
        if error != nil {
          self.lockDown()
        } else {
          UserDefaults.standard.set(user!.uid, forKey: "uid");
          self.uid = user!.uid
        }
        self.showTable()
        self.getRibbons()
      })
    } else {
      UserDefaults.standard.set(FIRAuth.auth()!.currentUser!.uid, forKey: "uid");
      uid = FIRAuth.auth()!.currentUser!.uid
      //uploadRibbons()
      showTable()
      getRibbons()
    }
  }
  
  func setUserRibbon() {
    ribbon = UserDefaults.standard.object(forKey: "ribbon") as? String
    if ribbon == nil {
      let ribbons = UserDefaults.standard.object(forKey: "ribbons") as! NSArray
      let index = Int(arc4random_uniform(UInt32(ribbons.count)))
      ribbon = ribbons.object(at: index) as? String
      UserDefaults.standard.set(ribbon, forKey: "ribbon")
    }
    
    self.ref.child("users/\(self.uid!)/ribbon").setValue(ribbon!)
    
    let data = try! Data(contentsOf: URL(string: ribbon!)!)
    let image = UIImage(data: data)
    image?.af_inflate()
    
    let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
    button.setImage(image, for: UIControlState.normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.addTarget(self, action: #selector(openRibbons(_:)), for:UIControlEvents.touchUpInside)
    userButton.customView = button
  }
  
  func getRibbons() {
    UserDefaults.standard.addObserver(self, forKeyPath: "ribbon", options: NSKeyValueObservingOptions.new, context: nil)
    
    UserDefaults.standard.removeObject(forKey: "ribbons")
    if UserDefaults.standard.object(forKey: "ribbons") == nil {
      ref.child("ribbons").observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists(), let value = snapshot.value as? NSDictionary {
          let ribbons = NSMutableArray()
          for ribbon in value {
            ribbons.add((ribbon.value as! NSDictionary).value(forKey: "url")!)
          }
          UserDefaults.standard.set(ribbons, forKey: "ribbons");
          self.setUserRibbon()
        }
      })
    } else {
      setUserRibbon()
    }
  }
  
  func openRibbons(_ sender:Any) {
    performSegue(withIdentifier: "segueToRibbons", sender: self)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "ribbon" {
      self.dismiss(animated: true, completion: (() -> Void)? {
        self.setUserRibbon()
      })
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
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
  
  func showTable() {
    activityIndicator.stopAnimating()
    tableView.isHidden = false
  }
    
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    
    let dict = UserDefaults.standard.object(forKey: "collects") as! NSDictionary;
    collects = dict.mutableCopy() as! NSMutableDictionary
    timestamps = NSMutableArray.init(array:collects.allKeys)
    tableView.reloadData()

    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    
    super.viewWillDisappear(animated)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return timestamps.count;
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let timestamp = timestamps[indexPath.row] as! String
    let collect = collects[timestamp] as! NSDictionary

    let cell = tableView.dequeueReusableCell(withIdentifier: "CollectsTableViewCell") as! CollectsTableViewCell;

    cell.titleLabel?.text = collect.value(forKey: "title") as? String;

    return cell;
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.separatorInset = UIEdgeInsets.zero
    cell.layoutMargins = UIEdgeInsets.zero
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true;
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let timestamp = timestamps[indexPath.row] as! String
    let dict = collects[timestamp] as! NSDictionary
    let collect = dict.mutableCopy() as! NSMutableDictionary
    
    let readonlyTitle = collect.object(forKey: "readonly") as? NSNumber == 0 ? "→close" : "→open"
    
    let readonlyAction = UITableViewRowAction(style: .normal, title: readonlyTitle) { (rowAction, indexPath) in
      let readonly = !(collect.object(forKey: "readonly") as? NSNumber == 0 ? false : true)
      collect.setObject(readonly, forKey: "readonly" as NSCopying)
      self.collects[timestamp] = collect
      UserDefaults.standard.set(self.collects, forKey: "collects");
      self.ref.child("users/\(self.uid!)/collects/\(timestamp)/readonly").setValue(readonly)
      self.ref.child("collects/\(timestamp)/readonly").setValue(readonly)
      tableView.reloadData();
    }
    readonlyAction.backgroundColor = blue

    let deleteAction = UITableViewRowAction(style: .normal, title: "x") { (rowAction, indexPath) in
      self.ref.child("users/\(self.uid!)/collects/\(timestamp)").removeValue()
      self.ref.child("collects/\(timestamp)").removeValue()
      self.timestamps.removeObject(at: indexPath.row)
      self.collects.removeObject(forKey: timestamp);
      UserDefaults.standard.set(self.collects, forKey: "collects");

      tableView.reloadData();
    }
    deleteAction.backgroundColor = purple

    return [deleteAction, readonlyAction]
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
    cell.contentView.backgroundColor = UIColor(colorLiteralRed: 200/256, green: 200/256, blue: 204/256, alpha: 0.1)
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
    cell.contentView.backgroundColor = UIColor.clear
  }
  
  @IBAction func createCollect(_ button: UIButton) {
    let alert = AlertController(title: "", message: "", preferredStyle: .alert)
    alert.addTextField(withHandler: { (textField) -> Void in
      textField.autocapitalizationType = UITextAutocapitalizationType.none;
    });
    alert.add(AlertAction(title: "Cancel", style: .normal))
    alert.add(AlertAction(title: "Add collect", style: .normal, handler: { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      if (textField.text?.characters.count)! > 0 {
        self.initCollect(textField.text! as NSString)
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
  
  func initCollect(_ title: NSString!) {
    let timestamp = "\(Int(NSDate().timeIntervalSince1970))"

    // TODO: assign template
    let collect: [String: Any] = ["title": title!, "readonly": false]
    let templateIndex = Int(arc4random_uniform(UInt32(7)))
    
    self.ref.child("collects/\(timestamp)").setValue(["title": title!, "template": templateIndex, "readonly": false, "entries": NSDictionary()])
    self.ref.child("users/\(uid!)/collects/\(timestamp)").setValue(collect)

    collects.setValue(collect, forKey: timestamp)
    self.tableView.reloadData();
    
    UserDefaults.standard.set(collects, forKey: "collects");
    performSegue(withIdentifier: "segueToCollect", sender: timestamp)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueToCollect" {
      var timestamp: String;
      if let indexPath = tableView.indexPathForSelectedRow {
        timestamp = timestamps[indexPath.row] as! String
      } else {
        timestamp = sender as! String
      }
      let destination = segue.destination as! CollectViewController
      destination.timestamp = timestamp
    } else if segue.identifier == "segueToRibbons" {
      if let destination = segue.destination as? RibbonCollectionViewController {
        destination.popoverPresentationController!.delegate = self
        destination.preferredContentSize = CGSize(width: 300, height: 300)
        destination.ribbon = ribbon
      }
    }
  }

  @IBAction func unwindToCollects(segue:UIStoryboardSegue) {

  }
  
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.none
  }
  
  func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    setUserRibbon()
  }
  
  func setReachability() {
    manager?.listener = { status in
      if status == .notReachable {
        self.lockDown()
      } else {
        self.offlineView.isHidden = true;
        self.setAuth()
      }
    }
    
    manager?.startListening()
  }
  
  func lockDown() {
    self.activityIndicator.stopAnimating()
    self.tableView.isHidden = true
    self.dismiss(animated: true, completion: {})
    self.offlineView.isHidden = false
  }
  
}
