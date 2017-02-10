//
//  WZTextStyle.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/10/7.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

public class WZTextStyle: Hashable {
  
  public var font: UIFont = UIFont.systemFont(ofSize: 16)
  public var lineSpace: CGFloat = 0
  public var backgroundColor: UIColor = UIColor.white
  public var textColor: UIColor = UIColor.black
  public var textAlignment: CTTextAlignment = .left
  public var isVerticalCenter = false
  
  public init() { }
  
  public var hashValue: Int {
    
    let hashComponents = [Int(lineSpace), Int(font.pointSize), textColor.hashValue, backgroundColor.hashValue, Int(textAlignment.rawValue), isVerticalCenter.hashValue]
    
    var hash = 0
    
    for (index, component) in hashComponents.enumerated() {
      
      hash ^= (component << index)
    }
    
    return hash
  }
  
  public static func ==(lhs: WZTextStyle, rhs: WZTextStyle) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
}
