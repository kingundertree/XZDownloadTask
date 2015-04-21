//
//  XZDownloadManager.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^downloadSuccuss)(BOOL isSuccuss ,NSMutableDictionary *userInfo);
typedef void(^downloadFail)(BOOL isFail ,NSMutableDictionary *userInfo , NSString *errMsg);
typedef void(^downloadProgress)(double progress ,NSMutableDictionary *userInfo);

@interface XZDownloadManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *userInfo;

- (void)configDownloadInfo:(NSString *) downloadStr
               isDownloadBackground:(BOOL)isDownloadBackground
                  succuss:(void (^)(BOOL isSuccuss ,NSMutableDictionary *userInfo)) succuss
                     fail:(void(^)(BOOL isFail ,NSMutableDictionary *userInfo, NSString *errMsg)) fail
                 progress:(void(^)(double progress ,NSMutableDictionary *userInfo)) progress;

- (void)pauseDownload;
- (void)resumeDownload;
- (void)cancleDownload;
@end
