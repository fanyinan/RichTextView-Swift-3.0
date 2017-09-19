//
//  PictureInterpreter.swift
//  WZRichTextViewProject
//
//  Created by fanyinan on 16/9/29.
//  Copyright © 2016年 fanyinan. All rights reserved.
//

import UIKit
import CoreText

class PictureRunInfo {
  
  var ascender: CGFloat
  var descender: CGFloat
  var width: CGFloat
  
  init(ascender: CGFloat, descender: CGFloat, width: CGFloat) {
    self.ascender = ascender
    self.descender = descender
    self.width = width
  }
}

public protocol PictureInterpreterDelegate: NSObjectProtocol {
  func pictureInterpreter(pictureInterpreter: PictureInterpreter, pictureSizeAt index: Int, with pictureMaxSize: CGSize) -> CGSize
}

public class PictureInterpreter: NSObject, Interpreter {
  
  public weak var delegate: PictureInterpreterDelegate?
  public var imageHoriMargin: CGFloat = 1
  
  var pictureRunInfos: [PictureRunInfo] = []

  var runDelegateCallbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { pointer in
    
    }, getAscent: { pointer -> CGFloat in
      
      let pictureRunInfo = unsafeBitCast(pointer, to: PictureRunInfo.self)
      return pictureRunInfo.ascender
      
    }, getDescent: { pointer -> CGFloat in
      
      let pictureRunInfo = unsafeBitCast(pointer, to: PictureRunInfo.self)
      return pictureRunInfo.descender
      
    }, getWidth: { pointer -> CGFloat in
      
    let pictureRunInfo = unsafeBitCast(pointer, to: PictureRunInfo.self)
    return pictureRunInfo.width
    
  })

  public func interpret(with richText: NSMutableAttributedString, with textStyle: WZTextStyle, with keyAttributeName: String) {
    
    let text = richText.string
    
    let pattern = "\\[.+?\\]"
    
    let regular = try! NSRegularExpression(pattern: pattern)
    
    let results = regular.matches(in: text, range: NSRange(location: 0, length: (text as NSString).length))
    
    for result in results.reversed() {
      
      let range = result.range
      
      let picturePlaceholderAttributes = richText.attributes(at: range.location, effectiveRange: nil)
      
      richText.deleteCharacters(in: range)
      
      //CTFramesetterSuggestFrameSizeWithConstraints会莫名其妙的忽略最后一个空格，所以这里用一个透明的字符代替
      let insertSpace = NSMutableAttributedString(string: "*")
      //将空白格的attributes设置为之前字符串的attributes
      insertSpace.addAttributes(picturePlaceholderAttributes, range: NSRange(location: 0, length: insertSpace.length))
      insertSpace.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value: UIColor.clear.cgColor, range: NSRange(location: 0, length: 1))
      
      let imageMaxSize = CGSize(width: textStyle.font.lineHeight, height: textStyle.font.lineHeight)
      var imageSize = delegate?.pictureInterpreter(pictureInterpreter: self, pictureSizeAt: range.location, with: imageMaxSize) ?? imageMaxSize
      imageSize = CGSize(width: min(imageSize.width, imageMaxSize.width), height: min(imageSize.height, imageMaxSize.height))
      let extraHeight = (imageSize.height - textStyle.font.lineHeight) / 2
      let pictureRunInfo = PictureRunInfo(ascender: textStyle.font.ascender + extraHeight, descender: -textStyle.font.descender + extraHeight, width: imageSize.width + imageHoriMargin * 2)
      pictureRunInfos += [pictureRunInfo]
      let runDelegate = CTRunDelegateCreate(&runDelegateCallbacks, unsafeBitCast(pictureRunInfo, to: UnsafeMutableRawPointer.self))
      insertSpace.addAttribute(NSAttributedStringKey(rawValue: kCTRunDelegateAttributeName as String as String), value: runDelegate!, range: NSRange(location: 0, length: insertSpace.length))
      
      let imageName = (text as NSString).substring(with: NSRange(location: range.location + 1, length: range.length - 2))
      
      insertSpace.addAttribute(NSAttributedStringKey(rawValue: keyAttributeName), value: imageName, range: NSRange(location: 0, length: insertSpace.length))
      richText.insert(insertSpace, at: range.location)
      
    }
  }
  
  public func draw(in context: CGContext, with runRect: CGRect, with keyAttributeValue: Any) {
    
    let imagePosition = CGPoint(x: runRect.origin.x + imageHoriMargin, y: runRect.origin.y)
    
    let pictureImageName = keyAttributeValue as! String
    
    guard let cgImage = UIImage(named: "\(pictureImageName).png")?.cgImage else { return }
    context.draw(cgImage, in: CGRect(origin: imagePosition, size: CGSize(width: runRect.width - imageHoriMargin * 2, height: runRect.height)))

  }
  
  public func didClick(with richTextView: WZRichTextView, with attributeValue: Any) {
    print(attributeValue)
  }
}
