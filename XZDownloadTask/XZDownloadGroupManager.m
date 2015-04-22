//
//  XZDownloadGroupManager.m
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "XZDownloadGroupManager.h"
#import "XZDownloadManager.h"
#import "XZDownloadElement.h"

@interface XZDownloadGroupManager ()
@property (nonatomic, strong) NSMutableArray *downloadManagerArr;
@property (nonatomic, strong) NSMutableArray *downloadElementArr;
@property (nonatomic, copy) void(^downloadResponse)(XZDownloadResponse *response);
@end

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

#pragma mark - 下载请求
- (void)addDownloadRequest:(NSString *)downloadStr
                identifier:(NSString *)identifier
                targetSelf:(id)targetSelf
              showProgress:(BOOL)showProgress
      isDownloadBackground:(BOOL)isDownloadBackground
          downloadResponse:(void(^)(XZDownloadResponse *response))downloadResponse {
    self.downloadResponse = downloadResponse;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak typeof(self) this = self;
        XZDownloadManager *downloadManager = [[XZDownloadManager alloc] init];
        [downloadManager configDownloadInfo:downloadStr
                       isDownloadBackground:isDownloadBackground
                                 identifier:identifier
                                    succuss:^(XZDownloadResponse *response) {
                                        [this downloadSuccuss:response];
                                    } fail:^(XZDownloadResponse *response) {
                                        [this downloadFail:response];
                                    } progress:^(XZDownloadResponse *response) {
                                        if (showProgress) {
                                            [self downloadIng:response];
                                        }
                                    }];
        
        NSDictionary *downloadManagerDic = [NSDictionary dictionaryWithObjectsAndKeys:downloadManager,identifier, nil];
        [self.downloadManagerArr addObject:downloadManagerDic];
    });
}
#pragma mark - 下载基本方法，批量任务处理
- (void)cancleAllDownloadRequest {
    __weak typeof(self) this = self;
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XZDownloadManager *downloadManager = (XZDownloadManager *)obj;
        [downloadManager cancleDownload];
        
        NSString *identifier = downloadManager.identifier;
        [this removeDownloadTask:identifier];
    }];
}
- (void)restartAllDownloadRequest {
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XZDownloadManager *downloadManager = (XZDownloadManager *)obj;
        [downloadManager resumeDownload];
    }];
}

#pragma mark - 下载基本方法，暂停、重启、取消、
- (void)pauseDownload:(NSString *)identifier {
    XZDownloadManager *downloadManager = [self getDownloadManager:identifier];
    [downloadManager pauseDownload];
    
    [self removeDownloadTask:identifier];
}
- (void)resumeDownload:(NSString *)identifier {
    XZDownloadManager *downloadManager = [self getDownloadManager:identifier];
    [downloadManager resumeDownload];
}
- (void)cancleDownload:(NSString *)identifier {
    XZDownloadManager *downloadManager = [self getDownloadManager:identifier];
    [downloadManager cancleDownload];
    
    [self removeDownloadTask:identifier];
}

#pragma mark - 下载类管理
- (void)addDownloadRequestElementWith:(NSString *)identifier targetSelf:(id)targetSelf downloadResponse:(void(^)(XZDownloadResponse *response))downloadResponse {
    
    XZDownloadElement *element = [[XZDownloadElement alloc] init];
    element.identifier = identifier;
    element.targert = targetSelf;
    element.downloadResponse = downloadResponse;
    
    [self.downloadElementArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:element,identifier, nil]];
}

#pragma mark - 下载成功失败进度处理
- (void)downloadSuccuss:(XZDownloadResponse *)response {
    self.downloadResponse(response);
    
    [self removeDownloadTask:response.identifier];
}

- (void)downloadFail:(XZDownloadResponse *)response {
    self.downloadResponse(response);
    
    [self removeDownloadTask:response.identifier];
}

- (void)downloadIng:(XZDownloadResponse *)response {
    self.downloadResponse(response);
}

- (XZDownloadManager *)getDownloadManager:(NSString *)identifier {
    XZDownloadManager *downloadManager;
    
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *downloadElement = (NSDictionary *)obj;
        if ([downloadElement[@"identifier"] isEqualToString:identifier]) {
            downloadElement = [self.downloadManagerArr objectAtIndex:idx];
            
            *stop = YES;
        }
    }];
    
    return downloadManager;
}

- (XZDownloadElement *)getDownloadElement:(NSString *)identifier {
    XZDownloadElement *downloadElement;
    
    [self.downloadElementArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *downloadElement = (NSDictionary *)obj;
        if ([downloadElement[@"identifier"] isEqualToString:identifier]) {
            downloadElement = [self.downloadElementArr objectAtIndex:idx];

            *stop = YES;
        }
    }];
    
    return downloadElement;
}

#pragma mark - 删除下载任务
- (void)removeDownloadTask:(NSString *)identifier {
    __weak typeof(self) this = self;
    // 删除下载任务
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *downloadManager = (NSDictionary *)obj;
        if ([downloadManager[@"identifier"] isEqualToString:identifier]) {
            [this.downloadManagerArr removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    
    //删除下载对应的element
    [self.downloadElementArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *downloadElement = (NSDictionary *)obj;
        if ([downloadElement[@"identifier"] isEqualToString:identifier]) {
            [this.downloadElementArr removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
}

@end
