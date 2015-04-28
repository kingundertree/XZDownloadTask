//
//  MultDownloadViewController.m
//  XZDownloadTask
//
//  Created by xiazer on 15/4/27.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "MultDownloadViewController.h"
#import "XZDownloadManager.h"
#import "XZDownloadGroupManager.h"
#import "XZDownloadView.h"

@interface MultDownloadViewController ()
@property (nonatomic, strong) XZDownloadManager *downloadManager;
@property (nonatomic, strong) UIProgressView *progressView1;
@property (nonatomic, strong) UIProgressView *progressView2;
@property (nonatomic, strong) UIProgressView *progressView3;
@property (nonatomic, strong) UIProgressView *progressView4;
@property (nonatomic, strong) NSMutableArray *musicIdentifierArr;
@property (nonatomic, strong) NSMutableArray *downloadViewArr;
@end

@implementation MultDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"多任务下载";
    self.view.backgroundColor = [UIColor whiteColor];

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
                                       [self pauseClick:identifier];
                                   } resumeClick:^(NSString *identifier) {
                                       NSLog(@"resume-->>%@",identifier);
                                       [self resumeClick:identifier];
                                   } cancleClick:^(NSString *identifier) {
                                       NSLog(@"cancle-->>%@",identifier);
                                       [self cancleClick:identifier];
                                   }];
        [self.view addSubview:downloadView];
        [self.downloadViewArr addObject:downloadView];
    }
    
    for (NSInteger i = 0; i < self.downloadViewArr.count; i++) {
        XZDownloadView *downloadView = (XZDownloadView *)[self.downloadViewArr objectAtIndex:i];
        NSLog(@"self.downloadViewArr---->>%@/%@",downloadView,downloadView.identifer);
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
    [[XZDownloadGroupManager shareInstance] pauseDownload:identifier];
}
- (void)resumeClick:(NSString *)identifier {
    [[XZDownloadGroupManager shareInstance] resumeDownload:identifier];
}
- (void)cancleClick:(NSString *)identifier {
    [[XZDownloadGroupManager shareInstance] cancleDownload:identifier];
}

- (NSInteger)getDownloadTaskIndex:(NSString *)identifier {
    return [self.musicIdentifierArr indexOfObject:identifier];
}

- (void)btnClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    if (tag == 100) {
        [self startDownload:-1];
    } else if (tag == 101) {
        
    } else if (tag == 102) {
        
    } else {
        
    }
}

- (void)startDownload:(NSInteger)index {
    NSString *music1 = @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/134423200/12152327672000128.mp3?xcode=1cfc4630c94b7e810406d6bd91c826431185dbd0cbb5163e&song_id=121523276";
    NSString *music2 = @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/240373726/2403730813600128.mp3?xcode=1cfc4630c94b7e817b1e03c7a13241fff4b09a757b6f1d9e&song_id=240373081";
    NSString *music3 = @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/240277173/240277067126000128.mp3?xcode=1cfc4630c94b7e8198fbc7ee106a0bc7ad0a5cf648f90713&song_id=240277067";
    NSString *music4 = @"https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf";
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
        NSLog(@"下载任务ing%@",response.identifier);
        XZDownloadView *downloadView = [self getDownloadView:response.identifier];
        downloadView.progressV = response.progress;
    } else if (response.downloadStatus == XZDownloadSuccuss) {
        NSLog(@"下载任务成功%@",response.identifier);
        XZDownloadView *downloadView = [self getDownloadView:response.identifier];
        downloadView.progressV = 1.0;
    } else if (response.downloadStatus == XZDownloadBackgroudSuccuss) {
        NSLog(@"后台下载任务成功%@",response.identifier);
        [self showLocalNotification:YES];
        XZDownloadView *downloadView = [self getDownloadView:response.identifier];
        downloadView.progressV = 1.0;
    } else if (response.downloadStatus == XZDownloadFail) {
        NSLog(@"下载任务失败%@",response.identifier);
        [self showLocalNotification:NO];
    } else if (response.downloadStatus == XZDownloadCancle) {
        NSLog(@"下载任务取消%@",response.identifier);
    } else if (response.downloadStatus == XZDownloadPause) {
        NSLog(@"下载任务暂停%@",response.identifier);
    } else if (response.downloadStatus == XZDownloadResume) {
        NSLog(@"下载任务重启%@",response.identifier);
    }
}

- (XZDownloadView *)getDownloadView:(NSString *)identifier {
    XZDownloadView *downloadView;
    for (NSInteger i = 0; i < 4; i++) {
        XZDownloadView *view = (XZDownloadView *)[self.downloadViewArr objectAtIndex:i];
        if ([view.identifer isEqualToString:identifier]) {
            downloadView = view;
            
            break;
        }
    }
    return downloadView;
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

- (XZDownloadManager *)downloadManager {
    if (!_downloadManager) {
        _downloadManager = [[XZDownloadManager alloc] init];
    }
    
    return _downloadManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
