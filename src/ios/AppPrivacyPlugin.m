#import <Cordova/CDV.h>

@interface AppPrivacyPlugin : CDVPlugin

@property (nonatomic, assign) BOOL privacyModeEnabled;
@property (nonatomic, strong) UIView *privacyView;

- (void)enablePrivacyMode:(CDVInvokedUrlCommand*)command;
- (void)disablePrivacyMode:(CDVInvokedUrlCommand*)command;

@end

@implementation AppPrivacyPlugin

- (void)pluginInitialize {
    // Подписываемся на события жизненного цикла приложения
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // Подписываемся на событие скриншота
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
    
    // Подписываемся на изменение статуса записи экрана (iOS 11+)
    if (@available(iOS 11.0, *)) {
        [[UIScreen mainScreen] addObserver:self
                                forKeyPath:@"captured"
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];
    }
    
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
        if (self.privacyView) {
            self.privacyView.hidden = YES;
            [self.privacyView removeFromSuperview];
            self.privacyView = nil;
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
