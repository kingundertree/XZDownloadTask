//
//  XZDownloadManager.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^downloadSuccuss)(BOOL isSuccuss);
typedef void(^downloadFail)(BOOL isFail, NSString *errMsg);
typedef void(^downloadProgress)(double progress);

@interface XZDownloadManager : NSObject


- (void)congifDownloadInfo:(NSString *) downloadStr
               isDownloadBackground:(BOOL)isDownloadBackground
                  succuss:(void (^)(BOOL isSuccuss)) succuss
                     fail:(void(^)(BOOL isFail, NSString *errMsg)) fail
                 progress:(void(^)(double progress)) progress;

- (void)pauseDownload;
- (void)resumeDownload;
- (void)cancleDownload;
- (void)restartDownload;
@end
