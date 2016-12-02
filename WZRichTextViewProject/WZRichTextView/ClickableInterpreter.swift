//
//  ClickableInterpreter.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/30.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

protocol ClickableInterpreterDelegate: NSObjectProtocol {
  func didClick(with richTextView: WZRichTextView, with key: String)
}

class ClickableInterpreter: NSObject, Interpreter {
  
  var keyTextNormalForegroundColor: UIColor? = UIColor.blue
  var keyTextSelectedForegroundColor: UIColor = UIColor.blue
  var keyTextSelectedBackgroundColor: UIColor = UIColor.clear
  
  weak var delegate: ClickableInterpreterDelegate?
  
  func interpret(with richText: NSMutableAttributedString, with keyAttributeName: String) {
    
    let text = richText.string
    let keyTextPattern = "<.+?>.+?</.*?>"
    let keyTextRegular = try! NSRegularExpression(pattern: keyTextPattern)
    
    let keyWordPattern = "[^<>]+"
    let keyWordRegular = try! NSRegularExpression(pattern: keyWordPattern)
    
    let results = keyTextRegular.matches(in: text, range: NSRange(location: 0, length: (text as NSString).length))
    
    for result in results.reversed() {
      
      let range = result.range
      
      let keyString = (text as NSString).substring(with: range)
      
      let keyWordResults = keyWordRegular.matches(in: keyString, range: NSRange(location: 0, length: (keyString as NSString).length))
      
      guard keyWordResults.count == 3 else { continue }
      
      var keyWords: [String] = []
      
      for keyWordResult in keyWordResults {
      
        let range = keyWordResult.range
        
        let keyString = (keyString as NSString).substring(with: range)
        
        keyWords += [keyString]
        
      }
      
      guard "/\(keyWords[0])" == keyWords[2] || keyWords[2] == "/" else { continue }
      
      let startTag = keyWords[0]
      let content = keyWords[1]
      let endTag = keyWords[2]

      let markLength = NSString(string: "<>").length
      let endTagLocation = range.location + startTag.characters.count + content.characters.count + markLength
      let endTagLength = endTag.characters.count + markLength
      richText.deleteCharacters(in: NSRange(location: endTagLocation, length: endTagLength))

      let startTagLocation = range.location
      let startTagLength = startTag.characters.count + markLength
      richText.deleteCharacters(in: NSRange(location: startTagLocation, length: startTagLength))

      richText.addAttribute(keyAttributeName, value: startTag, range: NSRange(location: range.location, length: content.characters.count))
      
      if let keyTextNormalForegroundColor = keyTextNormalForegroundColor {
        richText.addAttribute(kCTForegroundColorAttributeName as String, value: keyTextNormalForegroundColor.cgColor, range: NSRange(location: range.location, length: content.characters.count))

      }
    }
  }
  
  func didClick(with richTextView: WZRichTextView, with attributeValue: Any) {
    delegate?.didClick(with: richTextView, with: attributeValue as! String)
  }
  
  func editAttributedStringOnTouchDown(richText: NSMutableAttributedString, in ranges: [NSRange]) {
    
    for range in ranges {
      
      richText.addAttribute(kCTForegroundColorAttributeName as String, value: keyTextSelectedForegroundColor.cgColor, range: range)
      richText.addAttribute(NSBackgroundColorAttributeName as String, value: keyTextSelectedBackgroundColor.cgColor, range: range)

    }
  }

}
