//
//  SingleDownloadViewController.m
//  XZDownloadTask
//
//  Created by xiazer on 15/4/27.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "SingleDownloadViewController.h"
#import "XZDownloadManager.h"

//定义屏幕高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//定义屏幕宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width


@interface SingleDownloadViewController ()
@property (nonatomic, strong) XZDownloadManager *downloadManager;
@property (nonatomic, strong) UILabel *progressLab;
@property (nonatomic, assign) float downloadProgress;
@end

@implementation SingleDownloadViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"单任务下载";
    self.view.backgroundColor = [UIColor whiteColor];

    for (NSInteger i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, 100+60*i, ScreenWidth, 50);
        btn.backgroundColor = [UIColor blackColor];
        
        NSString *titStr;
        if (i == 0) {
            titStr = @"开始";
        } else if (i == 1) {
            titStr = @"暂停";
        } else if (i == 2) {
            titStr = @"重新下载";
        } else {
            titStr = @"取消";
        }
        [btn setTitle:titStr forState:UIControlStateNormal];
        btn.tintColor = [UIColor whiteColor];
        
        
        [self.view addSubview:btn];
    }
    
    self.progressLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, ScreenWidth, 50)];
    self.progressLab.backgroundColor = [UIColor blackColor];
    self.progressLab.textAlignment = NSTextAlignmentCenter;
    self.progressLab.textColor = [UIColor redColor];
    [self.view addSubview:self.progressLab];
}

- (void)btnClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    switch (tag) {
        case 0:
            [self startDownload];
            break;
        case 1:
            [self pauseDownload];
            break;
        case 2:
            [self resumeDownload];
            break;
        case 3:
            [self cancleDownload];
            break;
            
        default:
            break;
    }
}

- (void)startDownload {
    __weak typeof(self) this = self;
    
    NSString *imgStr = @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/240885332/124380645248400128.mp3?xcode=39485cd81627146b59a442d4041fa9d2b545e6e71c27bf77&song_id=124380645";
    
    
    [self.downloadManager configDownloadInfo:imgStr
                        isDownloadBackground:YES
                                  identifier:nil
                                     succuss:^(XZDownloadResponse *response) {
                                         NSLog(@"下载成功");
                                     } fail:^(XZDownloadResponse *response) {
                                         NSLog(@"下载失败");
                                     } progress:^(XZDownloadResponse *response) {
                                         this.downloadProgress = response.progress;
                                         
                                         NSString *proStr = [NSString stringWithFormat:@"%0.2f %@",response.progress*100,@"%"];
                                         NSLog(@"下载进度---%@",proStr);
                                         
                                         [this updateProgress];
                                     } cancle:^(XZDownloadResponse *response) {
                                         
                                     } pause:^(XZDownloadResponse *response) {
                                         
                                     } resume:^(XZDownloadResponse *response) {
                                         
                                     }];
    
}

- (void)updateProgress {
    self.progressLab.text = [NSString stringWithFormat:@"%0.2f",self.downloadProgress];
}

- (void)pauseDownload {
    [self.downloadManager pauseDownload];
}

- (void)resumeDownload {
    [self.downloadManager resumeDownload];
}

- (void)cancleDownload {
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
