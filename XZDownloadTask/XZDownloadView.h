//
//  XZDownloadView.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/21.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZDownloadView : UIView
@property (nonatomic, strong) NSString *identifer;
@property (nonatomic, assign) float progressV;

- (void)displayUIWithIdentifier:(NSString *)identifier
        startClick:(void(^)(NSString *identifier))startClick
       pauseClick:(void(^)(NSString *identifier))pauseClick
      resumeClick:(void(^)(NSString *identifier))resumeClick
      cancleClick:(void(^)(NSString *identifier))cancleClick;

@end
