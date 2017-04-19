//
//  CollectViewController.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import QuartzCore
import UIKit
import Firebase
import AlamofireImage
import SDCAlertView

class CollectTitleTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  
}

class CollectTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var entryImageView: UIImageView!
  
}

class CollectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var uid: String!
  var timestamp: String!
  var collect: NSDictionary!
  var entryTimestamps: NSMutableArray! = []
  var entries: NSMutableDictionary! = NSMutableDictionary()
  var readonly: Bool = false
  var ref: FIRDatabaseReference!
  //@IBOutlet weak var openCollectButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var renameButton: UIBarButtonItem!
  @IBOutlet weak var remixButton: UIBarButtonItem!
  @IBOutlet weak var addButton: UIBarButtonItem!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()

//    if let font = UIFont(name: "Times New Roman", size: 16) {
//      openCollectButton.setTitleTextAttributes([NSFontAttributeName:font], for: .normal)
//    }
    
    uid = UserDefaults.standard.string(forKey: "uid")!;
    
    ref = FIRDatabase.database().reference()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140
    tableView.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    getEntries();
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  func getEntries() {
    activityIndicator.startAnimating()
    ref.child("collects/\(timestamp!)").observeSingleEvent(of: .value, with: { (snapshot) in
      if snapshot.exists() {
        if let value = snapshot.value as? NSDictionary {
          self.collect = value
          if let entries = self.collect.value(forKey: "entries") as? NSDictionary {
            self.entries = entries.mutableCopy() as! NSMutableDictionary
          }
          self.entryTimestamps = NSMutableArray.init(array: self.entries.allKeys)
          
          print(self.collect)
          if (self.collect.object(forKey: "readonly") as? NSNumber) == 1 {
            self.readonly = true
            self.addButton.isEnabled = false
            self.remixButton.isEnabled = false
            self.renameButton.isEnabled = false
          }
          
          self.tableView.reloadData()
          self.activityIndicator.stopAnimating()
          self.tableView.isHidden = false
        }
      }
    }) { (error) in
      self.activityIndicator.stopAnimating()
      self.tableView.isHidden = false
      print(error.localizedDescription)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func renameCollect(_ button: UIButton) {
    let alert = AlertController(title: "", message: "", preferredStyle: .alert)
    alert.addTextField(withHandler: { (textField) -> Void in
      textField.autocapitalizationType = UITextAutocapitalizationType.none;
      textField.text = self.collect.value(forKey: "title") as? String
    });
    alert.add(AlertAction(title: "Cancel", style: .normal))
    alert.add(AlertAction(title: "Rename collect", style: .normal, handler: { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      if (textField.text?.characters.count)! > 0 {
        self.changeTitle(textField.text! as NSString)
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
  
  @IBAction func openCollect(_ sender: Any) {
    if timestamp != nil, let title = collect.value(forKey: "title") {
      let url = ("https://collectsart.firebaseapp.com/\(timestamp!)/\(title)" as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      UIApplication.shared.openURL(URL.init(string: url)!)
    }
  }
  
  func changeTitle (_ title: NSString!) {
    collect.setValue(title, forKey: "title")
    
    refreshTitleCell()
    
    let dict = UserDefaults.standard.object(forKey: "collects") as! NSDictionary
    let collects = dict.mutableCopy() as! NSMutableDictionary
    collects.setObject(collect, forKey: timestamp as NSCopying)
    UserDefaults.standard.set(collects, forKey: "collects");
    
    self.ref.child("users/\(uid!)/collects/\(timestamp!)/title").setValue(title)
    self.ref.child("collects/\(timestamp!)/title").setValue(title)
  }
  
  func refreshTitleCell() {
    tableView.beginUpdates()
    tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
    tableView.endUpdates()
  }
  
  // MARK: - Table view data source
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      return entryTimestamps.count
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CollectTitleTableViewCell") as! CollectTitleTableViewCell
      
      cell.titleLabel?.text = collect?.value(forKey: "title") as? String;
      
      return cell;
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CollectTableViewCell") as! CollectTableViewCell
      
      let entryTimestamp = entryTimestamps[indexPath.row] as! String
      let entry = entries.value(forKey: entryTimestamp) as! NSDictionary
      
      cell.titleLabel?.text = entry.value(forKey: "title") as? String;
      if let imageURL = entry.value(forKey: "image") as? String {
        cell.entryImageView?.af_setImage(withURL: URL(string: imageURL)!)
      } else {
        cell.entryImageView.isHidden = true
      }
      
      return cell;
    }
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if readonly || indexPath.section == 0 {
      return false
    }
    return true
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let deleteAction = UITableViewRowAction(style: .normal, title: "x") { (rowAction, indexPath) in
      let entryTimestamp = self.entryTimestamps[indexPath.row] as! String
      self.ref.child("collects/\(self.timestamp!)/entries/\(entryTimestamp)").removeValue()
      self.entryTimestamps.removeObject(at: indexPath.row)
      self.entries.removeObject(forKey: entryTimestamp)
      
      tableView.reloadData();
    }
    deleteAction.backgroundColor = .purple
    
    return [deleteAction]
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  @IBAction func backToCollects(_ sender: Any) {
    performSegue(withIdentifier: "unwindToCollects", sender: self)
  }
  
  @IBAction func unwindToCollect(segue:UIStoryboardSegue) {

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueToEntry" {
      var entryTimestamp: String;
      var entry: NSDictionary;
      if let indexPath = tableView.indexPathForSelectedRow {
        entryTimestamp = entryTimestamps[indexPath.row] as! String
      } else {
        entryTimestamp = sender as! String
      }
      entry = entries.value(forKey: entryTimestamp) as! NSDictionary
      
      let destination = segue.destination as! EntryViewController
      destination.entry = entry
      destination.collectTimestamp = timestamp
      destination.timestamp = entryTimestamp
      destination.readonly = readonly
    }
  }
  
  @IBAction func createEntry(_ sender: Any) {
    let entryTimestamp = "\(Int(NSDate().timeIntervalSince1970))"
    let entry: NSDictionary = ["title": "", "image": false];
    ref.child("collects/\(timestamp!)/entries/\(entryTimestamp)").setValue(entry)
    (collect.value(forKey: "entries") as? NSDictionary)?.setValue(entry, forKey: entryTimestamp)
    entries.setValue(entry, forKey: entryTimestamp)
    entryTimestamps = NSMutableArray.init(array: entries.allKeys)
    tableView.reloadData()
    performSegue(withIdentifier: "segueToEntry", sender: entryTimestamp)
  }
  
}
