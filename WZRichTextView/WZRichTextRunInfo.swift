//
//  WZRichTextRunInfo.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 2016/10/26.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

class WZRichTextRunInfo: NSObject {
  
  var range: NSRange
  var attributeValue: Any
  var classType: AnyClass
  
  init(range: NSRange, attributeValue: Any, classType: AnyClass) {
    self.range = range
    self.attributeValue = attributeValue
    self.classType = classType
    super.init()
  }
}
