//
//  ViewController.swift
//  WZRichTextViewProject
//
//  Created by 范祎楠 on 16/9/23.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class TableViewDemoViewController: UIViewController {
  
  var tableView: UITableView!
  var count = 100
  
  let str2 = "亲爱的帅哥(ID:71212013): 恭喜你成为71202013名来到收获爱情的用户。你所在的北京市有966614美女正在寻觅伴侣。据统计，在有头像、资料完整且验证了手机的用户能够成功找到对象的比例高达68.8%。别犹豫了，            <br>1、【<a href=\"1\"  style=\"color:red\">立即上传头像</a>】<br>            <br>2、【<a href=\"2\"  style=\"color:red\">立即完善资料</a>】<br>            <br>3、【<a href=\"3\" style=\"color:red\">立即验证手机</a>】<br>            <br>让自己靠近幸福的脚步再快一些吧！"
  let str1 = "送实现。[timg-4]<a>粉丝及开发</>新的<b>传感器</b>成像</b>像细节</>"
  let str = "像素 细节更扎实控噪有惊喜佳能5D4大家最直观的感受就是采用了3040万像素的全新传感器，全新传感器相于5D3提升了大约800万像[timg-4]，但是借助于DIGIC 6+处理器，佳能5D4在控噪上<a>粉丝及开发</a>并不弱于5D3，在如此大的像素提升下，控噪不退步，就已经是很大的提升。另外，全新的传感器成像细节表现非常不错，成像相当扎实。（点击直达相关测试）·宽容度大突破 这一次真的有感动大家对于佳能以往机器，最大的诟病莫过于宽容度问题，佳能5D3算得上是台好机子，但是宽容度绝对不算在优点之内，如今佳能也已经[timg-4]采用了片上ADC，宽容[timg-4]度问题在根源上已经<a>粉丝及开发</a>解决了，从实际使用中[timg-4]，虽然目前DPP只能处理3档曝光，因此我们还不能看到佳[timg-4]能5D4的全部宽容度实力，但是从笔者的实际拍摄感受来看，佳能5D4已经有了长足的进步。（点击直达相关测试）·双核RAW文件有新意 实际效果很明显全像素双核RA[timg-4]W文件是佳能5D4的全新功能，也就是DPRAW格式，这一格式为[timg-4]后期带来了更丰富的调整空间，特别是在人像拍摄领域拥有很[timg-4]大的用途。（点击直达相关测试）·对焦性能不俗 弱光对焦是亮点在机<a>粉丝及开发</a>身性能上，5D4最大的亮点在于对焦的升级。全新升级的61点对焦系统覆盖面积更广，而且[timg-4]全面支持-3EV对焦，弱光下的对焦拍摄变得更加容易。更加惊喜的是，全新的实时取景对焦系统，也就是佳[timg-4]能引以为傲的全像素双核CMOS AF，这次不仅覆盖面积达到了横纵80%的面积，而且全面支持-4EV对焦。当然，触控对焦也是全面升级，配合全新162万像素点的屏幕，触控对焦更加方便。（点击直达相关测[timg-4]试）·4K视频 未来相机的标准配置[timg-4]最后当然还是4K，佳能官方在5D4的卖点中着重表明了4K功能，说明佳能对于单反相机的视频系统还是非常看重的。回到机器本身，佳能的[timg-4]4K不是3840的长边，而是4096，这对于视频后期会有很大的帮助。但是，受制于存储v<a>粉丝及开发</a>卡[timg-4]的限制，佳能5D4并没有4K 60p，这一点略显遗憾。（点击直达相关测试）唯均衡更出众！佳能5D Mark IV深度评佳能5D Mark IV搭[timg-[timg-4]4]配24-70mm f/4从5D4的参数就可以看出，这款相机各项性能中虽然没有哪一项是绝对的亮点，但[timg-4]是各项性能都不差，[timg-4]所以5D4的综合性能相当不错，是一台以均衡性[timg-4]为主打的高端单反相机，拍摄用途也更加丰富，3000万像素完全可以胜任风光摄影或者大幅输出，而不错[timg-4]的控噪和出色的机械性能在连拍抓拍上也非常优秀。下面我们就进入今天的评测，看一下佳能5D4在客观测试中表现如何"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setupUI() {
    
    tableView = UITableView(frame: view.bounds)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    view.addSubview(tableView)
    tableView.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "TextCell")
    
//    preload()
    
  }
  
  func preload() {
    
    let start = CACurrentMediaTime()
    let interpreters: [Interpreter] = [EmojiInterpreter(), ClickableInterpreter(), URLInterpreter()]
    
    let textStyle = WZTextStyle()
    
    for i in 0..<count {
      
      let size = WZRichTextView.calculateSize(withText: "\(i)\(str)", withTextStyle: textStyle, withInterpretes: interpreters, withMaxWidth: UIScreen.main.bounds.width)
      
      WZRichTextView.preCreateRichText(withRichText: "\(i)\(str)", withTextStyle: textStyle, withInterpreters: interpreters, withSize: size)
      
    }
    
    print(CACurrentMediaTime() - start)
    print("preload finish")
  }
 
}

extension TableViewDemoViewController: UITableViewDataSource {
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
    
    cell.tag = indexPath.row
    cell.setData(text: str)
    
    return cell
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return count
  }
  
}

extension TableViewDemoViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    let interpreters: [Interpreter] = [EmojiInterpreter(), ClickableInterpreter(), URLInterpreter()]
    
    let textStyle = WZTextStyle()
    
    let size = WZRichTextView.calculateSize(withText: "\(indexPath.row)" + str, withTextStyle: textStyle, withInterpretes: interpreters, withMaxWidth: UIScreen.main.bounds.width)
    
    return size.height
  }
}

extension TableViewDemoViewController: ClickableInterpreterDelegate {
  func didClick(withRichText richText: WZRichTextView, withKey key: String) {
    print(key)
  }
}
