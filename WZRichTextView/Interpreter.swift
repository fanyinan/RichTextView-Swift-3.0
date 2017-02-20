//
//  Interpreter.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/29.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

public protocol Interpreter: NSObjectProtocol {
  
  func interpret(with richText: NSMutableAttributedString, with textStyle: WZTextStyle, with keyAttributeName: String)
  
  func draw(in context: CGContext, with runRect: CGRect, with keyAttributeValue: Any)
  
  func didClick(with richTextView: WZRichTextView, with attributeValue: Any)
  
  func editAttributedStringOnTouchDown(with richText: NSMutableAttributedString, in ranges: [NSRange])
}

extension Interpreter {
  
  public func draw(in context: CGContext, with runRect: CGRect, with keyAttributeValue: Any){}

  public func didClick(with richTextView: WZRichTextView, with attributeValue: Any){}

  public func editAttributedStringOnTouchDown(with richText: NSMutableAttributedString, in ranges: [NSRange]){}
  
}
