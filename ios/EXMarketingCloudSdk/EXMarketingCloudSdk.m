// SalesForce MarketingCloud ExpoModule
#import <MarketingCloudSDK/MarketingCloudSDK.h>
#import <ExpoModulesCore/EXDefines.h>
#import <EXNotifications/EXNotificationCenterDelegate.h>
#import <EXMarketingCloudSdk/EXMarketingCloudSdk.h>

@interface EXMarketingCloudSdk ()

@property (nonatomic, weak) id<EXNotificationCenterDelegate> notificationCenterDelegate;

@end

@implementation EXMarketingCloudSdk

EX_REGISTER_SINGLETON_MODULE(MarketingCloud);

# pragma mark - EXModuleRegistryConsumer

- (void)setModuleRegistry:(EXModuleRegistry *)moduleRegistry
{
  _notificationCenterDelegate = [moduleRegistry getSingletonModuleForName:@"NotificationCenterDelegate"];
}

# pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
  NSURL *sfmcServerUrl = [NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCServerUrl"]];
  NSString *sfmcAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCApplicationId"];
  NSString *sfmcMid = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCMid"];
  NSString *sfmcAccessToken = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCAccessToken"];
  NSNumber *sfmcAnalyticsEnabled = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCAnalyticsEnabled"];
  NSNumber *sfmcAppControlsBadging = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCApplicationControlsBadging"];
  NSNumber *sfmcDelayRegistrationUntilContactKeyIsSet = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCDelayRegistrationUntilContactKeyIsSet"];
  NSNumber *sfmcInboxEnabled = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCInboxEnabled"];
  NSNumber *sfmcLocationEnabled = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFMCLocationEnabled"];

  PushConfigBuilder *pushConfigBuilder = [[[[[[[[[PushConfigBuilder alloc] initWithAppId:sfmcAppId]
                        setMarketingCloudServerUrl:sfmcServerUrl]
                      setAccessToken:sfmcAccessToken]
                    setAnalyticsEnabled:sfmcAnalyticsEnabled]
                  setApplicationControlsBadging:sfmcAppControlsBadging]
                setDelayRegistrationUntilContactKeyIsSet:sfmcDelayRegistrationUntilContactKeyIsSet]
              setInboxEnabled:sfmcInboxEnabled]
            setLocationEnabled:sfmcLocationEnabled];
  
  if ([sfmcMid length] > 0) {
    pushConfigBuilder = [pushConfigBuilder setMid:sfmcMid];
  }
  
  [SFMCSdk initializeSdk:[[[SFMCSdkConfigBuilder new] setPushWithConfig:[pushConfigBuilder build] onCompletion:^(SFMCSdkOperationResult result) {
    if (result != SFMCSdkOperationResultSuccess) {
      EXLogError(@"[expo-plugin-marketingcloudsdk] Failed to initialize instance. (error: %d)", result);
    } else {
      [self->_notificationCenterDelegate addDelegate:self];
    }
  }] build]];
  
  
  
  return YES;
}

//# pragma mark - EXNotificationsDelegate

// MobilePush SDK: REQUIRED IMPLEMENTATION
/** This delegate method offers an opportunity for applications with the "remote-notification" background mode to fetch appropriate new data in response to an incoming remote notification. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
 This method will be invoked even if the application was launched or resumed because of the remote notification. The respective delegate methods will be invoked first. Note that this behavior is in contrast to application:didReceiveRemoteNotification:, which is not called in those cases, and which will not be invoked if this method is implemented. **/
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  [[MobilePushSDK sharedInstance] sfmc_setNotificationUserInfo:userInfo];
  completionHandler(UIBackgroundFetchResultNewData);
}

@end
