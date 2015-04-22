//
//  XZDownloadManager.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZDownloadResponse.h"

typedef void(^downloadSuccuss)(XZDownloadResponse *response);
typedef void(^downloadFail)(XZDownloadResponse *response);
typedef void(^downloadProgress)(XZDownloadResponse *response);
typedef void(^downloadCancle)(XZDownloadResponse *response);
typedef void(^downloadPause)(XZDownloadResponse *response);
typedef void(^downloadResume)(XZDownloadResponse *response);

@interface XZDownloadManager : NSObject

@property (nonatomic, strong) NSString *identifier;

- (void)configDownloadInfo:(NSString *) downloadStr
               isDownloadBackground:(BOOL)isDownloadBackground
                  identifier:(NSString *)identifier
                  succuss:(void (^)(XZDownloadResponse *response)) succuss
                     fail:(void(^)(XZDownloadResponse *response)) fail
                 progress:(void(^)(XZDownloadResponse *response)) progress
                    cancle:(void(^)(XZDownloadResponse *response)) cancle
                     pause:(void(^)(XZDownloadResponse *response)) pause
                     resume:(void(^)(XZDownloadResponse *response)) resume;

- (void)pauseDownload;
- (void)resumeDownload;
- (void)cancleDownload;
@end
