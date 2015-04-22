//
//  XZDownloadManager.m
//  XZDownloadTask
//
//  Created by xiazer on 15/4/20.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "XZDownloadManager.h"
#import "AppDelegate.h"

@interface XZDownloadManager () <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSURLSessionDownloadTask *backgroundSessionTask;

@property (nonatomic, strong) NSURLSession *normalSession;
@property (nonatomic, strong) NSURLSessionDownloadTask *normalSessionTask;
@property (nonatomic, strong) NSURLSessionDownloadTask *resumeSessionTask;
@property (nonatomic, strong) NSData *partialData;
@property (nonatomic, copy) void(^downloadSuccuss)(XZDownloadResponse *response);
@property (nonatomic, copy) void(^downloadFail)(XZDownloadResponse *response);
@property (nonatomic, copy) void(^downloadProgress)(XZDownloadResponse *response);
@property (nonatomic, assign) double lastProgress;
@property (nonatomic, strong) XZDownloadResponse *downloadResponse;
@end

@implementation XZDownloadManager


- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundSession.sessionDescription = @"XZDownloadUrlSession";
    }
    
    return self;
}

- (NSURLSession *)getBackgroundSession:(NSString *)identifier {
    NSURLSession *backgroundSession = nil;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"background-NSURLSession-%@",identifier]];
    backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    return backgroundSession;
}


- (NSURLSession *)normalSession {
    if (!_normalSession) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _normalSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        _normalSession.sessionDescription = @"normal NSURLSession";
    }
    
    return _normalSession;
}

- (void)configDownloadInfo:(NSString *) downloadStr isDownloadBackground:(BOOL)isDownloadBackground identifier:(NSString *)identifier succuss:(void (^)(XZDownloadResponse *response)) succuss fail:(void(^)(XZDownloadResponse *response)) fail progress:(void(^)(XZDownloadResponse *response)) progress {
    self.downloadSuccuss = succuss;
    self.downloadFail = fail;
    self.downloadProgress = progress;

    self.identifier = identifier;
    
    if (isDownloadBackground) {
        [self startBackgroundDownload:downloadStr identifier:self.identifier];
    } else {
        [self startNormalDownload:downloadStr];
    }
}

- (void)startBackgroundDownload:(NSString *)downloadStr identifier:(NSString *)identifier {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadStr]];
    self.backgroundSession = [self getBackgroundSession:identifier];
    self.backgroundSessionTask = [self.backgroundSession downloadTaskWithRequest:request];
    [self.backgroundSessionTask resume];
}

- (void)startNormalDownload:(NSString *)downloadStr {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadStr]];
    self.normalSessionTask = [self.normalSession downloadTaskWithRequest:request];
    [self.normalSessionTask resume];
}

- (void)pauseDownload {
    __weak typeof(self) this = self;
    if (self.normalSessionTask) {
        [self.normalSessionTask cancelByProducingResumeData:^(NSData *resumeData) {
            this.partialData = resumeData;
            this.normalSessionTask = nil;
        }];
    } else if (self.backgroundSessionTask) {
        [self.backgroundSessionTask cancelByProducingResumeData:^(NSData *resumeData) {
            this.partialData = resumeData;
            this.backgroundSessionTask = nil;
        }];
    }
}

- (void)resumeDownload {
    if (!self.resumeSessionTask) {
        if (self.partialData) {
            self.resumeSessionTask = [self.normalSession downloadTaskWithResumeData:self.partialData];
            
            [self.resumeSessionTask resume];
        } else {
            self.downloadFail([self getDownloadRespose:XZDownloadFail identifier:self.identifier progress:0.00 downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"没有需要恢复的任务"]);
        }
    } else {
        self.downloadFail([self getDownloadRespose:XZDownloadFail identifier:self.identifier progress:0.00 downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"没有需要恢复的任务"]);
    }
}

- (void)cancleDownload {
    if (self.normalSessionTask) {
        [self.normalSessionTask cancel];
        self.normalSessionTask = nil;
    } else if (self.resumeSessionTask) {
        self.partialData = nil;
        [self.resumeSessionTask cancel];
        self.resumeSessionTask = nil;
    } else if (self.backgroundSessionTask) {
        [self.backgroundSessionTask cancel];
        self.backgroundSessionTask = nil;
    }
}

- (XZDownloadResponse *)downloadResponse {
    if (!_downloadResponse) {
        _downloadResponse = [[XZDownloadResponse alloc] init];
    }
    
    return _downloadResponse;
}

- (XZDownloadResponse *)getDownloadRespose:(XZDownloadStatus)status identifier:(NSString *)identifier progress:(double)progress downloadUrl:(NSString *)downloadUrl downloadSaveFileUrl:(NSURL *)downloadSaveFileUrl
                              downloadData:(NSData *)downloadData downloadResult:(NSString *)downloadResult {
    self.downloadResponse.downloadStatus = status;
    self.downloadResponse.identifier = identifier;
    self.downloadResponse.progress = progress;
    self.downloadResponse.downloadUrl = downloadUrl;
    self.downloadResponse.downloadSaveFileUrl = downloadSaveFileUrl;
    self.downloadResponse.downloadData = downloadData;
    self.downloadResponse.downloadResult = downloadResult;
    
    
    return self.downloadResponse;
};


#pragma mark - NSURLSessionDownloadDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double currentProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSLog(@"%@---%0.2f",self.identifier,currentProgress);

    if (currentProgress >= self.lastProgress+0.05 || currentProgress == 1.00 || currentProgress == 0) {
        self.lastProgress = currentProgress;
        self.downloadProgress([self getDownloadRespose:XZDownloading identifier:self.identifier progress:currentProgress downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"下载中"]);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // 下载失败
    self.downloadFail([self getDownloadRespose:XZDownloadFail identifier:self.identifier progress:0.00 downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"下载失败"]);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // We've successfully finished the download. Let's save the file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = URLs[0];
    
    NSURL *destinationPath = [documentsDirectory URLByAppendingPathComponent:self.identifier];
    NSError *error;
    
    // Make sure we overwrite anything that's already there
    [fileManager removeItemAtURL:destinationPath error:NULL];
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationPath error:&error];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 此处可更新UI
        });
        self.downloadSuccuss([self getDownloadRespose:XZDownloadSuccuss identifier:self.identifier progress:1.00 downloadUrl:nil downloadSaveFileUrl:destinationPath downloadData:nil downloadResult:@"下载成功"]);
    } else {
        NSLog(@"Couldn't copy the downloaded file");
        self.downloadFail([self getDownloadRespose:XZDownloadFail identifier:self.identifier progress:0.00 downloadUrl:nil downloadSaveFileUrl:destinationPath downloadData:nil downloadResult:@"下载失败"]);
    }
    
    if(downloadTask == self.normalSessionTask) {
        self.normalSessionTask = nil;
    } else if (downloadTask == self.resumeSessionTask) {
        self.resumeSessionTask = nil;
        self.partialData = nil;
    } else if (session == self.backgroundSession) {
        self.backgroundSessionTask = nil;

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.backgroundURLSessionCompletionHandler) {
            void (^handler)() = appDelegate.backgroundURLSessionCompletionHandler;
            appDelegate.backgroundURLSessionCompletionHandler = nil;
            handler();
            
            self.downloadSuccuss([self getDownloadRespose:XZDownloadBackgroudSuccuss identifier:self.identifier progress:1.00 downloadUrl:nil downloadSaveFileUrl:destinationPath downloadData:nil downloadResult:@"后台下载下载成功"]);
            
            NSLog(@"后台下载完成");
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // 后台处理下载任务
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}


@end
