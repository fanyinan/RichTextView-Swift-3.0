//
//  WZRichTextView.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/23.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class WZRichTextView: UIView {
  
  private var rectDict: [NSValue: (range: NSRange, attributeValue: Any, interpreter: Interpreter)] = [:]
  private var currentClickRectValue: NSValue?
  private var clickable = true
  
  var interpreters: [Interpreter] = []
  var textStyle = WZTextStyle()
  var shouldCached = false
  
  static let keyAttributeName = "keyAttributeName"
  
  var text: String = "" {
    didSet{
      
      rectDict.removeAll()
      setNeedsLayout()
      
    }
  }
  
  override func layoutSubviews() {
    drawContent()
  }
  
  func drawContent(highlightRange: NSRange = NSRange(location: 0, length: 0)) {
    
    //非高亮的绘制首先将layer.contents设为nil
    if highlightRange.location == 0 && highlightRange.length == 0 {
      layer.contents = nil
    }
    
    let text = self.text
    let textStyle = self.textStyle
    let size = self.frame.size
    let rectDict = self.rectDict
    let currentClickRectValue = self.currentClickRectValue
    
    if shouldCached {
      
      if let image = WZRichTextCache.sharedCache.getRichTextImage(withRichText: text, withTextStyle: textStyle, withMaxWidth: size.width, withHighlightRange: highlightRange), let keyInfo = WZRichTextCache.sharedCache.getRichTextKeyInfo(withRichText: text, withTextStyle: textStyle, withMaxWidth: frame.width) {
        
        layer.contents = image.cgImage
        self.rectDict = keyInfo
        return
      }
      
    }
    
    DispatchQueue.global().async {
      
      self.clickable = false

      let (image, rectDict) = WZRichTextView.drawImage(withRichText: text, withTextStyle: textStyle, withInterpreters: self.interpreters, withSize: size, withKeyInfoDict: rectDict, withCurrentClickRectValue: currentClickRectValue)

      self.clickable = true
      
      guard let _image = image else { return }
      
      if self.shouldCached {
        
        WZRichTextCache.sharedCache.cachedRichTextImage(withRichText: text, withTextStyle: textStyle, withMaxWidth: size.width, withHighlightRange: highlightRange, image: _image)
        WZRichTextCache.sharedCache.cachedRichTextKeyInfo(withRichText: text, withTextStyle: textStyle, withMaxWidth: size.width, withKeyInfo: rectDict)
        
      }
      
      //当第一次点击后马上抬起，由于缓存的关系，会导致点击时的image在touchend之后绘制完成，从而抬起后会显示touchdown的image
      if self.layer.contents != nil && self.currentClickRectValue == nil {
        return
      }
      
      let key = WZRichTextCache.sharedCache.calculateKey(withRichText: text, withTextStyle: textStyle, withMaxWidth: size.width, highlightRange: highlightRange) as! Int
      
      DispatchQueue.main.async {
        
        //防止图片错位
        guard key == (WZRichTextCache.sharedCache.calculateKey(withRichText: self.text, withTextStyle: self.textStyle, withMaxWidth: self.frame.width, highlightRange:highlightRange) as! Int) else { return }

        self.layer.contents = image?.cgImage
        self.rectDict = rectDict
        
      }
    }
  }
  
  class func preCreateRichText(withRichText text: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withSize size: CGSize) {
    
    if WZRichTextCache.sharedCache.getRichTextImage(withRichText: text, withTextStyle: textStyle, withMaxWidth: size.width) != nil && WZRichTextCache.sharedCache.getRichTextKeyInfo(withRichText: text, withTextStyle: textStyle, withMaxWidth: size.width) != nil {
      return
    }
    
    let (image, rectDict) = self.drawImage(withRichText: text, withTextStyle: textStyle, withInterpreters: interpreters, withSize: size,    withKeyInfoDict: [:], withCurrentClickRectValue: nil)
    
    guard let _image = image else { return }
    WZRichTextCache.sharedCache.cachedRichTextImage(withRichText: text, withTextStyle: textStyle, withMaxWidth: size.width, image: _image)
    WZRichTextCache.sharedCache.cachedRichTextKeyInfo(withRichText: text, withTextStyle: textStyle, withMaxWidth: size.width, withKeyInfo: rectDict)
    
  }
  
  private class func drawImage(withRichText text: String, withTextStyle textStyle: WZTextStyle, withInterpreters interpreters: [Interpreter], withSize size: CGSize, withKeyInfoDict keyInfoDict: [NSValue: (range: NSRange, attributeValue: Any, interpreter: Interpreter)], withCurrentClickRectValue currentClickRectValue: NSValue?) -> (UIImage?, [NSValue: (range: NSRange, attributeValue: Any, interpreter: Interpreter)]) {
    
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return (nil, [:])}
    
    textStyle.backgroundColor.set()
    context.fill(CGRect(origin: CGPoint.zero, size: size))
    
    context.textMatrix = CGAffineTransform.identity
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1, y: -1)
    
    let attributedString = WZRichTextView.createAttributedString(withText: text, withTextStyle: textStyle, withInterpretes: interpreters)
    
    if let clickRectValue = currentClickRectValue, let range = keyInfoDict[clickRectValue]?.range {
      
      keyInfoDict[clickRectValue]?.interpreter.editAttributedStringOnTouchDown(richText: attributedString, inRanges: [range])
      
    }
    
    let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
    
    let path = CGMutablePath()
    path.addRect(CGRect(origin: CGPoint.zero, size: size))
    let frameRef = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: CFAttributedStringGetLength(attributedString)), path, nil)
    
    let lines = CTFrameGetLines(frameRef)
    let linesCount = CFArrayGetCount(lines)
    
    let origins = UnsafeMutablePointer<CGPoint>.allocate(capacity: linesCount)
    CTFrameGetLineOrigins(frameRef, CFRange(location: 0, length: 0), origins)
    
    var currentKeyInfoDict: [NSValue: (range: NSRange, attributeValue: Any, interpreter: Interpreter)] = [:]
    
    let yOffset = WZRichTextView.calculateOffsetForVerticalCenter(withImageSize: size, withText: text, withTextStyle: textStyle, withInterpretes: interpreters)
    
    for i in 0..<linesCount {
      
      let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, i), to: CTLine.self)
      var origin = origins[i]
      origin.y -= yOffset
      
      context.textPosition = origin
      CTLineDraw(line, context)
      
      let runs = CTLineGetGlyphRuns(line) as! Array<CTRun>
      
      for run in runs {
        
        let runRange = CTRunGetStringRange(run)
        let runOffset = CTLineGetOffsetForStringIndex(line, runRange.location, nil)
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        
        let runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil)
        let runPosition = CGPoint(x: origin.x + runOffset, y: origin.y - descent)
        let runRect = CGRect(origin: runPosition, size: CGSize(width: CGFloat(runWidth), height: ascent + descent))
        
        var touchableRect = runRect
        touchableRect.origin.y -= textStyle.lineSpace / 2
        touchableRect.size.height += textStyle.lineSpace
        
        //        UIColor.random.withAlphaComponent(0.5).setFill()
        //        context.fill(runRect)
        
        for interpreter in interpreters {
          
          let type = type(of: interpreter)
          let attributeName = "\(WZRichTextView.keyAttributeName)-\(type)"
          
          var attributeRange = NSRange(location: 0, length: 0)
          
          guard let keyAttributeValue = attributedString.attribute(attributeName, at: runRange.location, effectiveRange: &attributeRange) else { continue }
          
          currentKeyInfoDict[NSValue(cgRect: touchableRect)] = (attributeRange, keyAttributeValue, interpreter)
          
          interpreter.draw(inContext: context, withRunRect: runRect, withKeyAttributeValue: keyAttributeValue)
          
        }
      }
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    //如果keyInfoDict不为空则不用currentKeyInfoDict， 因为keyInfoDict的key为NSValue，不是值类型
    return (image, keyInfoDict.isEmpty ? currentKeyInfoDict : keyInfoDict)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard clickable else { return }
    
    let position = touches.first!.location(in: self)
    let runPosition = CGPoint(x: position.x, y: frame.height - position.y)
    
    for rect in rectDict.keys {
      
      if rect.cgRectValue.contains(runPosition) {
        
        currentClickRectValue = rect
        drawContent(highlightRange: rectDict[rect]!.range)
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard let currentClickRectValue = currentClickRectValue else { return}
    guard let attributeValue = rectDict[currentClickRectValue]?.attributeValue else { return }
    
    self.currentClickRectValue = nil
    drawContent()
    
    rectDict[currentClickRectValue]?.interpreter.didClick(withRichText: self, withAttributeValue: attributeValue)
    
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    currentClickRectValue = nil
    drawContent()
    
  }
  
  class func  calculateSize(withText text: String, withTextStyle textStyle: WZTextStyle, withInterpretes interpreters: [Interpreter],  withMaxWidth maxWidth: CGFloat) -> CGSize {
    
    if let size = WZRichTextCache.sharedCache.getRichTextSize(withRichText: text, withTextStyle: textStyle, withMaxWidth: maxWidth) {
      return size
    }
    
    let attributedString = WZRichTextView.createAttributedString(withText: text, withTextStyle: textStyle, withInterpretes: interpreters)
    
    let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
    
    let path = CGMutablePath()
    path.addRect(CGRect(origin: CGPoint.zero, size: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)))
    let frameRef = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: CFAttributedStringGetLength(attributedString)), path, nil)
    
    let lines = CTFrameGetLines(frameRef)
    let linesCount = CFArrayGetCount(lines)
    
    var size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(location: 0, length: 0), nil, CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), nil)
    
    size.width = linesCount == 1 ? size.width : maxWidth
    
    WZRichTextCache.sharedCache.cachedRichTextSize(withRichText: text, withTextStyle: textStyle, withMaxWidth: maxWidth, withSize: size)
    
    return size
  }
  
  private class func createAttributedString(withText text: String, withTextStyle textStyle: WZTextStyle, withInterpretes interpreters: [Interpreter]) -> NSMutableAttributedString {
    
    var attributesDic: [String: AnyObject] = [:]
    
    let font = textStyle.font
    let fontRef: CTFont = CTFontCreateWithName(font.fontName as CFString?, font.pointSize, nil)
    attributesDic[kCTFontAttributeName as String] = fontRef
    
    attributesDic[kCTForegroundColorAttributeName as String] = textStyle.textColor.cgColor
    
    var paragraphStyleSettings: [CTParagraphStyleSetting] = []
    var textAlignment: CTTextAlignment = textStyle.textAlignment
    var lineBreakMode: CTLineBreakMode = .byWordWrapping
    
    paragraphStyleSettings += [CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout.size(ofValue: textAlignment), value: &textAlignment)]
    paragraphStyleSettings += [CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout.size(ofValue: lineBreakMode), value: &lineBreakMode)]
    paragraphStyleSettings += [CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout.size(ofValue: textStyle.lineSpace), value: &textStyle.lineSpace)]
    paragraphStyleSettings += [CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout.size(ofValue: textStyle.lineSpace), value: &textStyle.lineSpace)]
    let paragraphStyle = CTParagraphStyleCreate(paragraphStyleSettings, paragraphStyleSettings.count)
    attributesDic[kCTParagraphStyleAttributeName as String] = paragraphStyle
    
    let attributedString = NSMutableAttributedString(string: text, attributes: attributesDic)
    
    for interpreter in interpreters {
      let type = type(of: interpreter)
      interpreter.interpret(richText: attributedString, withKeyAttributeName: "\(WZRichTextView.keyAttributeName)-\(type)")
    }
    
    return attributedString
  }
  
  private class func calculateOffsetForVerticalCenter(withImageSize imageSize: CGSize, withText text: String, withTextStyle textStyle: WZTextStyle, withInterpretes interpreters: [Interpreter]) -> CGFloat {
    
    guard textStyle.isVerticalCenter else {
      return 0
    }
    
    var yOffset: CGFloat = 0
    
    let textSize = calculateSize(withText: text, withTextStyle: textStyle, withInterpretes: interpreters, withMaxWidth: imageSize.width)
    
    yOffset = (imageSize.height - textSize.height) / 2
    
    return yOffset
  }
  
}
