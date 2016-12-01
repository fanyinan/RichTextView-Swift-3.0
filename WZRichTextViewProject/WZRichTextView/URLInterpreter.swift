//
//  URLInterpreter.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/10/2.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class URLInterpreter: NSObject, Interpreter {
  
  var keyTextNormalBackgroundColor: UIColor = UIColor.blue
  var keyTextSelectedBackgroundColor: UIColor = UIColor.green

  func interpret(with richText: NSMutableAttributedString, with keyAttributeName: String) {
    
    let text = richText.string
    let pattern = "(ht|f)tp(s?)://[0-9a-zA-Z]([-.\\w]*[0-9a-zA-Z])*(:(0-9)*)*(/?)([a-zA-Z0-9-.?,'/\\+&amp;%$#_]*)?"
    let regualr = try! NSRegularExpression(pattern: pattern)
    let results = regualr.matches(in: text, range: NSRange(location: 0, length: (text as NSString).length))
    
    for result in results {
      
      let range = result.range
      
      let url = (text as NSString).substring(with: range)
      
      let attributeRange = NSRange(location: range.location, length: url.characters.count)
      richText.addAttribute(keyAttributeName, value: url, range: attributeRange)
      richText.addAttribute(kCTForegroundColorAttributeName as String, value: keyTextNormalBackgroundColor.cgColor, range: attributeRange)
      
    }
  }
  
  func editAttributedStringOnTouchDown(richText: NSMutableAttributedString, in ranges: [NSRange]) {
    
    for range in ranges {
      
      richText.addAttribute(NSBackgroundColorAttributeName as String, value: keyTextSelectedBackgroundColor.cgColor, range: range)
      
    }
  }
  
  func didClick(with richTextView: WZRichTextView, withA attributeValue: Any) {
    
    print(attributeValue)
    
  }
}
