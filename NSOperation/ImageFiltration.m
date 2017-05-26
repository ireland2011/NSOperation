//
//  ImageFiltration.m
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import "ImageFiltration.h"

@interface ImageFiltration ()

@property (nonatomic, strong, readwrite) NSIndexPath *indexPathInTableView;
@property (nonatomic, strong, readwrite) PhotoRecord *photoRecord;

@end

@implementation ImageFiltration

- (instancetype)initWithRecord:(PhotoRecord *)record adIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)theDelegate {
    
    if (self = [super init]) {
        self.photoRecord = record;
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
    }
    
    return self;
}


#pragma mark - Main Operation

- (void)main {
    @autoreleasepool {
        
        if (self.isCancelled) return;
        
        if (!self.photoRecord.hasImage) return;
        
        UIImage *rawImage = self.photoRecord.image;
        UIImage *processedImage = [self applySepiaFilterToImage:rawImage];
        
        if (self.isCancelled) return;
        
        if (processedImage) {
            self.photoRecord.image = processedImage;
            self.photoRecord.filtered = YES;
             [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageFiltrationDidfinish:) withObject:self waitUntilDone:NO];
        }
    }
}


#pragma mark - Image filtration
- (UIImage *)applySepiaFilterToImage:(UIImage *)image {
    
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    
    if (self.isCancelled) return nil;
    
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues:kCIInputImageKey, inputImage, @"inputIntensity", @(0.8), nil];
    CIImage *outputImage = [filter outputImage];
    
    if (self.isCancelled) return nil;
    
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    if (self.isCancelled) {
        CGImageRelease(outputImageRef);
        return nil;
    };
    
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    
    CGImageRelease(outputImageRef);
    
    return sepiaImage;
}


@end
