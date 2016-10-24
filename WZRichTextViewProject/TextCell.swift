//
//  TextCell.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/26.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {
  
  var textView: WZRichTextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    let interpreters: [Interpreter] = [EmojiInterpreter(), ClickableInterpreter(), URLInterpreter()]
    
    let textStyle = WZTextStyle()
    
    textView = WZRichTextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: contentView.frame.height))
    textView.textStyle = textStyle
    textView.shouldCached = true
    textView.interpreters = interpreters
    contentView.addSubview(textView)

  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setData(text: String) {
    
    let interpreters: [Interpreter] = [EmojiInterpreter(), ClickableInterpreter(), URLInterpreter()]
    
    let textStyle = WZTextStyle()
    
    let size = WZRichTextView.calculateSize(withText: "\(tag)" + text, withTextStyle: textStyle, withInterpretes: interpreters, withMaxWidth: contentView.frame.width)

    textView.frame.size = size
    textView.text = "\(tag)" + text
  }
  
}
