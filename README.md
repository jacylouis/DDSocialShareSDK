# DDSocialShareSDK
> 
> 自己造的一个轮子，原生的第三方分享SDK
> 
### 示例代码

>图片分享实现DDShareSDKImageProtocol协议
>
			>[[DDSocialShareSDKHandle sharedInstance] shareWithPlatform:DDSSPlatformSina shareScene:DDSSShareSceneSina shareType:DDSSShareTypeImage protocol:self completeHandle:^(DDSSPlatform type, DDSSShareScene shareScene, DDSSStateType state, NSError *error) {
             >   
            >}];
			>
>连接分享实现DDShareSDKWebPageProtocol协议
            >[[DDSocialShareSDKHandle sharedInstance] shareWithPlatform:DDSSPlatformSina shareScene:DDSSShareSceneSina shareType:DDSSShareTypeWebPage protocol:self completeHandle:^(DDSSPlatform type, DDSSShareScene shareScene, DDSSStateType state, NSError *error) {
            >    
            >}];
			>
### 一、配置工作
   > 
   > 修改info.plist，copy Demo中的 LSApplicationQueriesSchemes 、 URLTypes、 NSAppTransportSecurity确保原封不动的copy，其次将URLTypes中的URLSchemes改为自己申请的
   > 
### 二、将SocialShareSDK目录中的内容全部copy到自己的工程中
    > 1、DDShareSDKContentProtocol 分享的协议类，实现分享的model必须实现该协议
	> 
    > 2、DDShareSDKEventHandlerDef 一些回调block定义
	> 
    > 3、DDShareSDKTypeDef平台 场景的枚举定义
	> 
    > 4、DDSocialShareSDKHandle 主要的分享入口，必须通过该入口进行分享
	> 
    > 5、DDSDKHandle对第三方做了平行封装可根据需求增删模块，增加模块参照已经写好的即可平行扩展
	> 
    > 6、Model 从第三方获取的信息转换成统一的Model
### 三、配置
  > 在AppDelegate中 #import "DDSocialShareSDKHandle.h"
  > 
  > 实现如下代码：
  > 
  > - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	   > 
       > [[DDSocialShareSDKHandle sharedInstance] registerPlatform:DDSSPlatformWeChat];
	   > 
       >  [[DDSocialShareSDKHandle sharedInstance] registerPlatform:DDSSPlatformSina];
	   > 
       > return YES;
	   > 
   > }

  > - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	  > 
      >  return [[DDSocialShareSDKHandle sharedInstance] handleOpenURL:url];
	  > 
  > }

  > - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	  > 
      > return [[DDSocialShareSDKHandle sharedInstance] handleOpenURL:url];
	  > 
  > }

### 四、如果不想手动配置第三方的库可以使用pod引入
       > pod 'DDThirdShareLibrary/TencentSDK'  //腾讯SDK
	   > 
       > pod 'DDThirdShareLibrary/WeChatSDK'   //微信SDK
	   > 
       > pod 'DDThirdShareLibrary/WeiboSDK'    //SinaSDK
	   > 
       > pod 'DDThirdShareLibrary/MISDK'       //MISDK
	   > 
