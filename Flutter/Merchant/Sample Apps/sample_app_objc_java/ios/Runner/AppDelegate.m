#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import "Minkasu2FAUtils.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
    [[Minkasu2FAUtils sharedInstance] setUpMinkasu2FAWithEngine:controller.engine];
    
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
