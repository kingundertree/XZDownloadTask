//
//  XZDownloadGroupManager.m
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "XZDownloadGroupManager.h"
#import "XZDownloadManager.h"

@implementation XZDownloadGroupManager


+ (instancetype)shareInstance {
    static XZDownloadGroupManager *downloadGroupManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadGroupManager = [[XZDownloadGroupManager alloc] init];
    });
    return downloadGroupManager;
}

- (void)initData {
    self.downloadManagerArr = [NSMutableArray array];
}

- (void)addDownloadRequest:(NSString *)downloadStr
                identifier:(NSString *)identifier
      isDownloadBackground:(BOOL)isDownloadBackground
          downloadResponse:(void(^)(XZDownloadResponse *response))downloadResponse {

}



@end
