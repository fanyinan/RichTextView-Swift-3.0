# RichTextView-Swift-3.0

<img src="WZRichTextViewDemo/WZRichTextViewProject/pic.png" width="30%">


* 主要结构

主要控件WZRichTextView继承自UIView，用于展示通过CoreText绘制文字生成的图片；通过WZTextStyle配置文字样式；可以配置多个Interpreter来处理文字


* 易拓展

将对文字的处理的逻辑抽象出一个Interpreter，主要包括对文字的解析，点击时的样式，点击事件的处理，在上下文中进行绘制。通过具体的Interpreter来实现需要的接口完成相应的功能。传入的多个Interpreter按顺序依次处理文字，但是如果一个`CTRun`对应了多个Interpreter，只有第一个Interpreter的点击事件和点击时的样式会生效

* 灵活

需要解析文字时只需传入相应的InterPreter即可，不做多余的文字处理。需要注意的是，当传入多个Interpreter时，需要注意在数组中的顺序，这个顺序决定了文字的处理顺序

* 缓存

CoreText绘制文字生成的图片以及尺寸等相关信息会存入缓存中，以便高效的复用，缓存的key有文字内容、文字样式、Interpreter共同生成，防止发生混乱

* 预加载

即使有缓存功能，但是在首次加载时依然会出现由于异步渲染无法立即显示文字的问题。预加载可以解决这个问题，文字尺寸的计算和绘制文字生成图片都是静态方式，不需要实例化WZRichTextView即可在控件加载之前便已完成对文字内容的缓存和高度的计算，当控件需要显示文字时便可直接在缓存中取得。所以使用者需要合理控制预加载的时机
