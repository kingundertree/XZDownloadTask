//
//  XZDownloadManager.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^downloadSuccuss)(BOOL isSuccuss ,NSDictionary *userInfo);
typedef void(^downloadFail)(BOOL isFail ,NSDictionary *userInfo , NSString *errMsg);
typedef void(^downloadProgress)(double progress ,NSDictionary *userInfo);

@interface XZDownloadManager : NSObject

@property (nonatomic, strong) NSDictionary *userInfo;

- (void)congifDownloadInfo:(NSString *) downloadStr
               isDownloadBackground:(BOOL)isDownloadBackground
                  succuss:(void (^)(BOOL isSuccuss ,NSDictionary *userInfo)) succuss
                     fail:(void(^)(BOOL isFail ,NSDictionary *userInfo, NSString *errMsg)) fail
                 progress:(void(^)(double progress ,NSDictionary *userInfo)) progress;

- (void)pauseDownload;
- (void)resumeDownload;
- (void)cancleDownload;
- (void)restartDownload;
@end
