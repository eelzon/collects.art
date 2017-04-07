//
//  CollectionsTableViewController
//  meryn.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit
import AlamofireImage

class CollectionsTableViewController: UITableViewController {
  
  var collections = NSMutableArray();
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collections = NSUserDefaults.standardUserDefaults().objectForKey("collections") as! NSMutableArray;
  }
  
  override func viewWillAppear(animated: Bool) {
//    self.title = "Pick a Community";
//    self.navigationItem.setHidesBackButton(true, animated: false)
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
//    self.title = "";
//    self.navigationItem.setHidesBackButton(false, animated: false)
    super.viewWillDisappear(animated)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collections.count;
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let community = collections[indexPath.row] as! NSDictionary

    let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CollectionsTableViewCell;
    
    cell.titleLabel?.text = (community["title"]! as! String);
    
    return cell;
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
  
  override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
    return "X";
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      collections.removeObjectAtIndex(indexPath.row);

      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic);
      
      tableView.reloadData();
    }
  }
  
  @IBAction func createCollection(button: UIButton) {
    //1. Create the alert controller.
    var alert = UIAlertController(title: "Add collection", message: "Enter a title", preferredStyle: .Alert)
    
    //2. Add the text field. You can configure it however you need.
    alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
      textField.text = ""
    })
    
    //3. Grab the value from the text field, and print it when the user clicks OK.
    alert.addAction(UIAlertAction(title: "Create", style: .Default, handler: { [weak alert] (action) -> Void in
      let textField = alert.textFields![0] as UITextField
      println("Text field: \(textField.text)")
    }))
    
    // 4. Present the alert.
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
}
