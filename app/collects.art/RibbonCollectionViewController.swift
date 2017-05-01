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

protocol RibbonDelegate {
  func setUserRibbon()
}


class RibbonCollectionViewController: UICollectionViewController {

  var ribbon: String!
  var ribbons: NSArray!
  var delegate: RibbonDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()

    ribbon = UserDefaults.standard.object(forKey: "ribbon") as! String
    ribbons = UserDefaults.standard.object(forKey: "ribbons") as! NSArray
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
    return ribbons.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RibbonCollectionViewCell", for: indexPath) as! RibbonCollectionViewCell

    let url = ribbons.object(at: indexPath.row) as! String
    cell.ribbonView.af_setImage(withURL: URL.init(string: url)!)

    cell.layer.borderWidth = 1.0
    cell.layer.cornerRadius = 0
    if url == ribbon {
      cell.layer.borderColor = UIColor(colorLiteralRed: 200/256, green: 200/256, blue: 204/256, alpha: 1.0).cgColor
    } else {
      cell.layer.borderColor = UIColor.clear.cgColor
    }

    return cell
  }

  // MARK: UICollectionViewDelegate

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    ribbon = ribbons.object(at: indexPath.row) as! String
    UserDefaults.standard.set(ribbon, forKey: "ribbon")
    delegate.setUserRibbon()
  }

}
