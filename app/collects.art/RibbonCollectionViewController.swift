//
//  RibbonCollectionViewController.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/16/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit

class RibbonCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet var ribbonView: UIImageView!
  
}

class RibbonCollectionViewController: UICollectionViewController {

  var ribbon: String!
  var ribbons: NSArray!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    ribbons = UserDefaults.standard.object(forKey: "ribbons") as! NSArray
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
    return ribbons.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RibbonCollectionViewCell", for: indexPath) as! RibbonCollectionViewCell

    let url = ribbons.object(at: indexPath.row) as! String
    cell.ribbonView.af_setImage(withURL: URL.init(string: url)!)

    if url == ribbon {
      cell.layer.borderColor = UIColor.black.cgColor
      cell.layer.borderWidth = 1.0
      cell.layer.cornerRadius = 0
    }
    
    return cell
  }

  // MARK: UICollectionViewDelegate

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    ribbon = ribbons.object(at: indexPath.row) as! String
    UserDefaults.standard.set(ribbon, forKey: "ribbon")
  }

}
