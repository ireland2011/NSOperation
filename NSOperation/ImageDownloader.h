//
//  ImageDownloader.h
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"

@class ImageDownloader;
@protocol ImageDownloadDelegate <NSObject>

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;

@end

@interface ImageDownloader : NSOperation

@property (nonatomic, weak) id<ImageDownloadDelegate> delegate;
@property (nonatomic, strong, readonly) NSIndexPath *indexPathInTableView;

//>>> 当下载完成的时候 可以直接设置属性。 下载失败同样
@property (nonatomic, strong, readonly) PhotoRecord *photoRecord;

- (instancetype)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloadDelegate>)theDelegate;

@end
