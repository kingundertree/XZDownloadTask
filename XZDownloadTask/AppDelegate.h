//
//  AppDelegate.h
//  XZDownloadTask
//
//  Created by xiazer on 15/4/17.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy) void (^backgroundURLSessionCompletionHandler)();


@end

