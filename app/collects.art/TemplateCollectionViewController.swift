//
//  TemplateCollectionViewController.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/24/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit

class TemplateCollectionViewCell: UICollectionViewCell {

  @IBOutlet var templateView: UIImageView!

}

protocol TemplateDelegate {
  func saveTemplate(index: Int)
}

class TemplateCollectionViewController: UICollectionViewController {

  var templateIndex: Int!
  var timestamp: String!
  var templates: NSArray!
  var delegate: TemplateDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()

    templates = UserDefaults.standard.object(forKey: "templates") as! NSArray
  }

  override func viewWillAppear(_ animated: Bool) {
    self.view?.superview?.layer.cornerRadius = 0
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return templates.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TemplateCollectionViewCell", for: indexPath) as! TemplateCollectionViewCell

    let template = templates.object(at: indexPath.row) as! NSDictionary
    let url = template.value(forKey: "url") as! String
    cell.templateView.af_setImage(withURL: URL.init(string: url)!)

    cell.layer.borderWidth = 1.0
    cell.layer.cornerRadius = 0
    if templateIndex == template.value(forKey: "index") as! Int {
      cell.layer.borderColor = UIColor.gray.cgColor
    } else {
      cell.layer.borderColor = UIColor.clear.cgColor
    }

    return cell
  }

  // MARK: UICollectionViewDelegate

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    templateIndex = (templates.object(at: indexPath.row) as! NSDictionary).value(forKey: "index") as! Int
    delegate.saveTemplate(index: templateIndex)
  }

}
