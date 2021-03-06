//
//  TextCell.swift
//  WZRichTextViewProject
//
//  Created by fanyinan on 16/9/26.
//  Copyright © 2016年 fanyinan. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {
  
  var textView: WZRichTextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    let interpreters: [Interpreter] = [PictureInterpreter(), ClickableInterpreter(), URLInterpreter()]
    
    let textStyle = WZTextStyle()
    
    textView = WZRichTextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: contentView.frame.height))
    textView.textStyle = textStyle
    textView.cachedContent = true
    textView.clearContentBeforeRedraw = true
    textView.interpreters = interpreters
    contentView.addSubview(textView)

  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setData(text: String) {
    
    let interpreters: [Interpreter] = [PictureInterpreter(), ClickableInterpreter(), URLInterpreter()]
    
    let textStyle = WZTextStyle()
    
    let size = WZRichTextView.calculateSize(text: "\(tag)" + text, textStyle: textStyle, interpreters: interpreters, maxWidth: contentView.frame.width)

    textView.frame.size = size
    textView.text = "\(tag)" + text
  }
  
}
