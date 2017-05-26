//
//  ImageDownloader.m
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()

@property (nonatomic, strong, readwrite) NSIndexPath *indexPathInTableView;
@property (nonatomic, strong, readwrite) PhotoRecord *photoRecord;

@end

@implementation ImageDownloader

- (instancetype)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloadDelegate>)theDelegate {
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    
    return self;
}


#pragma mark - Downloading image

/*
 Performs the receiver’s non-concurrent task.
 执行 调用者的非并发任务
 
 The default implementation of this method does nothing. You should override this method to perform the desired task. In your implementation, do not invoke super. 
 这个方法的默认实现 什么也没做. 你应该重写来执行你想要的任务. 在你实现中, 不要回调super
 
 This method will automatically execute within an autorelease pool provided by NSOperation, so you do not need to create your own autorelease pool block in your implementation.
 这个方法将会自动 在由NSOperation提供的自动池 中执行. 因此在你的实现中, 你不需要创建你自己的自动释放池.
 
 If you are implementing a concurrent operation, you are not required to override this method but may do so if you plan to call it from your custom start method.
 如果你实现一个并发操作, 你不必重写这个方法, 但是如果你打算在自定义的start方法中调用此方法, 你需要重写此方法.
 
 */
 
- (void)main {
    @autoreleasepool {
        if (self.isCancelled) return;
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.url];
        
        if (self.isCancelled) {
            imageData = nil; return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadedImage;
        }else {
            self.photoRecord.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled) return;
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}



@end
