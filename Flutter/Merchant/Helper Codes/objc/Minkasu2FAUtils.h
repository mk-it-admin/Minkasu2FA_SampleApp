#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface Minkasu2FAUtils : NSObject
+ (instancetype)sharedInstance;
- (void)setUpMinkasu2FAWithController:(FlutterViewController *)controller;
- (void)setUpMinkasu2FAWithEngine:(FlutterEngine *)engine;
@end

NS_ASSUME_NONNULL_END
