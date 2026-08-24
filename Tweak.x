#import <UIKit/UIKit.h>

static void CNULog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documents stringByAppendingPathComponent:@"chatgpt_noupdate.log"];
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

static NSString *CNUTopVC(void) {
    UIViewController *top = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    return top ? NSStringFromClass(top.class) : @"(none)";
}

%ctor {
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
