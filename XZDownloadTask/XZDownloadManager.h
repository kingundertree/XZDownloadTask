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
typedef void(^downloadProgress)(float progress);

@interface XZDownloadManager : NSObject


- (void)congiDownloadInfo:(NSString *) downloadStr
               isDownload:(BOOL)isDownload
                  succuss:(void (^)(BOOL isSuccuss)) succuss
                     fail:(void(^)(BOOL isFail, NSString *errMsg)) fail
                 progress:(void(^)(float progress)) progress;

@end
