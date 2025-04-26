#import <Cordova/CDV.h>

@interface AppPrivacyPlugin : CDVPlugin

@property (nonatomic, assign) BOOL privacyModeEnabled;
@property (nonatomic, strong) UIWindow *privacyWindow;

- (void)enablePrivacyMode:(CDVInvokedUrlCommand*)command;
- (void)disablePrivacyMode:(CDVInvokedUrlCommand*)command;

@end

@implementation AppPrivacyPlugin

- (void)pluginInitialize {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    });
    self.privacyModeEnabled = NO;
}

- (void)enablePrivacyMode:(CDVInvokedUrlCommand*)command {
    self.privacyModeEnabled = YES;
    
    // If app is currently not active, show privacy screen immediately
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self applyPrivacyScreen];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)disablePrivacyMode:(CDVInvokedUrlCommand*)command {
    self.privacyModeEnabled = NO;
    [self removePrivacyScreen];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onAppWillResignActive:(NSNotification *)notification {
    if (self.privacyModeEnabled) {
        [self applyPrivacyScreen];
    }
}

- (void)onAppDidBecomeActive:(NSNotification *)notification {
    [self removePrivacyScreen];
}

- (void)applyPrivacyScreen {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.privacyWindow) {
            self.privacyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.privacyWindow.windowLevel = UIWindowLevelAlert + 1;
            self.privacyWindow.backgroundColor = [UIColor blackColor];
            self.privacyWindow.userInteractionEnabled = NO;
            self.privacyWindow.hidden = NO;
        }
        self.privacyWindow.hidden = NO;
    });
}

- (void)removePrivacyScreen {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.privacyWindow) {
            self.privacyWindow.hidden = YES;
            self.privacyWindow = nil;
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
