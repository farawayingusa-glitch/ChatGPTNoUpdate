#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>

static NSString *kLogPath = @"/var/mobile/Library/Preferences/ChatGPTNoUpdate.log";

@interface ChatGPTNoUpdatePrefsListController : PSListController
@end

@implementation ChatGPTNoUpdatePrefsListController

- (id)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)shareLog {
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:kLogPath]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂无日志"
                                                                       message:@"还没有日志。请先打开一次 ChatGPT 并触发更新弹窗。"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSURL *fileURL = [NSURL fileURLWithPath:kLogPath];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL]
                                                                      applicationActivities:nil];
    avc.popoverPresentationController.sourceView = self.view;
    [self presentViewController:avc animated:YES completion:nil];
}

- (void)clearLog {
    [[NSFileManager defaultManager] removeItemAtPath:kLogPath error:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已清除"
                                                                   message:@"日志已清空。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
