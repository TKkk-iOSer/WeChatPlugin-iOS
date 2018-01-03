## WeChatPlugin-iOS

微信小助手-iOS版 v1.0.0

<img src="./Others/ScreenShots/WeChatPlugin.jpg" width="500">

**mac OS 版请戳→_→ [WeChatPlugin-MacOS](https://github.com/TKkk-iOSer/WeChatPlugin-MacOS)**

---

### 功能
- [x] 游戏作弊（石头剪刀布、骰子）
- [x] 修改微信运动步数
- [x] 消息防撤回
- [x] 自动通过好友请求
- [x] 请求自动通过后发送欢迎语
- [x] 消息自动回复(完全匹配触发)
- [x] 统一设置群公告
- [x] 敏感词自动踢人
- [x] 入群欢迎语
- [x] 群消息自动回复

**统一设置群公告、敏感词自动踢人、入群欢迎语 仅对自己创建的群有效**

---

### 截图

设置界面：

<img src="./Others/ScreenShots/Setting-03.png" height="500" hspace="20" style="display: inline-block"> <img src="./Others/ScreenShots/Setting-02.jpg" height="500" hspace="20" style="display: inline-block">


---

### 安装

~~详细安装方法可参考[iOS 逆向 - 微信 helloWorld](http://www.tkkk.fun/2017/03/19/%E9%80%86%E5%90%91-%E5%BE%AE%E4%BF%A1helloWorld/)~~

#### 0. 准备

* [ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)  (重签名)
* Xcode 或者 PP助手 (安装ipa)
* iOS 证书(可用Xcode生成临时开发证书，然而只能用7天)
* ipa文件(可直接下载下面百度云的app文件，如果重新注入动态库，请于PP助手下载**越狱版**的微信)
* [theos](https://github.com/theos/theos)(编写tweak工具，若不修改源码则不需要该工具)


#### 1. 生成临时证书(~~若有证书忽略该步骤~~)
使用 Xcode 创建一个 iOS 的 Project，选择方框1 的开发者，并用真机运行(~~使证书导入到 iPhone~~)。
![Xcode.png](http://upload-images.jianshu.io/upload_images/965383-e730b53fe95ab166.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 2. 生成注入的app文件

* 可直接通过百度云下载

链接: https://pan.baidu.com/s/1o7UBqL8 密码: f71u (微信版本 6.6.0 新版自动回复失效)

链接: https://pan.baidu.com/s/1c120oww 密码: 95bx（微信版本为6.5.16 无作弊功能）

* 若想修改源码，生成新的dylib，可在修改之后执行`make`,之后拷贝生成的dylib(~~路径为`./theos/obj/debug/robot.dylib`~~),最后执行 `./Others/autoInsertDylib.sh ipa文件路径 dylib文件路径` 即可获得注入dylib的app文件。

#### 3. 使用`iOS App Signer.app` 进行重签名

![iOS App Signer.app.png](http://upload-images.jianshu.io/upload_images/965383-c3daf12a77c8204b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* `Input File` 选择上面的app文件。
* `Signing Certificate` 选择第一步中的开发者账号(方框3)
* `Provisioning Profile` 选择第一步中的`bundle id`(方框2)

点击start获得重签名的`ipa`文件。

#### 4. 使用 Xcode 安装 ipa

打开Xcode-Window-Devices，将重签名的ipa文件拖到方框中，或者点击`+`添加ipa，即可完成。

![Device.png](http://upload-images.jianshu.io/upload_images/965383-abb8cf54a6acabbe.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 5. iOS权限设置

打开`设置-通用-描述文件与设备管理`，信任证列表中的开发者应用。

---

### 依赖
* [insert_dylib](https://github.com/gengjf/insert_dylib)(~~已在./Others/~~)
* [ios-app-signer](https://github.com/DanTheMan827/ios-app-signer) (~~文件太大，请自行下载编译~~)
* [theos](https://github.com/theos/theos)
* [zhPopupController](https://github.com/snail-z/zhPopupController) 

---

### 免责声明
本项目旨在学习 iOS 逆向的一点实践，不可使用于商业和个人其他意图。若使用不当，均由个人承担。


---

#### 听说你想请我喝下午茶？😏

<img src="http://upload-images.jianshu.io/upload_images/965383-cbc86dc1d75a6242.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" height="250" hspace="50"/>&nbsp;&nbsp;&nbsp;<img src="http://upload-images.jianshu.io/upload_images/965383-76a1c7c91b987e1a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" height="250" hspace="50"  />

