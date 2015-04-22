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

@interface XZDownloadManager : NSObject

@property (nonatomic, strong) NSString *identifier;

- (void)configDownloadInfo:(NSString *) downloadStr
               isDownloadBackground:(BOOL)isDownloadBackground
                  identifier:(NSString *)identifier
                  succuss:(void (^)(XZDownloadResponse *response)) succuss
                     fail:(void(^)(XZDownloadResponse *response)) fail
                 progress:(void(^)(XZDownloadResponse *response)) progress;

- (void)pauseDownload;
- (void)resumeDownload;
- (void)cancleDownload;
@end
