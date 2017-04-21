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
import SESlideTableViewCell

class CollectTitleTableViewCell: UITableViewCell {

  @IBOutlet var titleLabel: UILabel!

}

class CollectWithImageTableViewCell: SESlideTableViewCell {

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var entryImageView: UIImageView!

}

class CollectTableViewCell: SESlideTableViewCell {

  @IBOutlet var titleLabel: UILabel!

}

class CollectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SESlideTableViewCellDelegate {

  let blue = UIColor(colorLiteralRed: 0, green: 0, blue: 238/256, alpha: 1.0)
  let purple = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
  var uid: String!
  var timestamp: String!
  var collect: NSDictionary!
  var entryTimestamps: NSMutableArray! = []
  var entries: NSMutableDictionary! = NSMutableDictionary()
  var readonly: Bool = false
  var ref: FIRDatabaseReference!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var backButton: UIBarButtonItem!
  @IBOutlet weak var openButton: UIBarButtonItem!
  @IBOutlet weak var renameButton: UIBarButtonItem!
  @IBOutlet weak var remixButton: UIBarButtonItem!
  @IBOutlet weak var addButton: UIBarButtonItem!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()

    uid = UserDefaults.standard.string(forKey: "uid")!;

    ref = FIRDatabase.database().reference()

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140

