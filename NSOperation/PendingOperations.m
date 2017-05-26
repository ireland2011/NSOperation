//
//  PendingOperations.m
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

- (NSMutableDictionary *)downloadInProgress {
    if (!_downloadInProgress) {
        _downloadInProgress = [[NSMutableDictionary alloc] init];
    }
    return _downloadInProgress;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Download queue";
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

- (NSMutableDictionary *)filtrationsInProgress {
    if (!_filtrationsInProgress) {
        _filtrationsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _filtrationsInProgress;
}

- (NSOperationQueue *)filtrationQueue {
    if (!_filtrationQueue) {
        _filtrationQueue = [[NSOperationQueue alloc] init];
        _filtrationQueue.name = @"filtrationQueue";
        _filtrationQueue.maxConcurrentOperationCount = 1;
    }
    return _filtrationQueue;
}


@end
