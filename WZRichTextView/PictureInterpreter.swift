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

protocol PictureInterpreterDelegate: NSObjectProtocol {
  func pictureInterpreter(pictureInterpreter: PictureInterpreter, pictureSizeAt index: Int) -> CGSize
}

class PictureInterpreter: NSObject, Interpreter {
  
  weak var delegate: PictureInterpreterDelegate?
  var font = UIFont.systemFont(ofSize: 15)
  var imageHoriMargin: CGFloat = 1
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
      
      let imageSize = delegate?.pictureInterpreter(pictureInterpreter: self, pictureSizeAt: range.location) ?? CGSize(width: font.lineHeight, height: font.lineHeight)
      let extraHeight = (imageSize.height - font.lineHeight) / 2
      let pictureRunInfo = PictureRunInfo(ascender: font.ascender + extraHeight, descender: -font.descender + extraHeight, width: imageSize.width + imageHoriMargin * 2)
      pictureRunInfos += [pictureRunInfo]
      let runDelegate = CTRunDelegateCreate(&runDelegateCallbacks, unsafeBitCast(pictureRunInfo, to: UnsafeMutableRawPointer.self))
      insertSpace.addAttribute(kCTRunDelegateAttributeName as String, value: runDelegate!, range: NSRange(location: 0, length: insertSpace.length))
      
      let imageName = (text as NSString).substring(with: NSRange(location: range.location + 1, length: range.length - 2))
      
      insertSpace.addAttribute(keyAttributeName, value: PictureData(pictureImageName: imageName, pictureLocation: range.location), range: NSRange(location: 0, length: insertSpace.length))
      richText.insert(insertSpace, at: range.location)
      
    }
  }
  
  func draw(in context: CGContext, with runRect: CGRect, with keyAttributeValue: Any) {
    
    let imagePosition = CGPoint(x: runRect.origin.x + imageHoriMargin, y: runRect.origin.y)
    
    let pictureImageName = (keyAttributeValue as! PictureData).pictureImageName
    
    guard let cgImage = UIImage(named: "\(pictureImageName).png")?.cgImage else { return }
    context.draw(cgImage, in: CGRect(origin: imagePosition, size: CGSize(width: runRect.width - imageHoriMargin * 2, height: runRect.height)))

  }
}
