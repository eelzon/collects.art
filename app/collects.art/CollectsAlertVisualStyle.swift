//
//  CollectsAlertVisualStyle.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 5/7/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit
import SDCAlertView

class CollectsAlertVisualStyle: AlertVisualStyle {

  let font = UIFont(name: "Times New Roman", size: 18)!

  override init(alertStyle: AlertControllerStyle) {
    super.init(alertStyle: alertStyle)

    alertNormalFont = font
    actionSheetPreferredFont = font
    actionSheetNormalFont = font
    textFieldFont = font
    textFieldHeight = 30
    normalTextColor = UIColor.linkPurple
    backgroundColor = UIColor.white
    cornerRadius = 0
  }

}
