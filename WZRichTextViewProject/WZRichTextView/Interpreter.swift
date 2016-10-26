//
//  Interpreter.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/29.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

protocol Interpreter: NSObjectProtocol {
  
  func interpret(richText: NSMutableAttributedString, withKeyAttributeName keyAttributeName: String)
  
  func draw(inContext context: CGContext, withRunRect runRect: CGRect, withKeyAttributeValue keyAttributeValue: Any)
  
  func didClick(withRichText richText: WZRichTextView, withAttributeValue attributeValue: Any)
  
  func editAttributedStringOnTouchDown(richText: NSMutableAttributedString, inRanges ranges: [NSRange])
}

extension Interpreter {
  
  func draw(inContext context: CGContext, withRunRect runRect: CGRect, withKeyAttributeValue keyAttributeValue: Any) {}

  func didClick(withRichText richText: WZRichTextView, withAttributeValue attributeValue: Any) {}
  
  func editAttributedStringOnTouchDown(richText: NSMutableAttributedString, inRanges ranges: [NSRange]) {}
  
}
