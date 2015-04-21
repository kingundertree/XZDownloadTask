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

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              identifier,@"identifier", nil];

    __weak typeof(self) this = self;
    XZDownloadManager *downloadManager = [[XZDownloadManager alloc] init];
    downloadManager.userInfo = userInfo;
    [downloadManager configDownloadInfo:downloadStr
                   isDownloadBackground:isDownloadBackground
                                succuss:^(BOOL isSuccuss, NSDictionary *userInfo) {
                                    [this downloadSuccuss:userInfo];
                                } fail:^(BOOL isFail, NSDictionary *userInfo, NSString *errMsg) {
                                    [this downloadFail:userInfo];
                                } progress:^(double progress, NSDictionary *userInfo) {
                                    if (showProgress) {
                                        [self downloadIng:progress userInfo:userInfo];
                                    }
                                }];
    
    NSDictionary *downloadManagerDic = [NSDictionary dictionaryWithObjectsAndKeys:downloadManager,identifier, nil];
    [self.downloadManagerArr addObject:downloadManagerDic];
}
#pragma mark - 下载基本方法，批量任务处理
- (void)cancleAllDownloadRequest {
    __weak typeof(self) this = self;
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XZDownloadManager *downloadManager = (XZDownloadManager *)obj;
        [downloadManager cancleDownload];
        
        NSString *identifier = downloadManager.userInfo[@"identifier"];
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
- (void)downloadSuccuss:(NSDictionary *)userInfo {
    XZDownloadResponse *downloadResponse = [self getSuccussDownloadResponse:userInfo];
    self.downloadResponse(downloadResponse);
    
    [self removeDownloadTask:userInfo[@"identifier"]];
}

- (void)downloadFail:(NSDictionary *)userInfo {
    XZDownloadResponse *downloadResponse = [self getFailDownloadResponse:userInfo];
    self.downloadResponse(downloadResponse);
    
    [self removeDownloadTask:userInfo[@"identifier"]];
}

- (void)downloadIng:(double)progress userInfo:(NSDictionary *)userInfo {
    XZDownloadResponse *downloadResponse = [self getDownloadingResponse:progress userInfo:userInfo];
    self.downloadResponse(downloadResponse);
}

#pragma mark - 下载相关对象生成
- (XZDownloadResponse *)getSuccussDownloadResponse:(NSDictionary *)userInfo {
    XZDownloadResponse *response = [[XZDownloadResponse alloc] init];
    response.downloadStatus = XZDownloadSuccuss;
    response.progress = 1.00;
    response.identifier = userInfo[@"identifier"];
    response.downloadUrl = userInfo[@"downloadFileUrl"];
    
    return response;
}

- (XZDownloadResponse *)getFailDownloadResponse:(NSDictionary *)userInfo {
    XZDownloadResponse *response = [[XZDownloadResponse alloc] init];
    response.downloadStatus = XZDownloadFail;
    response.progress = 0.00;
    response.identifier = userInfo[@"identifier"];
    
    return response;
}

- (XZDownloadResponse *)getDownloadingResponse:(double)progress userInfo:(NSDictionary *)userInfo {
    XZDownloadResponse *response = [[XZDownloadResponse alloc] init];
    response.downloadStatus = XZDownloading;
    response.progress = progress;
    response.identifier = userInfo[@"identifier"];
    
    return response;
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
