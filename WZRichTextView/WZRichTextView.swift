//
//  WZRichTextView.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/23.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

open class WZRichTextView: UIView {
  
  private var rectDict: [NSValue: WZRichTextRunInfo] = [:]
  private var currentClickRectValue: NSValue?
  private var clickable = true
  
  public var interpreters: [Interpreter] = []
  public var textStyle = WZTextStyle()
  public var cachedContent = false
  public var clearContentBeforeRedraw = false
  
  public var text: String = "" {
    didSet{
      rectDict.removeAll()
      setNeedsLayout()
    }
  }
  
  static let keyAttributeName = "keyAttributeName"
  
  public init() {
    super.init(frame: CGRect.zero)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override open func layoutSubviews() {
    drawContent()
  }
  
  func drawContent(with highlightRange: NSRange = NSRange(location: 0, length: 0)) {
    
    if clearContentBeforeRedraw {
      layer.contents = nil
    }
    
    let text = self.text
    let textStyle = self.textStyle
    let size = self.frame.size
    let rectDict = self.rectDict
    let currentClickRectValue = self.currentClickRectValue
    let interpreters = self.interpreters
    
    if cachedContent {
      
      if let image = WZRichTextCache.sharedCache.getRichTextImage(with: text, with: textStyle, with: interpreters, with: size.width, with: highlightRange), let keyInfo = WZRichTextCache.sharedCache.getRichTextKeyInfo(with: text, with: textStyle, with: interpreters, with: frame.width) {
        
        layer.contents = image.cgImage
        self.rectDict = keyInfo
        return
      }
      
    }
    
    DispatchQueue.global().async {
      
      self.clickable = false
      
      let (image, rectDict) = WZRichTextView.drawImage(text: text, textStyle: textStyle, interpreters: interpreters, size: size, keyInfoDict: rectDict, currentClickRectValue: currentClickRectValue)
      
      self.clickable = true
      
      guard let _image = image else { return }
      
      if self.cachedContent {
        
        WZRichTextCache.sharedCache.cachedRichTextImage(with: text, with: textStyle, with: interpreters, with: size.width, with: highlightRange, image: _image)
        WZRichTextCache.sharedCache.cachedRichTextKeyInfo(with: text, with: textStyle, with: interpreters, with: size.width, with: rectDict)
        
      }
      
      //当第一次点击后马上抬起，由于缓存的关系，会导致点击时的image在touchend之后绘制完成，从而抬起后会显示touchdown的image
      if !(highlightRange.location == 0 && highlightRange.length == 0) && self.currentClickRectValue == nil {
        return
      }
      
      let key = WZRichTextCache.sharedCache.calculateKey(with: text, with: textStyle, with: interpreters, with: size.width, with: highlightRange) as! Int
      
      DispatchQueue.main.async {
        
        //防止图片错位
        guard key == (WZRichTextCache.sharedCache.calculateKey(with: self.text, with: self.textStyle, with: interpreters, with: self.frame.width, with:highlightRange) as! Int) else { return }
        
        self.layer.contents = image?.cgImage
        self.rectDict = rectDict
        
      }
    }
  }
  
  public class func preCreateRichText(with text: String, with textStyle: WZTextStyle, with interpreters: [Interpreter], with size: CGSize) {
    
    if WZRichTextCache.sharedCache.getRichTextImage(with: text, with: textStyle, with: interpreters, with: size.width) != nil && WZRichTextCache.sharedCache.getRichTextKeyInfo(with: text, with: textStyle, with: interpreters, with: size.width) != nil {
      return
    }
    
    let (image, rectDict) = self.drawImage(text: text, textStyle: textStyle, interpreters: interpreters, size: size, keyInfoDict: [:], currentClickRectValue: nil)
    
    guard let _image = image else { return }
    WZRichTextCache.sharedCache.cachedRichTextImage(with: text, with: textStyle, with: interpreters, with: size.width, image: _image)
    WZRichTextCache.sharedCache.cachedRichTextKeyInfo(with: text, with: textStyle, with: interpreters, with: size.width, with: rectDict)
    
  }
  
  private class func drawImage(text: String, textStyle: WZTextStyle, interpreters: [Interpreter], size: CGSize, keyInfoDict: [NSValue: WZRichTextRunInfo], currentClickRectValue: NSValue?) -> (UIImage?, [NSValue: WZRichTextRunInfo]) {
    
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return (nil, [:])}
    
    textStyle.backgroundColor.set()
    context.fill(CGRect(origin: CGPoint.zero, size: size))
    
    context.textMatrix = CGAffineTransform.identity
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1, y: -1)
    
    let attributedString = WZRichTextView.createAttributedString(text: text, textStyle: textStyle, interpreters: interpreters)
    
    if let clickRectValue = currentClickRectValue, let range = keyInfoDict[clickRectValue]?.range, let classType = keyInfoDict[clickRectValue]?.classType {
      
      interpreters.filter({$0.isKind(of: classType)}).first?.editAttributedStringOnTouchDown(with: attributedString, in: [range])
      
    }
    
    let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
    
