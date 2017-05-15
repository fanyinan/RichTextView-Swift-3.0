//
//  ViewController.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/23.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class ViewDemoViewController: UIViewController {
  
  var richTextView: WZRichTextView!
  
  let str3 = "<font color=\"#FF0000\" size=\"2\">11</font>一掷千金，登上土豪榜第<font color=\"#FF0000\" size=\"2\">22</font>"
  
  //解析html中的超链接，同时添加点击事件
  //需要HTMLInterpreter和ClickableInterpreter
  //HTMLInterpreter需要设置isParserHerf为true
  let str2 = "很遗憾，您的视频认证审核未通过，请拍摄真是清晰的个人近照。<a href=\"video_certification\">点击认证</a>"
  let str1 = "送[timg-4][timg-4][timg-4]实现。[timg-4]<a>粉丝及开发</>新的<b>传感器</b>成像</b>像细节</>"
  let str = "3040万像素 细节更<b>扎实</>控噪有惊喜佳能5D4大家最直观的感受就是采[timg-4][timg-4]用了3040万像素的全新传感器，全新传感器相于5D3提升了大约800万像[timg-4][timg-4][timg-4][timg-4][timg-4]，但是借助于DIGIC 6+处理器，佳能5D4在控噪上<a>粉丝及开发</a>并不弱于5D3，在如此大的像素提升下，控噪不退步，就已经是很大的提升。另外，全新的传感器成像细节表现非常不错，成像相当扎实。（点击直达相关测试）·宽容度大突破 这一次真的有感动大家对于佳能以往机器，最大的诟病莫过于宽容度问题，佳能5D3算得上是台好机子，但是宽容度绝对不算在优点之内，如今佳能也已经[timg-4]采用了片上ADC，宽容[timg-4]度问题在根源上已经<a>粉丝及开发</a>解决了"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
  }
  
  func setupUI() {
    
    let testStr = str
    let clickableInterpreter = ClickableInterpreter()
    clickableInterpreter.delegate = self
    clickableInterpreter.keyTextNormalForegroundColor = UIColor.yellow
    clickableInterpreter.keyTextSelectedBackgroundColor = UIColor.orange
    clickableInterpreter.keyTextSelectedForegroundColor = UIColor.red
    
    let htmlInterpreter = HTMLInterpreter()
    htmlInterpreter.isParserHerf = true
    htmlInterpreter.isUseHtmlStyle = true
    
    let pictureInterpreter = PictureInterpreter()
    pictureInterpreter.delegate = self
    let interpreters: [Interpreter] = [pictureInterpreter, clickableInterpreter]
    
    let textStyle = WZTextStyle()
    textStyle.backgroundColor = UIColor.green
    textStyle.isVerticalCenter = true
    textStyle.textColor = UIColor.gray
    textStyle.font = UIFont.systemFont(ofSize: 12)
//    textStyle.isShowRunRect = true

//    textStyle.textAlignment = .center
    
    let size = WZRichTextView.calculateSize(text: testStr, textStyle: textStyle, interpreters: interpreters, maxWidth: view.frame.width - 40)
    
    richTextView = WZRichTextView(frame: CGRect(x: 20, y: 100, width: size.width, height: size.height))
//    richTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    richTextView.textStyle = textStyle
    richTextView.backgroundColor = UIColor.green
    richTextView.interpreters = interpreters
    richTextView.cachedContent = false
    richTextView.clearContentBeforeRedraw = false
    view.addSubview(richTextView)
    richTextView.text = testStr
    
  }

  @IBAction func test() {
    
    WZRichTextCache.sharedCache.removeAllCache()
  }
}

extension ViewDemoViewController: ClickableInterpreterDelegate {
  func didClick(with richText: WZRichTextView, with key: String) {
    print(key)
  }
}

extension ViewDemoViewController: PictureInterpreterDelegate {
  
  func pictureInterpreter(pictureInterpreter: PictureInterpreter, pictureSizeAt index: Int, with pictureMaxSize: CGSize) -> CGSize {
    
    return CGSize(width: pictureMaxSize.width - 2, height: pictureMaxSize.height - 2)

  }
}
