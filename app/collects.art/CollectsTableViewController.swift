//
//  CollectsTableViewController
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit
import Firebase
import SDCAlertView

class CollectsTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  
}

class CollectsTableViewController: UITableViewController {
  
  var collects: NSMutableDictionary!
  var timestamps: NSArray!
  var ref: FIRDatabaseReference!
  var uid: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = FIRDatabase.database().reference()
    
    // Using Cloud Storage for Firebase requires the user be authenticated. Here we are using
    // anonymous authentication.
    if FIRAuth.auth()?.currentUser == nil {
      FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
        if error != nil {
          // TODO lock down app in some way
        } else {
          UserDefaults.standard.set(user!.uid, forKey: "uid");
          self.uid = user!.uid
        }
      })
    } else {
      UserDefaults.standard.set(FIRAuth.auth()!.currentUser!.uid, forKey: "uid");
      uid = FIRAuth.auth()!.currentUser!.uid
    }
    
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableViewAutomaticDimension
  }
    
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    
    let dict = UserDefaults.standard.object(forKey: "collects") as! NSDictionary;
    collects = dict.mutableCopy() as! NSMutableDictionary
    timestamps = collects.allKeys as NSArray
    tableView.reloadData()
    print("reloaded")

    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    super.viewWillDisappear(animated)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return timestamps.count;
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let timestamp = timestamps[indexPath.row] as! String
    let collect = collects[timestamp] as! NSDictionary

    let cell = tableView.dequeueReusableCell(withIdentifier: "CollectsTableViewCell") as! CollectsTableViewCell;

    cell.titleLabel?.text = collect.value(forKey: "title") as? String;

    return cell;
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.separatorInset = UIEdgeInsets.zero
    cell.layoutMargins = UIEdgeInsets.zero
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true;
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let timestamp = timestamps[indexPath.row] as! String
    let dict = collects[timestamp] as! NSDictionary
    let collect = dict.mutableCopy() as! NSMutableDictionary
    
    let readonlyTitle = collect.object(forKey: "readonly") as? NSNumber == 0 ? "→readonly" : "→editable"
    
    let readonlyAction = UITableViewRowAction(style: .normal, title: readonlyTitle) { (rowAction, indexPath) in
      let readonly = !(collect.object(forKey: "readonly") as? NSNumber == 0 ? false : true)
      print(readonly)
      collect.setObject(readonly, forKey: "readonly" as NSCopying)
      self.collects[timestamp] = collect
      UserDefaults.standard.set(self.collects, forKey: "collects");
      self.ref.child("users/\(self.uid!)/collects/\(timestamp)/readonly").setValue(readonly)
      self.ref.child("collects/\(timestamp)/readonly").setValue(readonly)
      tableView.reloadData();
    }
    readonlyAction.backgroundColor = .blue

    let deleteAction = UITableViewRowAction(style: .normal, title: "x") { (rowAction, indexPath) in
      self.collects.removeObject(forKey: timestamp);
      UserDefaults.standard.set(self.collects, forKey: "collects");
      self.ref.child("users/\(self.uid!)/collects/\(timestamp)").removeValue()
      self.ref.child("collects/\(timestamp)").removeValue()

      tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic);

      tableView.reloadData();
    }
    deleteAction.backgroundColor = .purple

    return [deleteAction, readonlyAction]
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

    self.ref.child("collects/\(timestamp)").setValue(["title": title!, "template": "", "readonly": false, "entries": {}])
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
      let destination = segue.destination as! CollectTableViewController
      destination.timestamp = timestamp
    }
  }

  @IBAction func unwindToCollects(segue:UIStoryboardSegue) {

  }

}
