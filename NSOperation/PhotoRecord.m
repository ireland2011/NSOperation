//
//  PhotoRecord.m
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import "PhotoRecord.h"

@implementation PhotoRecord

- (BOOL)hasImage {
    return _image != nil;
}

- (BOOL)isFailed {
    return _failed;
}

- (BOOL)isFiltered {
    return _filtered;
}

@end
