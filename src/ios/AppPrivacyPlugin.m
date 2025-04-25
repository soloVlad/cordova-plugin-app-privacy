#import <Cordova/CDV.h>

@interface AppPrivacyPlugin : CDVPlugin
@property (nonatomic, strong) UIView *privacyView;
- (void)enablePrivacyMode:(CDVInvokedUrlCommand*)command;
- (void)disablePrivacyMode:(CDVInvokedUrlCommand*)command;
@end

@implementation AppPrivacyPlugin

- (void)enablePrivacyMode:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.privacyView) {
            self.privacyView = [[UIView alloc] initWithFrame:self.viewController.view.bounds];
            self.privacyView.backgroundColor = [UIColor blackColor]; // or use splash image
            self.privacyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.viewController.view addSubview:self.privacyView];
        }
        self.privacyView.hidden = NO;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

- (void)disablePrivacyMode:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.privacyView.hidden = YES;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

@end