//
//  XZDownloadElement.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/21.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZDownloadResponse.h"

@interface XZDownloadElement : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) id targert;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, copy) void(^downloadResponse)(XZDownloadResponse *response);

@end
