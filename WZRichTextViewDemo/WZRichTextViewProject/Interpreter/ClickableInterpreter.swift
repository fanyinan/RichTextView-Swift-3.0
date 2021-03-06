//
//  ClickableInterpreter.swift
//  WZRichTextViewProject
//
//  Created by fanyinan on 16/9/30.
//  Copyright © 2016年 fanyinan. All rights reserved.
//

import UIKit

public protocol ClickableInterpreterDelegate: NSObjectProtocol {
  func didClick(with richTextView: WZRichTextView, with key: String)
}

public class ClickableInterpreter: NSObject, Interpreter {
  
  public var keyTextNormalForegroundColor: UIColor?
  public var keyTextSelectedForegroundColor: UIColor = UIColor.blue
  public var keyTextSelectedBackgroundColor: UIColor = UIColor.clear
  
  public weak var delegate: ClickableInterpreterDelegate?
  
  public func interpret(with richText: NSMutableAttributedString, with textStyle: WZTextStyle, with keyAttributeName: String) {
    
    let text = richText.string
    let keyTextPattern = "(<(.+?)>)(.+?)(<(/.*?)>)"
    let keyTextRegular = try! NSRegularExpression(pattern: keyTextPattern)
    
    let results = keyTextRegular.matches(in: text, range: NSRange(location: 0, length: (text as NSString).length))
    
    for result in results.reversed() {
      
      let startTagRange = result.range(at: 1)
      let startTagTextRange = result.range(at: 2)
      let keyWordRange = result.range(at: 3)
      let endTagRange = result.range(at: 4)
      let endTagTextRange = result.range(at: 5)

      let keyWord = (text as NSString).substring(with: keyWordRange)
      let startTag = (text as NSString).substring(with: startTagTextRange)
      let endTag = (text as NSString).substring(with: endTagTextRange)
      
      guard "/\(startTag)" == endTag || endTag == "/" else { continue }
      
      richText.deleteCharacters(in: endTagRange)
      richText.deleteCharacters(in: startTagRange)

      richText.addAttribute(NSAttributedStringKey(rawValue: keyAttributeName), value: startTag, range: NSRange(location: startTagRange.location, length: keyWord.count))
      
      if let keyTextNormalForegroundColor = keyTextNormalForegroundColor {
        
        richText.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String), value: keyTextNormalForegroundColor.cgColor, range: NSRange(location: startTagRange.location, length: keyWord.count))

      }
    }
  }
  
  public func didClick(with richTextView: WZRichTextView, with attributeValue: Any) {
    delegate?.didClick(with: richTextView, with: attributeValue as! String)
  }
  
  public func editAttributedStringOnTouchDown(with richText: NSMutableAttributedString, in ranges: [NSRange]) {
    for range in ranges {
      
      richText.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String), value: keyTextSelectedForegroundColor.cgColor, range: range)
      richText.addAttribute(NSAttributedStringKey.backgroundColor, value: keyTextSelectedBackgroundColor, range: range)
      
    }
  }
}
