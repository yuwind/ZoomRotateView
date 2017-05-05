# ZoomRotateView
这是一个会缩放的轮播图，自带波浪刷新以及3D变化

**详见效果图**
![image](https://github.com/yuwind/ZoomRotateView/blob/master/ScreenShort/zoomRotateView.gif)   

**说明：**
	 这是一个一句话就可实现基础功能的缩放轮播图，内部自动设置代理，自动监听tableView的滚动，用结构体存储数据，简化赋值流程。不依赖第三方库，只需要调用实例化方法，设置几个属性即可使用。同时拥有波浪刷新，简易3D变化，让你的轮播图不再单一。
	 
注意事项：需要导入资源包placeholdResource.bundle

**使用方法：**
```objc
	self.tableView.tableHeaderView= [HHRotateView rotateViewWithFrame:CGRectMake(0, 0, 0, 200) imageArray:imageArray describeArray:titleArray showScale:YES];
```
**常用属性：**
```objc
	 rotateView.rotateMode = RotateMode3D;
	 rotateView.pageColor = pageColorMake([UIColor redColor],[UIColor yellowColor]);
	 rotateView.labelAttribute = labelAttributeMake([UIColor yellowColor], 20);
	 rotateView.pageImage = pageImageMake(@"dianhui",@"dianhong");
	 rotateView.waveColor = [UIColor whiteColor];
	 rotateView.waveFrequency = 5.0f;
```