    let back = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    back.setImage(UIImage.init(named: "back"), for: UIControlState.normal)
    back.imageView?.contentMode = .scaleAspectFit
    back.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    back.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    back.addTarget(self, action: #selector(backToCollects(_:)), for:UIControlEvents.touchUpInside)
    backButton.customView = back

    let open = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    open.setImage(UIImage.init(named: "open"), for: UIControlState.normal)
    open.imageView?.contentMode = .scaleAspectFit
    open.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    open.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    open.addTarget(self, action: #selector(openCollect(_:)), for:UIControlEvents.touchUpInside)
    openButton.customView = open

    let rename = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    rename.setImage(UIImage.init(named: "rename"), for: UIControlState.normal)
    rename.imageView?.contentMode = .scaleAspectFit
    rename.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    rename.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    rename.addTarget(self, action: #selector(renameCollect(_:)), for:UIControlEvents.touchUpInside)
    renameButton.customView = rename

    let remix = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    remix.setImage(UIImage.init(named: "remix"), for: UIControlState.normal)
    remix.imageView?.contentMode = .scaleAspectFit
    remix.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    remix.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    remix.addTarget(self, action: #selector(remixTemplate(_:)), for:UIControlEvents.touchUpInside)
    remixButton.customView = remix

    let add = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    add.setImage(UIImage.init(named: "addEntry"), for: UIControlState.normal)
    add.imageView?.contentMode = .scaleAspectFit
    add.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
    add.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    add.addTarget(self, action: #selector(createEntry(_:)), for:UIControlEvents.touchUpInside)
    addButton.customView = add
  }

  override func viewWillAppear(_ animated: Bool) {
    let defaults = UserDefaults.standard
    if let collectData = defaults.data(forKey: "collect") {
      collect = NSKeyedUnarchiver.unarchiveObject(with: collectData) as? NSDictionary
      if let entriesData = defaults.data(forKey: "entries") {
        entries = (NSKeyedUnarchiver.unarchiveObject(with: entriesData) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        entryTimestamps = NSMutableArray.init(array: entries.allKeys)
      }
      tableView.reloadData()
      setReadonly()
    } else {
      getEntries();
    }
    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  func getEntries() {
    tableView.isHidden = true
    activityIndicator.startAnimating()
    ref.child("collects/\(timestamp!)").observeSingleEvent(of: .value, with: { (snapshot) in
      if snapshot.exists() {
        if let value = snapshot.value as? NSDictionary {
          self.collect = value
          if let entries = self.collect.value(forKey: "entries") as? NSDictionary {
            self.entries = NSMutableDictionary()
            for entry in entries {
              let dict = (entry.value as! NSDictionary).mutableCopy() as! NSMutableDictionary
              if let imageURL = dict.value(forKey: "image") as? String {
                let data = try! Data(contentsOf: URL(string: imageURL)!)
                let image = UIImage(data: data)
                image?.af_inflate()
                dict.setObject(image!, forKey: "image" as NSCopying)
              }
              self.entries.setObject(dict, forKey: entry.key as! NSCopying)
            }
          }
          self.entryTimestamps = NSMutableArray.init(array: self.entries.allKeys)

          self.setReadonly()

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

  func setReadonly() {
    if (collect.object(forKey: "readonly") as? NSNumber) == 1 {
      readonly = true
      addButton.isEnabled = false
      remixButton.isEnabled = false
      renameButton.isEnabled = false
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
    alert.add(AlertAction(title: "Rename", style: .normal, handler: { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      if (textField.text?.characters.count)! > 0 {
        self.changeTitle(textField.text! as NSString)
      }
    }))
    alert.visualStyle.textFieldFont = UIFont(name: "Times New Roman", size: 18)!
    alert.visualStyle.textFieldHeight = 30
    alert.visualStyle.alertNormalFont = UIFont(name: "Times New Roman", size: 18)!
    alert.visualStyle.normalTextColor = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
    alert.visualStyle.backgroundColor = UIColor.white
    alert.visualStyle.cornerRadius = 0

    alert.present()
  }

  @IBAction func openCollect(_ sender: Any) {
    if timestamp != nil, let title = collect.value(forKey: "title") {
      let url = ("https://collectable.art/\(timestamp!)/\(title)" as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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

  @IBAction func remixTemplate(_ sender: Any) {
    let templateIndex = Int(arc4random_uniform(UInt32(11))) + 1

    self.ref.child("collects/\(timestamp!)/template").setValue(templateIndex)

    let alert = AlertController(attributedTitle: NSAttributedString.init(string: "Template changed", attributes: [NSFontAttributeName: UIFont.init(name: "Times New Roman", size: 18)!, NSForegroundColorAttributeName: UIColor.black]), attributedMessage: nil, preferredStyle: .alert)
    alert.add(AlertAction(title: "Ok", style: .normal))
    alert.visualStyle.alertNormalFont = UIFont(name: "Times New Roman", size: 18)!
    alert.visualStyle.normalTextColor = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
    alert.visualStyle.backgroundColor = UIColor.white
    alert.visualStyle.cornerRadius = 0

    alert.present()
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
      let entryTimestamp = entryTimestamps[indexPath.row] as! String
      let entry = entries.value(forKey: entryTimestamp) as! NSDictionary
      var entryTitle: String;
      if let title = entry.value(forKey: "title") as? String, title.characters.count > 0 {
        entryTitle = title;
      } else {
        entryTitle = "untitled"
      }

      if let image = entry.object(forKey: "image") as? UIImage {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectWithImageTableViewCell") as! CollectWithImageTableViewCell
        cell.entryImageView.image = image
        cell.titleLabel?.text = entryTitle;
        cell.removeAllRightButtons()
        if !readonly {
          cell.delegate = self
          cell.showsRightSlideIndicator = false
          let font = UIFont.init(name: "Times New Roman", size: 18)
          cell.addRightButton(withText: "x", textColor: UIColor.white, backgroundColor: purple, font: font!)
        }

        cell.layoutIfNeeded()

        return cell;
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectTableViewCell") as! CollectTableViewCell
        cell.titleLabel?.text = entryTitle;
        cell.removeAllRightButtons()
        if !readonly {
          cell.delegate = self
          cell.showsRightSlideIndicator = false
          let font = UIFont.init(name: "Times New Roman", size: 18)
          cell.addRightButton(withText: "x", textColor: UIColor.white, backgroundColor: purple, font: font!)
        }

        cell.layoutIfNeeded()

        return cell;
      }
    }
  }

  func slideTableViewCell(_ cell: SESlideTableViewCell!, didTriggerRightButton buttonIndex: NSInteger) {
    let indexPath = tableView.indexPath(for: cell)!
    let entryTimestamp = entryTimestamps[indexPath.row] as! String

    ref.child("collects/\(timestamp!)/entries/\(entryTimestamp)").removeValue()
    entryTimestamps.removeObject(at: indexPath.row)
    entries.removeObject(forKey: entryTimestamp)

    tableView.reloadData();
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.separatorInset = UIEdgeInsets.zero
    cell.layoutMargins = UIEdgeInsets.zero
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if readonly || indexPath.section == 0 {
      return false
    }
    return true
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
    cell.contentView.backgroundColor = UIColor(colorLiteralRed: 200/256, green: 200/256, blue: 204/256, alpha: 0.1)
  }

  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
    cell.contentView.backgroundColor = UIColor.clear
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
      destination.entry = entry.mutableCopy() as! NSMutableDictionary
      destination.collectTimestamp = timestamp
      destination.timestamp = entryTimestamp
      destination.readonly = readonly

      saveCollect()
    } else if segue.identifier == "unwindToCollects" {
      let defaults = UserDefaults.standard
      defaults.removeObject(forKey: "collect")
      defaults.removeObject(forKey: "entries")
    }
  }

  func saveCollect() {
    let defaults = UserDefaults.standard
    let encodedCollect = NSKeyedArchiver.archivedData(withRootObject: collect)
    defaults.set(encodedCollect, forKey: "collect")
    let encodedEntries = NSKeyedArchiver.archivedData(withRootObject: entries)
    defaults.set(encodedEntries, forKey: "entries")
  }

  @IBAction func createEntry(_ sender: Any) {
    let entryTimestamp = "\(Int(NSDate().timeIntervalSince1970))"
    let entry: NSDictionary = ["title": ""];
    ref.child("collects/\(timestamp!)/entries/\(entryTimestamp)").setValue(entry)
    (collect.value(forKey: "entries") as? NSDictionary)?.setValue(entry, forKey: entryTimestamp)
    entries.setValue(entry, forKey: entryTimestamp)
    entryTimestamps = NSMutableArray.init(array: entries.allKeys)
    tableView.reloadData()
    performSegue(withIdentifier: "segueToEntry", sender: entryTimestamp)
  }
  
}
