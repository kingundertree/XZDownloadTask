//
//  ViewController.m
//  XZDownloadTask
//
//  Created by xiazer on 15/4/17.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "ViewController.h"
#import "XZDownloadManager.h"
#import "XZDownloadGroupManager.h"
#import "XZDownloadView.h"

////定义屏幕高度
//#define ScreenHeight [UIScreen mainScreen].bounds.size.height
////定义屏幕宽度
//#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
@property (nonatomic, strong) XZDownloadManager *downloadManager;
@property (nonatomic, strong) UIProgressView *progressView1;
@property (nonatomic, strong) UIProgressView *progressView2;
@property (nonatomic, strong) UIProgressView *progressView3;
@property (nonatomic, strong) UIProgressView *progressView4;
@property (nonatomic, strong) NSMutableArray *musicIdentifierArr;
@property (nonatomic, strong) NSMutableArray *downloadViewArr;
@end

@implementation ViewController

- (XZDownloadManager *)downloadManager {
    if (!_downloadManager) {
        _downloadManager = [[XZDownloadManager alloc] init];
    }
    
    return _downloadManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.musicIdentifierArr = [NSMutableArray array];
    self.downloadViewArr = [NSMutableArray array];
    
    for (NSInteger j = 0; j < 4; j++) {
        NSString* uniCode = [[NSProcessInfo processInfo] globallyUniqueString];
        [self.musicIdentifierArr addObject:uniCode];
        
        XZDownloadView *downloadView = [[XZDownloadView alloc] initWithFrame:CGRectMake(0, 100+60*j, ScreenWidth, 50)];
        [downloadView displayUIWithIdentifier:uniCode
                                   startClick:^(NSString *identifier) {
                                       NSLog(@"start-->>%@",identifier);
                                       [self startClick:identifier];
                                   } pauseClick:^(NSString *identifier) {
                                       NSLog(@"pause-->>%@",identifier);
                                   } resumeClick:^(NSString *identifier) {
                                       NSLog(@"resume-->>%@",identifier);
                                   } cancleClick:^(NSString *identifier) {
                                       NSLog(@"cancle-->>%@",identifier);
                                   }];
        [self.view addSubview:downloadView];
        [self.downloadViewArr addObject:downloadView];
    }
    
    NSLog(@"%@",self.musicIdentifierArr);
    
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+100;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(ScreenWidth*i/4, 350, ScreenWidth/4, 50);
        btn.backgroundColor = [UIColor blackColor];
        
        NSString *titStr;
        if (i == 0) {
            titStr = @"全部开始";
        } else if (i == 1) {
            titStr = @"全部暂停";
        } else if (i == 2) {
            titStr = @"重新下载";
        } else {
            titStr = @"全部取消";
        }
        [btn setTitle:titStr forState:UIControlStateNormal];
        btn.tintColor = [UIColor whiteColor];
        
        [self.view addSubview:btn];
    }
}

- (void)startClick:(NSString *)identifier {
    [self startDownload:[self getDownloadTaskIndex:identifier]];
}
- (void)pauseClick:(NSString *)identifier {
}
- (void)resumeClick:(NSString *)identifier {
}
- (void)cancleClick:(NSString *)identifier {
}

- (NSInteger)getDownloadTaskIndex:(NSString *)identifier {
    return [self.musicIdentifierArr indexOfObject:identifier];
}

- (void)btnClick:(id)sender {
//    UIButton *btn = (UIButton *)sender;
//    NSInteger tag = btn.tag;

}

- (void)startDownload:(NSInteger)index {
    NSString *music1 = @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/238979467/124380645248400128.mp3?xcode=a31af1dad0ce66f58e501bb39bd713e7a957e289de92d109&song_id=124380645";
    NSString *music2 = @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/239130183/1226741191429509661128.mp3?xcode=11cd45642bcebf4368254d6e7a4f74a9c3ba3c8b80064e3b&song_id=122674119";
    NSString *music3 = @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/240277173/2402770671429581661128.mp3?xcode=11cd45642bcebf43e12afa176a6962aaad0a5cf648f90713&song_id=240277067";
    NSString *music4 = @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/134423200/12152327672000128.mp3?xcode=b8a2a1a32cf60e30c8950b37b04a1ea81185dbd0cbb5163e&song_id=121523276";
    NSArray *musicUrlArr = [NSArray arrayWithObjects:music1,music2,music3,music4, nil];
    
    __weak typeof(self) this = self;
    
    if (index >= 0) {
        [[XZDownloadGroupManager shareInstance] addDownloadRequest:[musicUrlArr objectAtIndex:index]
                                                        identifier:[self.musicIdentifierArr objectAtIndex:index]
                                                        targetSelf:self
                                                      showProgress:YES
                                              isDownloadBackground:YES
                                                  downloadResponse:^(XZDownloadResponse *response) {
                                                      [this handleResponse:response];
                                                  }];
    } else {
        for (NSInteger i = 0; i < 4; i++) {
            [[XZDownloadGroupManager shareInstance] addDownloadRequest:[musicUrlArr objectAtIndex:i]
                                                            identifier:[self.musicIdentifierArr objectAtIndex:i]
                                                            targetSelf:self
                                                          showProgress:YES
                                                  isDownloadBackground:YES
                                                      downloadResponse:^(XZDownloadResponse *response) {
                                                          [this handleResponse:response];
                                                      }];
        }
    }
}

- (void)handleResponse:(XZDownloadResponse *)response {
    if (response.downloadStatus == XZDownloading) {
        XZDownloadView *downloadView = [self getDownloadView:response.identifier];
        downloadView.progressV = response.progress;
    }
}

- (XZDownloadView *)getDownloadView:(NSString *)identifier {
    XZDownloadView *downloadView;
    for (NSInteger i = 0; i < 4; i++) {
        XZDownloadView *view = (XZDownloadView *)[self.downloadViewArr objectAtIndex:i];
        if ([view.identifer isEqualToString:identifier]) {
            downloadView = view;
            
            continue;
        }
    }
    return downloadView;
}

- (void)pauseDownload:(NSInteger)index {
    [self.downloadManager pauseDownload];
}

- (void)resumeDownload:(NSInteger)index {
    [self.downloadManager resumeDownload];
}

- (void)cancleDownload:(NSInteger)index {
    [self.downloadManager cancleDownload];
}

- (void)showLocalNotification:(BOOL)downloadSuc {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification!=nil) {
        
        NSDate *now=[NSDate new];
        notification.fireDate=[now dateByAddingTimeInterval:6]; //触发通知的时间
        notification.repeatInterval = 0; //循环次数，kCFCalendarUnitWeekday一周一次
        
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = downloadSuc ? @"后台下载成功啦" : @"下载失败";
        notification.alertAction = @"打开";  //提示框按钮
        notification.hasAction = YES; //是否显示额外的按钮，为no时alertAction消失
        notification.applicationIconBadgeNumber = 1; //设置app图标右上角的数字
        
        //下面设置本地通知发送的消息，这个消息可以接受
        NSDictionary* infoDic = [NSDictionary dictionaryWithObject:@"value" forKey:@"key"];
        notification.userInfo = infoDic;
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
