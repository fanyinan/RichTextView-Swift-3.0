//
//  HTMLInterpreter.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/10/21.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class HTMLInterpreter: Interpreter {
  
  var isParserHerf = false
  
  func interpret(richText: NSMutableAttributedString, withKeyAttributeName keyAttributeName: String) {
    
    let text = richText.string
    
    let htmlText = try! NSMutableAttributedString(data: text.data(using: String.Encoding.unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
    
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
      
      let ranges = (richText.string as NSString).ranges(of: content)
      let contentIndex = ranges.index(where: {$0.location == contentRangeInText.location && $0.length == contentRangeInText.length}) ?? 0
      
      contentInfos += [(content: content, index: contentIndex, href: href)]
      
    }
    
    for (content, index, href) in contentInfos.reversed() {
      
      let range = (richText.string as NSString).ranges(of: content)[index]
      richText.insert(NSAttributedString(string: "</>"), at: range.location + range.length)
      richText.insert(NSAttributedString(string: "<\(href)>"), at: range.location)

    }
  }
}
