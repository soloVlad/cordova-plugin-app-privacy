#import <Cordova/CDV.h>

@interface AppPrivacyPlugin : CDVPlugin

@property (nonatomic, assign) BOOL privacyModeEnabled;
@property (nonatomic, strong) UIView *privacyView;

- (void)enablePrivacyMode:(CDVInvokedUrlCommand*)command;
- (void)disablePrivacyMode:(CDVInvokedUrlCommand*)command;

@end

@implementation AppPrivacyPlugin

- (void)pluginInitialize {
    // Register for app lifecycle notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
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
        if (!self.privacyView) {
            // Create a black view that covers the entire screen
            self.privacyView = [[UIView alloc] initWithFrame:self.viewController.view.bounds];
            self.privacyView.backgroundColor = [UIColor blackColor];
            self.privacyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        if (!self.privacyView.superview) {
            [self.viewController.view addSubview:self.privacyView];
        }
        self.privacyView.hidden = NO;
    });
}

- (void)removePrivacyScreen {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.privacyView) {
            self.privacyView.hidden = YES;
            [self.privacyView removeFromSuperview];
            self.privacyView = nil;
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end