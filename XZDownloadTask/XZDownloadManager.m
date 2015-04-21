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
@property (nonatomic, copy) void(^downloadSuccuss)(BOOL isSuccuss ,NSMutableDictionary *userInfo);
@property (nonatomic, copy) void(^downloadFail)(BOOL isFail ,NSMutableDictionary *userInfo, NSString *errMsg);
@property (nonatomic, copy) void(^downloadProgress)(double progress ,NSMutableDictionary *userInfo);
@end

@implementation XZDownloadManager


- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundSession.sessionDescription = @"XZDownloadUrlSession";
    }
    
    return self;
}

- (NSURLSession *)backgroundSession {
    static NSURLSession *backgroundSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"background NSURLSession"];
        backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    
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

- (void)configDownloadInfo:(NSString *) downloadStr isDownloadBackground:(BOOL)isDownloadBackground succuss:(void (^)(BOOL isSuccuss ,NSMutableDictionary *userInfo)) succuss fail:(void(^)(BOOL isFail ,NSMutableDictionary *userInfo, NSString *errMsg)) fail progress:(void(^)(double progress ,NSMutableDictionary *userInfo)) progress {
    self.downloadSuccuss = succuss;
    self.downloadFail = fail;
    self.downloadProgress = progress;

    if (isDownloadBackground) {
        [self startBackgroundDownload:downloadStr];
    } else {
        [self startNormalDownload:downloadStr];
    }
}

- (void)startBackgroundDownload:(NSString *)downloadStr {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadStr]];
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
            self.downloadFail(YES, self.userInfo, @"没有需要恢复的任务");
        }
    } else {
        self.downloadFail(YES, self.userInfo, @"没有需要恢复的任务");
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

#pragma mark - NSURLSessionDownloadDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double currentProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    self.downloadProgress(currentProgress, self.userInfo);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // 下载失败
    self.downloadFail(YES, self.userInfo, @"下载失败");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // We've successfully finished the download. Let's save the file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = URLs[0];
    
    NSURL *destinationPath = [documentsDirectory URLByAppendingPathComponent:[location lastPathComponent]];
    NSError *error;
    
    // Make sure we overwrite anything that's already there
    [fileManager removeItemAtURL:destinationPath error:NULL];
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationPath error:&error];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 此处可更新UI
        });
        [self.userInfo addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:destinationPath,@"downloadFileUrl", nil]];
        self.downloadSuccuss(YES, self.userInfo);
    } else {
        NSLog(@"Couldn't copy the downloaded file");
        self.downloadFail(YES, self.userInfo ,@"下载失败");
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
