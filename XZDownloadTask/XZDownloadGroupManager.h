//
//  XZDownloadGroupManager.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZDownloadResponse.h"

@interface XZDownloadGroupManager : NSObject

typedef void(^downloadResponse)(XZDownloadResponse *response);

+ (id)shareInstance;

// 下载请求
- (void)addDownloadRequest:(NSString *)downloadStr
                identifier:(NSString *)identifier
                targetSelf:(id)targetSelf
              showProgress:(BOOL)showProgress
      isDownloadBackground:(BOOL)isDownloadBackground
          downloadResponse:(void(^)(XZDownloadResponse *response))downloadResponse;

// 所有下载任务控制
- (void)pauseAllDownloadRequest;
- (void)cancleAllDownloadRequest;
- (void)resumeAllDownloadRequest;

// 单个下载任务控制
- (void)pauseDownload:(NSString *)identifier;
- (void)resumeDownload:(NSString *)identifier;
- (void)cancleDownload:(NSString *)identifier;

@end
