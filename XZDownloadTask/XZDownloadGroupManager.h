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
@property (nonatomic, strong) NSMutableArray *downloadManagerArr;



+ (id)shareInstance;

- (void)addDownloadRequest:(NSString *)downloadStr
                identifier:(NSString *)identifier
      isDownloadBackground:(BOOL)isDownloadBackground
          downloadResponse:(void(^)(XZDownloadResponse *response))downloadResponse;


@end
