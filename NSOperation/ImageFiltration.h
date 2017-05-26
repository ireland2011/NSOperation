//
//  ImageFiltration.h
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"

@class ImageFiltration;
@protocol ImageFiltrationDelegate <NSObject>

- (void)imageFiltrationDidfinish:(ImageFiltration *)filtration;

@end

@interface ImageFiltration : NSOperation

@property (nonatomic, weak) id<ImageFiltrationDelegate> delegate;
@property (nonatomic, strong, readonly) NSIndexPath *indexPathInTableView;
@property (nonatomic, strong, readonly) PhotoRecord *photoRecord;

- (instancetype)initWithRecord:(PhotoRecord *)record adIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)theDelegate;


@end
