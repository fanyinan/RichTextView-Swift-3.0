//
//  WZRichTextCache.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/10/7.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

enum WZCacheKeyType {

  case content
  case size
  case textInfo
}

class WZRichTextCache {
  
  static var sharedCache = WZRichTextCache()
  
  private var richTextHeightCache =  NSCache<AnyObject, AnyObject>()
  private var richTextImageCache = NSCache<AnyObject, UIImage>()
  private var richTextKeyInfoCache = NSCache<AnyObject, AnyObject>()

  private init() {
    
    richTextImageCache.countLimit = 500
  }
  
  func cachedRichTextSize(withRichText richText: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withMaxWidth maxWidth: CGFloat, withSize size: CGSize) {
    
    let key = calculateKey(withKeyType: .size, withRichText: richText, withTextStyle: textStyle, withInterpreters: interpreters, withMaxWidth: maxWidth)
    richTextHeightCache.setObject(size as AnyObject, forKey: key)
  }
  
  func getRichTextSize(withRichText richText: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withMaxWidth maxWidth: CGFloat) -> CGSize? {
    
    let key = calculateKey(withKeyType: .size, withRichText: richText, withTextStyle: textStyle, withInterpreters: interpreters, withMaxWidth: maxWidth)
    return richTextHeightCache.object(forKey: key) as? CGSize
  }
  
  func cachedRichTextImage(withRichText richText: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withMaxWidth maxWidth: CGFloat, withHighlightRange highlightRange: NSRange = NSRange(location: 0, length: 0), image: UIImage) {
    
    let key = calculateKey(withKeyType: .content, withRichText: richText, withTextStyle: textStyle, withInterpreters: interpreters, withMaxWidth: maxWidth, highlightRange: highlightRange)
    richTextImageCache.setObject(image, forKey: key)
  }
  
  func getRichTextImage(withRichText richText: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withMaxWidth maxWidth: CGFloat, withHighlightRange highlightRange: NSRange = NSRange(location: 0, length: 0)) -> UIImage? {
    
    let key = calculateKey(withKeyType: .content, withRichText: richText, withTextStyle: textStyle, withInterpreters: interpreters, withMaxWidth: maxWidth, highlightRange: highlightRange)
    return richTextImageCache.object(forKey: key)
  }
  
  func cachedRichTextKeyInfo(withRichText richText: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withMaxWidth maxWidth: CGFloat, withKeyInfo keyInfo: [NSValue: WZRichTextRunInfo]) {
    
    let key = calculateKey(withKeyType: .textInfo, withRichText: richText, withTextStyle: textStyle, withInterpreters: interpreters, withMaxWidth: maxWidth)
    richTextKeyInfoCache.setObject(keyInfo as AnyObject, forKey: key)
  }
  
  func getRichTextKeyInfo(withRichText richText: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withMaxWidth maxWidth: CGFloat) -> [NSValue: WZRichTextRunInfo]? {
    
    let key = calculateKey(withKeyType: .textInfo, withRichText: richText, withTextStyle: textStyle, withInterpreters: interpreters, withMaxWidth: maxWidth)
    
    guard let rectInfo = richTextKeyInfoCache.object(forKey: key) as? [NSValue: WZRichTextRunInfo] else { return nil }
    
    for (_, runInfo) in rectInfo {
      
      if runInfo.interpreter == nil {
        
        richTextKeyInfoCache.removeObject(forKey: key)
        return nil
      }
    }
    
    return rectInfo
  }
  
  func calculateKey(withKeyType keyType: WZCacheKeyType, withRichText richText: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withMaxWidth maxWidth: CGFloat, highlightRange: NSRange = NSRange(location: 0, length: 0)) -> AnyObject {
    
    var interpreterKey = 0
    
    for (index, interpreter) in interpreters.enumerated() {
      
      let type: String = "\(type(of: interpreter))"
      
      interpreterKey ^= type.hashValue << index
      
    }
    
    let key = (richText.hashValue << 10) ^ (interpreterKey << 5) ^ textStyle.hashValue ^ Int(maxWidth * CGFloat(100)) ^ highlightRange.location
    
    return key as AnyObject
  }
  
  func removeAllCache() {
    
    richTextKeyInfoCache.removeAllObjects()
    richTextHeightCache.removeAllObjects()
    richTextKeyInfoCache.removeAllObjects()
  }
}
