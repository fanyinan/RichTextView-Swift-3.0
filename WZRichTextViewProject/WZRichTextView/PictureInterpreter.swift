//
//  PictureInterpreter.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/29.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit
import CoreText

//当连续两个表情相同时无法区分，会被视为一个run，用location来区分一下
struct PictureData {
  var pictureImageName = ""
  var pictureLocation = 0
}

class PictureInterpreter: NSObject, Interpreter {
  
  var font = UIFont.systemFont(ofSize: 15)
  var imageWidth: CGFloat = 18
  var imageHoriMargin: CGFloat = 1
  
  var runDelegateCallbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { pointer in
    
    }, getAscent: { pointer -> CGFloat in
      
      let selfInstance = unsafeBitCast(pointer, to: PictureInterpreter.self)
      return selfInstance.font.ascender
      
    }, getDescent: { pointer -> CGFloat in
      
      let selfInstance = unsafeBitCast(pointer, to: PictureInterpreter.self)
      return -selfInstance.font.descender
      
    }, getWidth: { pointer -> CGFloat in
    let selfInstance = unsafeBitCast(pointer, to: PictureInterpreter.self)
    return selfInstance.imageWidth + selfInstance.imageHoriMargin * 2
    
  })

  func interpret(with richText: NSMutableAttributedString, with keyAttributeName: String) {
    
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
      insertSpace.addAttributes(picturePlaceholderAttributes, range: NSRange(location: 0, length: 1))
      insertSpace.addAttribute(kCTForegroundColorAttributeName as String, value: UIColor.clear.cgColor, range: NSRange(location: 0, length: 1))
      
      let runDelegate = CTRunDelegateCreate(&runDelegateCallbacks, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
      insertSpace.addAttribute(kCTRunDelegateAttributeName as String, value: runDelegate!, range: NSRange(location: 0, length: insertSpace.length))
      
      let imageName = (text as NSString).substring(with: NSRange(location: range.location + 1, length: range.length - 2))
      
      insertSpace.addAttribute(keyAttributeName, value: PictureData(pictureImageName: imageName, pictureLocation: range.location), range: NSRange(location: 0, length: insertSpace.length))
      richText.insert(insertSpace, at: range.location)
      
    }
  }
  
  func draw(in context: CGContext, with runRect: CGRect, with keyAttributeValue: Any) {
    
    let runCenterYInLine = (font.ascender - font.descender - imageWidth) / 2
    
    let imagePosition = CGPoint(x: runRect.origin.x + imageHoriMargin, y: runRect.origin.y + runCenterYInLine)
    
    let pictureImageName = (keyAttributeValue as! PictureData).pictureImageName
    
    guard let cgImage = UIImage(named: "\(pictureImageName).png")?.cgImage else { return }
    context.draw(cgImage, in: CGRect(origin: imagePosition, size: CGSize(width: imageWidth, height: imageWidth)))

  }
}