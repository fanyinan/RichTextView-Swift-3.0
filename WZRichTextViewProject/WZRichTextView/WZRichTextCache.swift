//
//  WZRichTextCache.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/10/7.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class WZRichTextCache {
  
  static var sharedCache = WZRichTextCache()
  
  var richTextHeightCache =  NSCache<AnyObject, AnyObject>()
  var richTextImageCache = NSCache<AnyObject, UIImage>()
  var richTextKeyInfoCache = NSCache<AnyObject, AnyObject>()

  private init() {
    
    richTextImageCache.countLimit = 500
  }
  
  func cachedRichTextSize(withRichText richText: String, withTextStyle textStyle: WZTextStyle,  withMaxWidth maxWidth: CGFloat, withSize size: CGSize) {
    
    let key = calculateKey(withRichText: richText, withTextStyle: textStyle, withMaxWidth: maxWidth)
    richTextHeightCache.setObject(size as AnyObject, forKey: key)
  }
  
  func getRichTextSize(withRichText richText: String, withTextStyle textStyle: WZTextStyle,  withMaxWidth maxWidth: CGFloat) -> CGSize? {
    
    let key = calculateKey(withRichText: richText, withTextStyle: textStyle, withMaxWidth: maxWidth)
    return richTextHeightCache.object(forKey: key) as? CGSize
  }
  
  func cachedRichTextImage(withRichText richText: String, withTextStyle textStyle: WZTextStyle,  withMaxWidth maxWidth: CGFloat, withHighlightRange highlightRange: NSRange = NSRange(location: 0, length: 0), image: UIImage) {
    
    let key = calculateKey(withRichText: richText, withTextStyle: textStyle, withMaxWidth: maxWidth, highlightRange: highlightRange)
    richTextImageCache.setObject(image, forKey: key)
  }
  
  func getRichTextImage(withRichText richText: String, withTextStyle textStyle: WZTextStyle,  withMaxWidth maxWidth: CGFloat, withHighlightRange highlightRange: NSRange = NSRange(location: 0, length: 0)) -> UIImage? {
    
    let key = calculateKey(withRichText: richText, withTextStyle: textStyle, withMaxWidth: maxWidth, highlightRange: highlightRange)
    return richTextImageCache.object(forKey: key)
  }
  
  func cachedRichTextKeyInfo(withRichText richText: String, withTextStyle textStyle: WZTextStyle,  withMaxWidth maxWidth: CGFloat, withKeyInfo keyInfo: [NSValue: (range: NSRange, attributeValue: Any, interpreter: Interpreter)]) {
    
    let key = calculateKey(withRichText: richText, withTextStyle: textStyle, withMaxWidth: maxWidth)
    richTextKeyInfoCache.setObject(keyInfo as AnyObject, forKey: key)
  }
  
  func getRichTextKeyInfo(withRichText richText: String, withTextStyle textStyle: WZTextStyle, withMaxWidth maxWidth: CGFloat) -> [NSValue: (range: NSRange, attributeValue: Any, interpreter: Interpreter)]? {
    
    let key = calculateKey(withRichText: richText, withTextStyle: textStyle, withMaxWidth: maxWidth)
    return richTextKeyInfoCache.object(forKey: key) as? [NSValue: (range: NSRange, attributeValue: Any, interpreter: Interpreter)]
  }
  
  func calculateKey(withRichText richText: String, withTextStyle textStyle: WZTextStyle,  withMaxWidth maxWidth: CGFloat, highlightRange: NSRange = NSRange(location: 0, length: 0)) -> AnyObject {
    
    let key = richText.hashValue ^ textStyle.hashValue ^ Int(maxWidth * CGFloat(100)) ^ highlightRange.location
    return key as AnyObject
  }
}
