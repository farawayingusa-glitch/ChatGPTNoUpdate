#import <UIKit/UIKit.h>
#import <substrate.h>

// 共享日志路径：Settings 的偏好目录，设置面板也能读写
static NSString *CNULogPath(void) {
    return @"/var/mobile/Library/Preferences/ChatGPTNoUpdate.log";
}

static void CNULog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSString *path = CNULogPath();
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        [fm createFileAtPath:path contents:nil attributes:nil];
    }
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (fh) {
        [fh seekToEndOfFile];
        NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [NSDate date], message];
        [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [fh closeFile];
    }
    NSLog(@"[CNU] %@", message);
}

// 沙盒放行：ChatGPT 是沙盒 App，默认写不到共享目录，
// 这里放行文件类操作（个人越狱机通用做法）。
static int (*orig_sandbox_check)(pid_t, const char *, int, void *);
static int my_sandbox_check(pid_t pid, const char *operation, int type, void *arg) {
    if (operation != NULL) {
        if (strcmp(operation, "file-write-create") == 0 ||
            strcmp(operation, "file-write-data") == 0 ||
            strcmp(operation, "file-write-unlink") == 0 ||
            strcmp(operation, "file-read-data") == 0 ||
            strcmp(operation, "file-read-metadata") == 0) {
            return 0;
        }
    }
    return orig_sandbox_check(pid, operation, type, arg);
}

extern int sandbox_check(pid_t pid, const char *operation, int type, ...);

static NSString *CNUTopVC(void) {
    UIWindow *keyWindow = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        if (windowScene.activationState != UISceneActivationStateForegroundActive) {
            continue;
        }
        for (UIWindow *window in windowScene.windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        if (keyWindow) {
            break;
        }
    }
    UIViewController *top = keyWindow.rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    return top ? NSStringFromClass(top.class) : @"(none)";
}

%ctor {
    MSHookFunction((void *)sandbox_check, (void *)my_sandbox_check, (void **)&orig_sandbox_check);
    CNULog(@"== ChatGPTNoUpdate loaded ==");
}

%hook UIViewController
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    CNULog(@"present [%@] from top [%@]", NSStringFromClass(viewControllerToPresent.class), CNUTopVC());
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alert = (UIAlertController *)viewControllerToPresent;
        CNULog(@"  alert title=%@ message=%@", alert.title, alert.message);
        for (UIAlertAction *action in alert.actions) {
            CNULog(@"  action=%@ style=%ld", action.title, (long)action.style);
        }
    }
    %orig;
}
%end

%hook UIAlertController
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle {
    if (title.length || message.length) {
        CNULog(@"UIAlertController init title=%@ message=%@", title, message);
    }
    return %orig;
}
%end
