//
//  CollectsTableViewController
//  meryn.art
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
  
  var collects: NSMutableArray!
  var ref: FIRDatabaseReference!
  var uid: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = FIRDatabase.database().reference()
    
    uid = UserDefaults.standard.string(forKey: "uid")!;

    let array = UserDefaults.standard.object(forKey: "collects") as! NSArray;
    collects = NSMutableArray(array: array)

    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collects.count;
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let collect = collects[indexPath.row] as! NSDictionary

    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CollectsTableViewCell;
    
    cell.titleLabel?.text = collect.value(forKey: "title") as? String;
    
    return cell;
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.separatorInset = UIEdgeInsets.zero
    cell.layoutMargins = UIEdgeInsets.zero
  }

//  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//
//  }
  
  override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "X";
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.delete) {
      let collect = collects[indexPath.row] as! NSDictionary
      collects.removeObject(at: indexPath.row);
      UserDefaults.standard.set(collects, forKey: "collects");
      self.ref.child("users/\(uid)/collects/\(collect.value(forKey: "title") as! String)").removeValue()
      
      tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic);
      
      tableView.reloadData();
    }
  }
  
  @IBAction func createCollect(_ button: UIButton) {
    let alert = AlertController(title: "", message: "", preferredStyle: .alert)
    alert.addTextField(withHandler: { (textField) -> Void in
      textField.autocapitalizationType = UITextAutocapitalizationType.none;
    });
    alert.add(AlertAction(title: "Cancel", style: .normal))
    alert.add(AlertAction(title: "Add collect", style: .normal, handler: { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      self.initCollect(textField.text! as NSString)
      self.tableView.reloadData();
    }))
    alert.visualStyle.textFieldFont = UIFont(name: "Times New Roman", size: 16)!
    alert.visualStyle.textFieldHeight = 30
    alert.visualStyle.alertNormalFont = UIFont(name: "Times New Roman", size: 16)!
    alert.visualStyle.normalTextColor = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
    alert.visualStyle.backgroundColor = UIColor.white
    alert.visualStyle.cornerRadius = 0
    
    alert.present()
  }
  
  func initCollect(_ collect: NSString!) {
    let folder = sanitizeCollect(string: collect! as String)
    self.ref.child("users/\(uid)/collects/\(folder)").setValue(true)
    // TODO: assign template and url
    self.ref.child("collects/\(folder)").setValue(["url": false, "template": false, "entries": false, "readonly": false])
    
    let collect: [String: Any] = ["title": collect!]

    collects.add(collect);
    
    UserDefaults.standard.set(collects, forKey: "collects");
  }
  
  func sanitizeCollect(string : String) -> String {
    // put anything you dislike in that set ;-)
    let blacklist = CharacterSet(charactersIn: ".$[]#")
    let components = string.components(separatedBy: blacklist)
    return components.joined(separator: "")
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = tableView.indexPathForSelectedRow {
      let collect = collects[indexPath.row] as! NSDictionary
      UserDefaults.standard.set(collect.value(forKey: "title") as! String, forKey: "collectName");
    }
  }

  @IBAction func unwindToCollects(segue:UIStoryboardSegue) {

  }

}
