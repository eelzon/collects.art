//
//  CollectionTableViewController.swift
//  meryn.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import QuartzCore
import UIKit
import Firebase

class CollectionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var entries: NSMutableArray = [];
  var uid: String!
  var collect: String!
  var ref: FIRDatabaseReference!
  @IBOutlet weak var openCollectButton: UIBarButtonItem!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()

    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: "folder")
    navigationItem.titleView = imageView

    if let font = UIFont(name: "Times New Roman", size: 16) {
      openCollectButton.setTitleTextAttributes([NSFontAttributeName:font], for: .normal)
    }
    
    // turn on loading animation
    
    // turn off loading animation
    
    uid = UserDefaults.standard.string(forKey: "uid")!;
    collect = UserDefaults.standard.string(forKey: "collectName")!;
    titleLabel.text = collect

    ref = FIRDatabase.database().reference()

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140
//    tableView.isHidden = true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews();

    let height = tableView.tableHeaderView!.subviews.first!.frame.maxY;
    tableView.tableHeaderView!.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height);
    tableView.tableHeaderView = self.tableView.tableHeaderView;
  }

  override func viewWillAppear(_ animated: Bool) {
    // get entries
    getEntries();
    
    navigationController?.isToolbarHidden = false;

    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isToolbarHidden = true;
  }
  
  func getEntries() {
//    activityIndicator.startAnimating()
//    ref.child("users/\(uid)/collects/\(collect!)").observeSingleEvent(of: .value, with: { (snapshot) in
//      let collect = snapshot.value as? NSDictionary
//      self.entries = collect?["entries"] as? NSDictionary as! NSMutableDictionary
//      print(self.entries)
//    }) { (error) in
//      print(error.localizedDescription)
//    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return entries.count;
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CollectionTableViewCell
    
    let entry = entries[indexPath.row] as! NSDictionary
    
    cell.titleLabel?.text = entry.value(forKey: "title") as? String;

//    cell.imageView?.af_setImageWithURL(URL(string: author["profile_image_url"] as! String)!)
    
    return cell;
  }
  
  @IBAction func openActivityViewController(_ sender: UIButton) {
//    let cell = tableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! CollectionTableViewCell;
//    let entry = entries.object(at: sender.tag);
//    
//    let title = cell.titleLabel.attributedText?.string;
//    let image = cell.bodyImageView?.image
//    //let URL = entry["url"] as! String
//    
//    let activityViewController = UIActivityViewController(activityItems: [title!, image!, URL()], applicationActivities: nil)
//    activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.copyToPasteboard, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList, UIActivityType.airDrop, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.postToWeibo]
//    self.navigationController?.present(activityViewController, animated: true) {
//      // ...
//    }
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
