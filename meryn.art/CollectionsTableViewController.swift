//
//  CollectionsTableViewController
//  meryn.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit
import Firebase

class CollectionsTableViewController: UITableViewController {
  
  var collections: NSMutableArray!
  var storageRef: FIRStorageReference!
  var databaseRef: FIRDatabaseReference!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    storageRef = FIRStorage.storage().reference()
    databaseRef = FIRDatabase.database().reference()

    collections = UserDefaults.standard.object(forKey: "collections") as! NSMutableArray;
  }
  
  override func viewWillAppear(_ animated: Bool) {
//    self.title = "Pick a Community";
//    self.navigationItem.setHidesBackButton(true, animated: false)
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
//    self.title = "";
//    self.navigationItem.setHidesBackButton(false, animated: false)
    super.viewWillDisappear(animated)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collections.count;
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let collection = collections[indexPath.row] as! NSDictionary

    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CollectionsTableViewCell;
    
    cell.titleLabel?.text = (collection.value(forKey: "title") as! String);
    
    return cell;
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.separatorInset = UIEdgeInsets.zero
    cell.layoutMargins = UIEdgeInsets.zero
  }

//  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    let community = collections[indexPath.row] as! NSDictionary
//    let communityID = community["community_id"]! as! Int
//    let communityName = community["community_name"]! as! String
//    NSUserDefaults.standardUserDefaults().setInteger(communityID, forKey: "communityID");
//    NSUserDefaults.standardUserDefaults().setObject(communityName, forKey: "communityName");
//    
//    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Feed");
//    self.navigationController?.pushViewController(vc, animated: true);
//  }
  
  override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "X";
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.delete) {
      collections.removeObject(at: indexPath.row);

      tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic);
      
      tableView.reloadData();
    }
  }
  
  @IBAction func createCollection(_ button: UIButton) {
    //1. Create the alert controller.
    let alert = UIAlertController(title: "Add collection", message: "Enter a title", preferredStyle: .alert);
    
    //2. Add the text field. You can configure it however you need.
    alert.addTextField(configurationHandler: { (textField) -> Void in
      textField.text = ""
    });
    
    //3. Grab the value from the text field, and print it when the user clicks OK.
    alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      self.createCollect(textField.text! as NSString)
      self.tableView.reloadData();
    }))
    
    // 4. Present the alert.
    self.present(alert, animated: true, completion: nil);
  }
  
  func createCollect(_ collect: NSString!) {
    // create blank file
    // upload blank file
    // store data in nsuserdefaults
    
    let collection = NSMutableDictionary.init(object: collect, forKey: "title" as NSCopying);

    collections.add(collection);
    
    UserDefaults.standard.set(collections, forKey: "collections");
    
    let file = "index.txt" //this is the file. we will write to and read from it
    
    let text = "" //just a text
    
    if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
      let path = URL(fileURLWithPath: dir).appendingPathComponent(file)
      
      //writing
      do {
        try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
      }
      catch {/* error handling here */}
      
//      //reading
//      do {
//        let text2 = try NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding)
//      }
//      catch {/* error handling here */}
    }
  }
  
}
