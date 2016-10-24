//
//  NSRange+extension.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 2016/10/24.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

extension NSString {
  
  func ranges(of subString: String) -> [NSRange] {
    
    var rangeList: [NSRange] = []
    
    var searchRange = NSRange(location: 0, length: length)
    
    while searchRange.length >= 0 {
      
      let range = self.range(of: subString, range: searchRange, locale: nil)
      
      guard range.length != 0 else {
        return rangeList
      }
      
      rangeList += [range]
      
      searchRange = NSRange(location: range.location + range.length, length: length - (range.location + range.length))
      
    }
    
    return rangeList
  }
}
