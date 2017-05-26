//
//  PendingOperations.h
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *downloadInProgress;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@property (nonatomic, strong) NSMutableDictionary *filtrationsInProgress;
@property (nonatomic, strong) NSOperationQueue *filtrationQueue;

@end
