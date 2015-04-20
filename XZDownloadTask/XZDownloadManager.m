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
@property (nonatomic, copy) void(^downloadSuccuss)(BOOL isSuccuss);
@property (nonatomic, copy) void(^downloadFail)(BOOL isFail, NSString *errMsg);
@property (nonatomic, assign) void(^downloadProgress)(float progress);
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

- (void)congiDownloadInfo:(NSString *) downloadStr isDownload:(BOOL)isDownload succuss:(void (^)(BOOL isSuccuss)) succuss fail:(void(^)(BOOL isFail, NSString *errMsg)) fail progress:(void(^)(float progress)) progress {
    self.downloadSuccuss = succuss;
    self.downloadFail = fail;
    self.downloadProgress = progress;

    if (isDownload) {
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

// http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/134423200/12152327672000128.mp3?xcode=b8a2a1a32cf60e30c8950b37b04a1ea81185dbd0cbb5163e&song_id=121523276

- (void)pauseDownload {
    if (self.normalSessionTask) {
        [self.normalSessionTask cancelByProducingResumeData:^(NSData *resumeData) {
            self.partialData = resumeData;
            self.normalSessionTask = nil;
        }];
    }
}

- (void)resumeDownload {
    if (!self.resumeSessionTask) {
        if (self.partialData) {
            self.resumeSessionTask = [self.normalSession downloadTaskWithResumeData:self.partialData];
            
            [self.resumeSessionTask resume];
        } else {
            self.downloadFail(YES, @"没有需要恢复的任务");
        }
    } else {
        self.downloadFail(YES, @"没有需要恢复的任务");
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
    }
}

- (void)restartDownload {
    if (!self.resumeSessionTask) {
        if (self.partialData) {
            self.resumeSessionTask = [self.normalSession downloadTaskWithResumeData:self.partialData];
            
            [self.resumeSessionTask resume];
        } else {
            self.downloadFail(YES, @"没什么要重新下载");
        }
    } else {
        self.downloadFail(YES, @"没什么要重新下载");
    }
}

#pragma mark - NSURLSessionDownloadDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double currentProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    self.downloadProgress(currentProgress);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // 下载失败
    self.downloadFail(YES, @"下载失败");
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
        self.downloadSuccuss(YES);
    } else {
        NSLog(@"Couldn't copy the downloaded file");
        self.downloadFail(YES,@"下载失败");
    }
    
//    if(downloadTask == cancellableTask) {
//        cancellableTask = nil;
//    } else if (downloadTask == self.resumableTask) {
//        self.resumableTask = nil;
//        partialDownload = nil;
//    } else
//        
    if (session == self.backgroundSession) {
        self.backgroundSessionTask = nil;
        // Get hold of the app delegate
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.backgroundURLSessionCompletionHandler) {
            void (^handler)() = appDelegate.backgroundURLSessionCompletionHandler;
            appDelegate.backgroundURLSessionCompletionHandler = nil;
            handler();
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