    let path = CGMutablePath()
    path.addRect(CGRect(origin: CGPoint.zero, size: size))
    let frameRef = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: CFAttributedStringGetLength(attributedString)), path, nil)
    
    let lines = CTFrameGetLines(frameRef)
    let linesCount = CFArrayGetCount(lines)
    
    let origins = UnsafeMutablePointer<CGPoint>.allocate(capacity: linesCount)
    CTFrameGetLineOrigins(frameRef, CFRange(location: 0, length: 0), origins)
    
    var currentKeyInfoDict: [NSValue : WZRichTextRunInfo] = [:]
    
    let yOffset = WZRichTextView.calculateOffsetForVerticalCenter(imageSize: size, text: text, textStyle: textStyle, interpreters: interpreters)
    
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
        
        if textStyle.isShowRunRect {
          UIColor.random.withAlphaComponent(0.5).setFill()
          context.fill(runRect)
        }
        
        for interpreter in interpreters {
          
          let type = type(of: interpreter)
          let attributeName = "\(WZRichTextView.keyAttributeName)-\(type)"
          
          var attributeRange = NSRange(location: 0, length: 0)
          
          guard let keyAttributeValue = attributedString.attribute(attributeName, at: runRange.location, effectiveRange: &attributeRange) else { continue }
          
          currentKeyInfoDict[NSValue(cgRect: touchableRect)] = WZRichTextRunInfo(range: attributeRange, attributeValue: keyAttributeValue, classType: type(of: interpreter))
          
          interpreter.draw(in: context, with: runRect, with: keyAttributeValue)
          
        }
      }
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    //如果keyInfoDict不为空则不用currentKeyInfoDict， 因为keyInfoDict的key为NSValue，不是值类型
    return (image, keyInfoDict.isEmpty ? currentKeyInfoDict : keyInfoDict)
  }
  
  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard clickable else { return }
    
    let position = touches.first!.location(in: self)
    let runPosition = CGPoint(x: position.x, y: frame.height - position.y)
    
    for rect in rectDict.keys {
      
      if rect.cgRectValue.contains(runPosition) {
        
        currentClickRectValue = rect
        drawContent(with: rectDict[rect]!.range)
      }
    }
  }
  
  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard let currentClickRectValue = currentClickRectValue else { return}
    guard let attributeValue = rectDict[currentClickRectValue]?.attributeValue else { return }
    
    self.currentClickRectValue = nil
    drawContent()
    
    guard let classType = rectDict[currentClickRectValue]?.classType else { return }
        
    interpreters.filter({$0.isKind(of: classType)}).first?.didClick(with: self, with: attributeValue)
    
  }
  
  override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    currentClickRectValue = nil
    drawContent()
    
  }
  
  public class func calculateSize(text: String, textStyle: WZTextStyle, interpreters: [Interpreter],  maxWidth: CGFloat) -> CGSize {
    
    if let size = WZRichTextCache.sharedCache.getRichTextSize(with: text, with: textStyle, with: interpreters, with: maxWidth) {
      return size
    }
    
    let attributedString = WZRichTextView.createAttributedString(text: text, textStyle: textStyle, interpreters: interpreters)
    
    let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
    
    let path = CGMutablePath()
    path.addRect(CGRect(origin: CGPoint.zero, size: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)))
    let frameRef = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: CFAttributedStringGetLength(attributedString)), path, nil)
    
    let lines = CTFrameGetLines(frameRef)
    let linesCount = CFArrayGetCount(lines)
    
    var size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(location: 0, length: 0), nil, CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), nil)
    
    size.width = linesCount == 1 ? size.width : maxWidth
    
    WZRichTextCache.sharedCache.cachedRichTextSize(with: text, with: textStyle, with: interpreters, with: maxWidth, with: size)
    
    return size
  }
  
  public class func calculateSize(richTextView: WZRichTextView, maxWidth: CGFloat) -> CGSize {
  
    return calculateSize(text: richTextView.text, textStyle: richTextView.textStyle, interpreters: richTextView.interpreters, maxWidth: maxWidth)
  }
  
  private class func createAttributedString(text: String, textStyle: WZTextStyle, interpreters: [Interpreter]) -> NSMutableAttributedString {
    
    var attributesDic: [String: AnyObject] = [:]
    
    let font = textStyle.font
    let fontRef: CTFont = CTFontCreateWithName(font.fontName as CFString?, font.pointSize, nil)
    attributesDic[kCTFontAttributeName as String] = fontRef
    
    attributesDic[kCTForegroundColorAttributeName as String] = textStyle.textColor.cgColor
    
    var paragraphStyleSettings: [CTParagraphStyleSetting] = []
    var textAlignment: CTTextAlignment = textStyle.textAlignment
    var lineBreakMode: CTLineBreakMode = textStyle.lineBreakMode
    
    paragraphStyleSettings += [CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout.size(ofValue: textAlignment), value: &textAlignment)]
    paragraphStyleSettings += [CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout.size(ofValue: lineBreakMode), value: &lineBreakMode)]
    paragraphStyleSettings += [CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout.size(ofValue: textStyle.lineSpace), value: &textStyle.lineSpace)]
    paragraphStyleSettings += [CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout.size(ofValue: textStyle.lineSpace), value: &textStyle.lineSpace)]
    let paragraphStyle = CTParagraphStyleCreate(paragraphStyleSettings, paragraphStyleSettings.count)
    attributesDic[kCTParagraphStyleAttributeName as String] = paragraphStyle
    
    let attributedString = NSMutableAttributedString(string: text, attributes: attributesDic)
    
    for interpreter in interpreters {
      let type = type(of: interpreter)
      interpreter.interpret(with: attributedString, with: textStyle, with: "\(WZRichTextView.keyAttributeName)-\(type)")
    }
    
    return attributedString
  }
  
  private class func calculateOffsetForVerticalCenter(imageSize: CGSize, text: String, textStyle: WZTextStyle, interpreters: [Interpreter]) -> CGFloat {
    
    guard textStyle.isVerticalCenter else {
      return 0
    }
    
    let textSize = calculateSize(text: text, textStyle: textStyle, interpreters: interpreters, maxWidth: imageSize.width)
    
    let yOffset = (imageSize.height - textSize.height) / 2
    
    return yOffset
  }
  
}
