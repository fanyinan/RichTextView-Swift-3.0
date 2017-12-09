//
//  WZTextStyle.swift
//  WZRichTextViewProject
//
//  Created by fanyinan on 16/10/7.
//  Copyright © 2016年 fanyinan. All rights reserved.
//

import UIKit

public class WZTextStyle: Hashable {
  
  public var font: UIFont = UIFont.systemFont(ofSize: 20)
  public var lineSpace: CGFloat = 0
  public var backgroundColor: UIColor = UIColor.white
  public var textColor: UIColor = UIColor.black
  public var textAlignment: CTTextAlignment = .left
  public var lineBreakMode: CTLineBreakMode = .byCharWrapping
  public var isVerticalCenter = false
  public var isShowRunRect = false
  
  var attributes: [NSAttributedStringKey: (Any, NSRange)] = [:]
  
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
  
  public func addAttribute(_ name: NSAttributedStringKey, value: Any, range: NSRange) {
    
    switch name {
    case NSAttributedStringKey.foregroundColor:
      if let color = value as? UIColor {
        attributes[NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String)] = (color.cgColor, range)
      }
    case NSAttributedStringKey.font:
      if let font = value as? UIFont {
        let fontRef: CTFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        attributes[NSAttributedStringKey(rawValue: kCTFontAttributeName as String)] = (fontRef, range)
      }
    default:
      attributes[name] = (value, range)
    }
  }
}
