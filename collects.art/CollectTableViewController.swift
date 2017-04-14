//
//  CollectTableViewController.swift
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

class CollectTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var entryImageView: UIImageView!
  
}

class CollectTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var entries: NSMutableArray = [];
  var uid: String!
  var index: Int!
  var folder: String!
  var collect: NSDictionary!
  var ref: FIRDatabaseReference!
  //@IBOutlet weak var openCollectButton: UIBarButtonItem!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
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
    
    getEntries();
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews();

    let height = tableView.tableHeaderView!.subviews.first!.frame.maxY;
    tableView.tableHeaderView!.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height);
    tableView.tableHeaderView = self.tableView.tableHeaderView;
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  func getEntries() {
    activityIndicator.startAnimating()
    ref.child("collects/\(folder!)").observeSingleEvent(of: .value, with: { (snapshot) in
      if snapshot.exists() {
        if let value = snapshot.value as? NSDictionary {
          self.collect = value
          if let allEntries = self.collect["entries"] as? NSDictionary {
            for e in allEntries {
              self.entries.add(e.value)
            }
          }
        }
      }
      
      self.titleLabel.text = self.collect.value(forKey: "title") as? String
      self.tableView.reloadData()
      self.activityIndicator.stopAnimating()
      self.tableView.isHidden = false
    }) { (error) in
      self.activityIndicator.stopAnimating()
      self.tableView.isHidden = false
      // TODO do something about offline mode
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
  
  func changeTitle (_ title: NSString!) {
    self.ref.child("users/\(uid!)/collects/\(folder!)").removeValue()
    self.ref.child("collects/\(folder!)").removeValue()
    
    folder = sanitizeCollect(string: title! as String)
    collect.setValue(title, forKey: "title")
    self.titleLabel.text = title as String;
    
    let localCollect: [String: Any] = ["title": title!, "readonly": collect.value(forKey: "readonly")!]
    let array = UserDefaults.standard.object(forKey: "collects") as! NSArray
    let collects = NSMutableArray(array: array)
    collects[index] = localCollect
    UserDefaults.standard.set(collects, forKey: "collects");
    
    self.ref.child("users/\(uid!)/collects/\(folder!)").setValue(localCollect)
    self.ref.child("collects/\(folder!)").setValue(collect)
  }
  
  func sanitizeCollect(string : String) -> String {
    // put anything you dislike in that set ;-)
    let blacklist = CharacterSet(charactersIn: ".$[]#")
    let components = string.components(separatedBy: blacklist)
    return components.joined(separator: "")
  }

  // MARK: - Table view data source
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return entries.count;
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CollectTableViewCell
    
    let entry = entries[indexPath.row] as! NSDictionary
    
    cell.titleLabel?.text = entry.value(forKey: "title") as? String;
    if let imageURL = entry.value(forKey: "image") as? String {
      cell.entryImageView?.af_setImage(withURL: URL(string: imageURL)!)
    }
    return cell;
  }

  @IBAction func backToCollects(_ sender: Any) {
    performSegue(withIdentifier: "unwindToCollects", sender: self)
  }
  
  @IBAction func unwindToCollect(segue:UIStoryboardSegue) {

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "unwindToCollects" {
      return
    }
    var timestamp: NSString;
    if let indexPath = tableView.indexPathForSelectedRow {
      let entry = entries[indexPath.row] as! NSDictionary
      timestamp = entry.value(forKey: "timestamp") as! NSString
    } else {
      timestamp = sender as! NSString
    }
    let destination = segue.destination as! EntryViewController
    destination.timestamp = timestamp
  }
  
  @IBAction func createEntry(_ sender: Any) {
    let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
    let entry: NSDictionary = ["title": "", "image": false, "description": "", "timestamp": timestamp];
    self.ref.child("entries/\(timestamp)").setValue(entry)
    self.ref.child("collects/\(folder!)/entries/\(timestamp)").setValue(entry)
    entries.add(entry)
    self.tableView.reloadData()
    performSegue(withIdentifier: "segueToEntry", sender: timestamp)
  }

  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  */

  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      // Delete the row from the data source
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }  
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
  }
  */

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
  */
  
}
