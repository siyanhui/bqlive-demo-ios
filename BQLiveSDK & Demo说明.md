##BQLiveSDK & Demo说明

###SDK部分：
##### 一、解密与统计模块

######类：

######`BQLiveManager`

######功能：

######1.解码Gift资源 2.事件统计

######使用：



#######初始化：

`[[BQLiveManager defaultManager] setAppId:"YOUR APPID" secret:"YOUR APP SECRET"];`



#######解码统计接口:

见`BQLiveManager.h`, 用法参考Demo





##### 二、资源管理模块：（本模块可自行实现）

######类： 
`BQGiftManager` 
######功能：
1.获取服务器礼物配置信息 2.获取本地礼物配置信息 3.下载删除本地礼物资源

######使用：


#######初始化：
`[[BQGiftManager defaultManager] setUserId:@"USER ID" userName:@"USER_NAME"];`
#######礼物资源增删改查
见  ` BQGiftManager.h`, 用法参考Demo

###DEMO：
#####一、界面 LiveViewController
######主要是两个View控件：

1.   ```LLSimpleCamera```，（相机窗口）模拟直播 
2.   ```BQLAnimatedImageView```，用来播放礼物特效

######发送礼物方法是：

`sendGift`（细节见demo）

#####二、特效展示模块（资源文件的解析加载和播放展示逻辑）
######类：
`BQLAnimatedImageConfig` ：特效中除主图以外的元素的配置信息
`BQLAnimatedImage`：整个特效资源的数据model
`BQLAnimatedImageView`： 特效播放展示的UI控件

######技术要点：` CADisplayLink`






















