//
//  HTMLInterpreter.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/10/21.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class HTMLInterpreter: NSObject, Interpreter {
  
  var isParserHerf = false

  func interpret(richText: NSMutableAttributedString, withKeyAttributeName keyAttributeName: String) {
    
    let text = richText.string
    
    let htmlText = try! NSMutableAttributedString(data: text.data(using: String.Encoding.unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
    
    richText.enumerateAttributes(in: NSRange(location: 0, length: richText.length), options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) { (attributes, range, bool) in
      
      guard range.length == richText.length else { return }
      
      var attributes = attributes
      attributes[kCTForegroundColorAttributeName as String] = nil
      htmlText.addAttributes(attributes, range: NSRange(location: 0, length: htmlText.length))
        
    }
    
    richText.setAttributedString(htmlText)
    
    guard isParserHerf else { return }
    
    let tagPattern = "<a.*?href.*?>.+?</a>"
    let hrefPattern = "(?<=href=\")(.+?)(?=\")"
    let contentPattern = "(?<=>)(.+?)(?=<)"
    
    let tagRegular = try! NSRegularExpression(pattern: tagPattern)
    let hrefRegular = try! NSRegularExpression(pattern: hrefPattern)
    let contentRegular = try! NSRegularExpression(pattern: contentPattern)

    var contentInfos: [(content: String, index: Int, href: String)] = []

    let matchs = tagRegular.matches(in: text, range: NSMakeRange(0, (text as NSString).length))
  
    for match in matchs {
    
      let tagRange = match.range
      let tag = (text as NSString).substring(with: tagRange)
      
      let contentResults = contentRegular.matches(in: tag, range: NSMakeRange(0, (tag as NSString).length))

      guard !contentResults.isEmpty else { continue }
      
      let contentRangeInTag = contentResults[0].range
      let contentRangeInText = NSRange(location: contentRangeInTag.location + tagRange.location, length: contentRangeInTag.length)
      let content = (tag as NSString).substring(with: contentRangeInTag)
      
      let hrefResults = hrefRegular.matches(in: tag, range: NSMakeRange(0, (tag as NSString).length))
      
      guard !hrefResults.isEmpty else { continue }

      let href = (tag as NSString).substring(with: hrefResults[0].range)
      
      //为了防止文本中有两个相同的字符串，且一个在标签内，一个在标签外，这里需要先找到标签内的文本在所有相同文本中的序号
      let ranges = (richText.string as NSString).ranges(of: content)
      let contentIndex = ranges.index(where: {$0.location == contentRangeInText.location && $0.length == contentRangeInText.length}) ?? 0
      
      contentInfos += [(content: content, index: contentIndex, href: href)]
      
    }
    
    for (content, index, href) in contentInfos.reversed() {
      
      //找到此序号的文本
      let range = (richText.string as NSString).ranges(of: content)[index]
      richText.insert(NSAttributedString(string: "</>"), at: range.location + range.length)
      richText.insert(NSAttributedString(string: "<\(href)>"), at: range.location)

    }
  }
}
