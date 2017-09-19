//
//  WZRichTextCache.swift
//  WZRichTextViewProject
//
//  Created by fanyinan on 16/10/7.
//  Copyright © 2016年 fanyinan. All rights reserved.
//

import UIKit

class WZRichTextCache {
  
  static var sharedCache = WZRichTextCache()
  
  private var richTextHeightCache =  NSCache<AnyObject, AnyObject>()
  private var richTextImageCache = NSCache<AnyObject, UIImage>()
  private var richTextKeyInfoCache = NSCache<AnyObject, AnyObject>()

  private init() {
    
    richTextImageCache.countLimit = 500
  }
  
  func cachedRichTextSize(with richText: String, with textStyle: WZTextStyle, with interpreters: [Interpreter], with maxWidth: CGFloat, with size: CGSize) {
    
    let key = calculateKey(with: richText, with: textStyle, with: interpreters, with: maxWidth)
    richTextHeightCache.setObject(size as AnyObject, forKey: key)
  }
  
  func getRichTextSize(with richText: String, with textStyle: WZTextStyle, with interpreters: [Interpreter], with maxWidth: CGFloat) -> CGSize? {
    
    let key = calculateKey(with: richText, with: textStyle, with: interpreters, with: maxWidth)
    return richTextHeightCache.object(forKey: key) as? CGSize
  }
  
  func cachedRichTextImage(with richText: String, with textStyle: WZTextStyle, with interpreters: [Interpreter], with maxWidth: CGFloat, with highlightRange: NSRange = NSRange(location: 0, length: 0), image: UIImage) {
    
    let key = calculateKey(with: richText, with: textStyle, with: interpreters, with: maxWidth, with: highlightRange)
    richTextImageCache.setObject(image, forKey: key)
  }
  
  func getRichTextImage(with richText: String, with textStyle: WZTextStyle, with interpreters: [Interpreter], with maxWidth: CGFloat, with highlightRange: NSRange = NSRange(location: 0, length: 0)) -> UIImage? {
    
    let key = calculateKey(with: richText, with: textStyle, with: interpreters, with: maxWidth, with: highlightRange)
    return richTextImageCache.object(forKey: key)
  }
  
  func cachedRichTextKeyInfo(with richText: String, with textStyle: WZTextStyle, with interpreters: [Interpreter], with maxWidth: CGFloat, with keyInfo: [NSValue: WZRichTextRunInfo]) {
    
    let key = calculateKey(with: richText, with: textStyle, with: interpreters, with: maxWidth)
    richTextKeyInfoCache.setObject(keyInfo as AnyObject, forKey: key)
  }
  
  func getRichTextKeyInfo(with richText: String, with textStyle: WZTextStyle, with interpreters: [Interpreter], with maxWidth: CGFloat) -> [NSValue: WZRichTextRunInfo]? {
    
    let key = calculateKey(with: richText, with: textStyle, with: interpreters, with: maxWidth)
    
    guard let rectInfo = richTextKeyInfoCache.object(forKey: key) as? [NSValue: WZRichTextRunInfo] else { return nil }
    
    return rectInfo
  }
  
  func calculateKey(with richText: String, with textStyle: WZTextStyle, with interpreters: [Interpreter], with maxWidth: CGFloat, with highlightRange: NSRange = NSRange(location: 0, length: 0)) -> AnyObject {
    
    var interpreterKey = 0
    
    //确定interpreter的顺序
    for (index, interpreter) in interpreters.enumerated() {
      
      let type: String = "\(Swift.type(of: interpreter))"
      
      interpreterKey ^= type.hashValue << index
      
    }
    
    let key = richText.hashValue ^ (interpreterKey ^ textStyle.hashValue ^ Int(maxWidth * CGFloat(100)) ^ highlightRange.location) << 10
    
    return key as AnyObject
  }
  
  func removeAllCache() {
    
    richTextKeyInfoCache.removeAllObjects()
    richTextHeightCache.removeAllObjects()
    richTextKeyInfoCache.removeAllObjects()
  }
}
