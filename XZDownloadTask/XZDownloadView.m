//
//  XZDownloadView.m
//  XZDownloadTask
//
//  Created by xiazer on 15/4/21.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "XZDownloadView.h"

@interface XZDownloadView ()
@property (nonatomic, copy) void(^startClick)(NSString *identifier);
@property (nonatomic, copy) void(^pauseClick)(NSString *identifier);
@property (nonatomic, copy) void(^resumeClick)(NSString *identifier);
@property (nonatomic, copy) void(^cancleClick)(NSString *identifier);
@property (nonatomic, strong) UIProgressView *showProgressView;
@property (nonatomic, assign) float lastProgressV;

@end

@implementation XZDownloadView

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(ScreenWidth*i/4, 0, ScreenWidth/4, 50);
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
        
        [self addSubview:btn];
    }
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 50, ScreenWidth, 5)];
    progressView.progress = self.progressV;
    progressView.progressTintColor = [UIColor redColor];
    [self addSubview:progressView];
    self.showProgressView = progressView;
}

- (void)setProgressV:(float)progressV {
    if (progressV >= _lastProgressV+0.05 || _progressV >= 0.98 || _progressV == 0) {
        _progressV = progressV;
        _lastProgressV = _progressV;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.showProgressView setProgress:_progressV animated:YES];
        });
    }
}

- (void)displayUIWithIdentifier:(NSString *)identifier
                     startClick:(void(^)(NSString *identifier))startClick
                     pauseClick:(void(^)(NSString *identifier))pauseClick
                    resumeClick:(void(^)(NSString *identifier))resumeClick
                    cancleClick:(void(^)(NSString *identifier))cancleClick {

    self.identifer = identifier;
    self.startClick = startClick;
    self.pauseClick = pauseClick;
    self.resumeClick = resumeClick;
    self.cancleClick = cancleClick;
}

- (void)btnClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;

    switch (tag) {
        case 0:
            self.startClick(self.identifer);
            break;
        case 1:
            self.pauseClick(self.identifer);
            break;
        case 2:
            self.resumeClick(self.identifer);
            break;
        case 3:
            self.startClick(self.identifer);
            break;
            
        default:
            break;
    }
}

@end
