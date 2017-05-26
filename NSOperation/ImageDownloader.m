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
