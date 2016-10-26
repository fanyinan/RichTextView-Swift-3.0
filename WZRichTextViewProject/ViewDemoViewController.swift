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
  
  let str3 = ""
  let str2 = "尊敬的用户，欢迎来到小友，据统计，在<key>小友</>有头像、资料完整且验证了手机的用户能够成功找到对象的比例高达68.8%。别犹豫了\n\t1、【<a href=\"/customAction?cmd=uploadPhoto\"  style=\"color:red\">立即上传头像</a>】\n\t1、【<a href=\"/customAction?cmd=fillDetail\"  style=\"color:red\">立即完善资料</a>】\n\t1、【<a href=\"/customAction?cmd=setPhone\"  style=\"color:red\">立即验证手机</a>】"
  let str1 = "送实现。[timg-4]<a>粉丝及开发</>新的<b>传感器</b>成像</b>像细节</>"
  let str = "3040万像素 细节更扎实控噪有惊喜佳能5D4大家最直观的感受就是采用了3040万像素的全新传感器，全新传感器相于5D3提升了大约800万像[timg-4]，但是借助于DIGIC 6+处理器，佳能5D4在控噪上<a>粉丝及开发</a>并不弱于5D3，在如此大的像素提升下，控噪不退步，就已经是很大的提升。另外，全新的传感器成像细节表现非常不错，成像相当扎实。（点击直达相关测试）·宽容度大突破 这一次真的有感动大家对于佳能以往机器，最大的诟病莫过于宽容度问题，佳能5D3算得上是台好机子，但是宽容度绝对不算在优点之内，如今佳能也已经[timg-4]采用了片上ADC，宽容[timg-4]度问题在根源上已经<a>粉丝及开发</a>解决了，从实际使用中[timg-4]，虽然目前DPP只能处理3档曝光，因此我们还不能看到佳[timg-4]能5D4的全部宽容度实力，但是从笔者的实际拍摄感受来看，佳能5D4已经有了长足的进步。（点击直达相关测试）·双核RAW文件有新意 实际效果很明显全像素双核RA[timg-4]W文件是佳能5D4的全新功能，也就是DPRAW格式，这一格式为[timg-4]后期带来了更丰富的调整空间，特别是在人像拍摄领域拥有很[timg-4]大的用途。（点击直达相关测试）·对焦性能不俗 弱光对焦是亮点在机<a>粉丝及开发</a>身性能上，5D4最大的亮点在于对焦的升级。全新升级的61点对焦系统覆盖面积更广，而且[timg-4]全面支持-3EV对焦，弱光下的对焦拍摄变得更加容易。更加惊喜的是，全新的实时取景对焦系统，也就是佳[timg-4]能引以为傲的全像素双核CMOS AF，这次不仅覆盖面积达到了横纵80%的面积，而且全面支持-4EV对焦。当然，触控对焦也是全面升级，配合全新162万像素点的屏幕，触控对焦更加方便。（点击直达相关测[timg-4]试）·4K视频 未来相机的标准配置[timg-4]最后当然还是4K，佳能官方在5D4的卖点中着重表明了4K功能，说明佳能对于单反相机的视频系统还是非常看重的。回到机器本身，佳能的[timg-4]4K不是3840的长边，而是4096，这对于视频后期会有很大的帮助。但是，受制于存储v<a>粉丝及开发</a>卡[timg-4]的限制，佳能5D4并没有4K 60p，这一点略显遗憾。（点击直达相关测试）唯均衡更出众！佳能5D Mark IV深度评佳能5D Mark IV搭[timg-[timg-4]4]配24-70mm f/4从5D4的参数就可以看出，这款相机各项性能中虽然没有哪一项是绝对的亮点，但[timg-4]是各项性能都不差，[timg-4]所以5D4的综合性能相当不错，是一台以均衡性[timg-4]为主打的高端单反相机，拍摄用途也更加丰富，3000万像素完全可以胜任风光摄影或者大幅输出，而不错[timg-4]的控噪和出色的机械性能在连拍抓拍上也非常优秀。下面我们就进入今天的评测，看一下佳能5D4在客观测试中表现如何"

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setupUI() {
    
    let clickableInterpreter = ClickableInterpreter()
    clickableInterpreter.delegate = self
    clickableInterpreter.keyTextNormalForegroundColor = nil
    clickableInterpreter.keyTextSelectedBackgroundColor = UIColor.orange
    clickableInterpreter.keyTextSelectedForegroundColor = UIColor.red
    
    let htmlInterpreter = HTMLInterpreter()
    htmlInterpreter.isParserHerf = true
    
    let interpreters: [Interpreter] = [htmlInterpreter, clickableInterpreter]
    
    let textStyle = WZTextStyle()
    textStyle.backgroundColor = UIColor.green
    textStyle.isVerticalCenter = true
//    textStyle.textAlignment = .center
    
    let size = WZRichTextView.calculateSize(withText: str2, withTextStyle: textStyle, withInterpretes: interpreters, withMaxWidth: view.frame.width)
    
    richTextView = WZRichTextView(frame: CGRect(x: 0, y: 100, width: size.width, height: size.height))
//    richTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    richTextView.textStyle = textStyle
    richTextView.backgroundColor = UIColor.green
    richTextView.interpreters = interpreters
    richTextView.cachedContent = true
    view.addSubview(richTextView)
//    richTextView.text = str
    richTextView.text = str2
    
 
    print(self)
  }

  @IBAction func test() {
    
    WZRichTextCache.sharedCache.removeAllCache()
//    let clickableInterpreter = ClickableInterpreter()
//    clickableInterpreter.delegate = self
//    clickableInterpreter.keyTextNormalForegroundColor = nil
//    clickableInterpreter.keyTextSelectedBackgroundColor = UIColor.orange
//    clickableInterpreter.keyTextSelectedForegroundColor = UIColor.red
//    
//    let htmlInterpreter = HTMLInterpreter()
//    htmlInterpreter.isParserHerf = true
//    
//    let interpreters2: [Interpreter] = [clickableInterpreter, htmlInterpreter]
//    
//    let textStyle = WZTextStyle()
//    textStyle.backgroundColor = UIColor.green
//    textStyle.isVerticalCenter = true
//    //    textStyle.textAlignment = .center
//    
//    let size2 = WZRichTextView.calculateSize(withText: str2, withTextStyle: textStyle, withInterpretes: interpreters2, withMaxWidth: view.frame.width)
//    
//    
//    let richTextView2 = WZRichTextView(frame: CGRect(x: 0, y: 150, width: size2.width, height: size2.height))
//    //    richTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    richTextView2.textStyle = textStyle
//    richTextView2.backgroundColor = UIColor.green
//    richTextView2.interpreters = interpreters2
//    richTextView2.cachedContent = true
//    view.addSubview(richTextView2)
//    //    richTextView.text = str
//    richTextView2.text = str2
//    
  }
}

extension ViewDemoViewController: ClickableInterpreterDelegate {
  func didClick(withRichText richText: WZRichTextView, withKey key: String) {
    print(key)
  }
}
