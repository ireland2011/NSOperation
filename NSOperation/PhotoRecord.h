//
//  PhotoRecord.h
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoRecord : NSObject

/** 名称 */
@property (nonatomic, copy) NSString *name;
/** URL */
@property (nonatomic, strong) NSURL *url;
/** image */
@property (nonatomic, strong) UIImage *image;
/** 是否有图片 */
@property (nonatomic, assign, readonly) BOOL hasImage;
/** 是否滤镜 */
@property (nonatomic, assign, getter=isFiltered) BOOL filtered;
/** 是否下载失败 */
@property (nonatomic, assign, getter=isFailed) BOOL failed;



@end
