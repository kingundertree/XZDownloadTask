//
//  XZDownloadResponse.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, XZDownloadStatus) {
    XZDownloadSuccuss, // 下载成功
    XZDownloading, // 下载中
    XZDownloadFail // 下载失败
};

@interface XZDownloadResponse : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) id targert;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, assign) double progress;
@property (nonatomic, strong) NSString *downloadFileUrl;


@end
