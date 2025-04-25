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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
        if (@available(iOS 11.0, *)) {
            [[UIScreen mainScreen] addObserver:self forKeyPath:@"captured" options:NSKeyValueObservingOptionNew context:nil];
        }
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
- (void)userDidTakeScreenshot:(NSNotification *)notification {
    if (!self.privacyModeEnabled) {
        return; // Если режим приватности выключен — ничего не делаем
    }
    
    NSLog(@"[AppPrivacyPlugin] Screenshot detected!");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self applyPrivacyScreen];
        
        // Скрываем overlay через 2 секунды
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removePrivacyScreen];
        });
    });
}

// Обработка изменения статуса записи экрана
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"captured"]) {
        BOOL isCaptured = [change[NSKeyValueChangeNewKey] boolValue];
        NSLog(@"[AppPrivacyPlugin] Screen recording status changed: %@", isCaptured ? @"Started" : @"Stopped");
        
        if (!self.privacyModeEnabled) {
            return; // Если режим приватности выключен — не реагируем
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isCaptured) {
                [self applyPrivacyScreen];
            } else {
                [self removePrivacyScreen];
            }
        });
    }
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
    if (@available(iOS 11.0, *)) {
        [[UIScreen mainScreen] removeObserver:self forKeyPath:@"captured"];
    }
}

@end
