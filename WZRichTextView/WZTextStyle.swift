//
//  WZTextStyle.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/10/7.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class WZTextStyle: Hashable {
  
  var font: UIFont = UIFont.systemFont(ofSize: 16)
  var lineSpace: CGFloat = 0
  var backgroundColor: UIColor = UIColor.white
  var textColor: UIColor = UIColor.black
  var textAlignment: CTTextAlignment = .left
  var isVerticalCenter = false
  
  var hashValue: Int {
    
    let hashComponents = [Int(lineSpace), Int(font.pointSize), textColor.hashValue, backgroundColor.hashValue, Int(textAlignment.rawValue), isVerticalCenter.hashValue]
    
    var hash = 0
    
    for (index, component) in hashComponents.enumerated() {
      
      hash ^= (component << index)
    }
    
    return hash
  }
  
  static func ==(lhs: WZTextStyle, rhs: WZTextStyle) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
}
