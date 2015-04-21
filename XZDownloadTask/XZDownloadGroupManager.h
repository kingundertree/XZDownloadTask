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

- (void)addDownloadRequest:(NSString *)downloadStr
                identifier:(NSString *)identifier
                targetSelf:(id)targetSelf
              showProgress:(BOOL)showProgress
      isDownloadBackground:(BOOL)isDownloadBackground
          downloadResponse:(void(^)(XZDownloadResponse *response))downloadResponse;


- (void)pauseDownload:(NSString *)identifier;
- (void)resumeDownload:(NSString *)identifier;
- (void)cancleDownload:(NSString *)identifier;

@end
