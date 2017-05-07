//
//  CollectsButton.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 5/7/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit

class CollectsButton: UIButton {

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }

  init(image: Any!, target: Any!, action: Selector) {
    super.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    if image as? String != nil {
      self.setImage(UIImage(named: image as! String), for: .normal)
    } else {
      self.setImage(image as? UIImage, for: .normal)
    }
    self.imageView?.contentMode = .scaleAspectFit
    self.contentHorizontalAlignment = .fill
    self.contentVerticalAlignment = .fill
    self.addTarget(target, action: action, for: .touchUpInside)
  }

}
