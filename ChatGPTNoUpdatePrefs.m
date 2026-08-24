#import <UIKit/UIKit.h>

// 不链接 Preferences 私有框架（Xcode SDK 下 Theos 找不到），
// 仅声明接口，运行时 Settings 自带真实 PSListController。
@interface PSListController : UIViewController
- (id)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
@end

// 类名与 bundle 同名，作为 principal class，PreferenceLoader 才能实例化
@interface ChatGPTNoUpdatePrefs : PSListController
@end

static NSString *kLogPath = @"/var/mobile/Library/Preferences/ChatGPTNoUpdate.log";

@implementation ChatGPTNoUpdatePrefs

- (id)specifiers {
    // 用 KVC 访问真实 _specifiers，避免声明假 ivar 导致偏移错误
    id existing = [self valueForKey:@"specifiers"];
    if (!existing) {
        existing = [self loadSpecifiersFromPlistName:@"Root" target:self];
        [self setValue:existing forKey:@"specifiers"];
    }
    return existing;
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
