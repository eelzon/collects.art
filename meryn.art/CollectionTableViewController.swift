//
//  CollectionTableViewController.swift
//  meryn.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import QuartzCore
import UIKit
import Alamofire
import AlamofireImage

class CollectionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var entries = [];
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  let dateParser = NSDateFormatter()
  let dateFormatter = NSDateFormatter()
  let refreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"

    // turn on loading animation
    
    // turn off loading animation
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140
    tableView.hidden = true

    // Initialize the refresh control.
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(CollectionTableViewController.getEntries), forControlEvents: .ValueChanged)
    tableView.addSubview(refreshControl)
  }
  
  override func viewWillAppear(animated: Bool) {
    //self.title = (NSUserDefaults.standardUserDefaults().objectForKey("communityName") as! String);
    self.navigationItem.setHidesBackButton(false, animated: false)
    
    // get entries
    getEntries();

    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    //self.title = "";
    super.viewWillDisappear(animated)
  }
  
  func getEntries() {
    activityIndicator.startAnimating()
    let headers = [
      "Authorization": "foo",
      "Accept": "application/json"
    ]
    let parameters = [
      "type": "foo"
    ];
    
    Alamofire.request(.GET,
      "http://google.com",
      headers: headers,
      parameters: parameters)
      .responseJSON { response in
        let dict = response.result.value as! NSDictionary;
        self.entries = (dict["_embedded"] as! NSDictionary)["entry"] as! NSArray;
        self.activityIndicator.stopAnimating()
        self.tableView.hidden = false;
        self.tableView.reloadData();
        self.refreshControl.endRefreshing()
    }
    
  }
  
  func goBack() {
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIContentSizeCategoryDidChangeNotification,
                                object: nil,
                                queue: NSOperationQueue.mainQueue()) {
                                  [weak self] _ in self?.tableView.reloadData()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return entries.count;
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CollectionTableViewCell
    
    let entry = entries[indexPath.row] as! NSDictionary
    let embedded = entry["_embedded"] as! NSDictionary

    if (entry["title"] !== NSNull()) {
      setLabelHTML(cell.titleLabel, html: (entry["title"] as! String), fontName: "OpenSans-Bold")
    } else {
      setLabelHTML(cell.titleLabel, html: "", fontName: "OpenSans-Bold")
    }
    
    if (entry["body_extended"] !== NSNull()) {
      setLabelHTML(cell.bodyLabel, html: (entry["body_extended"] as! String), fontName: "OpenSans")
    } else {
      setLabelHTML(cell.titleLabel, html: "", fontName: "OpenSans")
    }
    
    if (embedded["author"] !== NSNull()) {
      let author = (embedded["author"] as! NSDictionary);
      cell.userLabel?.text = (author["username"] as! String);
      cell.profileImageView?.af_setImageWithURL(NSURL(string: author["profile_image_url"] as! String)!)
      let imageLayer = (cell.profileImageView?.layer)! as CALayer;
      imageLayer.cornerRadius = 5;
      imageLayer.borderWidth = 0;
      imageLayer.masksToBounds = true;
      cell.profileImageView?.layer.cornerRadius = (cell.profileImageView?.frame.size.width)! / 2;
      cell.profileImageView?.layer.masksToBounds = true;
    } else {
      cell.userLabel?.text = "";
      cell.profileImageView?.image = nil
    }
    
    if (entry["visible_comments_count"] !== NSNull()) {
      // TODO: wire up comment count label
      cell.commentsLabel?.text = (entry["visible_comments_count"] as! String);
    } else {
      cell.commentsLabel?.text = "0";
    }
    
    cell.shareButton.tag = indexPath.row;
    
    renderImage(cell, entry: entry)

    cell.selectionStyle = .None
    
    return cell;
  }

  func setLabelHTML(label: UILabel, html: String, fontName: String) {
    let wrappedHTML = "<span style=\"font-family: \(fontName); font-size: 14\">\(html)</span>"
    
    let attrStr = try! NSAttributedString(
      data: wrappedHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
      options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding],
      documentAttributes: nil)
    label.attributedText = attrStr
  }

  func renderImage(cell: CollectionTableViewCell, entry: NSDictionary) {
    let embedded = entry["_embedded"] as! NSDictionary
    if (embedded["fan_shot_image"] === NSNull()) {
      return;
    }

    let image = (embedded["fan_shot_image"] as! NSDictionary)


    let string = (image["public_filename"] as! String)

    if (string == NSNull()) {
      return;
    }

    let url = NSURL(string: string)!
    cell.bodyImageView?.af_setImageWithURL(url);
  }
  
  @IBAction func openActivityViewController(sender: UIButton) {
    let cell = tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: sender.tag, inSection: 0)) as! CollectionTableViewCell;
    let entry = entries.objectAtIndex(sender.tag);
    
    let title = cell.titleLabel.attributedText?.string;
    let image = cell.bodyImageView?.image
    let URL = entry["url"] as! String
    
    let activityViewController = UIActivityViewController(activityItems: [title!, image!, URL], applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo]
    self.navigationController?.presentViewController(activityViewController, animated: true) {
      // ...
    }
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
