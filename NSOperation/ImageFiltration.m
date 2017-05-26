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
    
    /*
     A representation of an image to be processed or produced by Core Image filters.
     Core Image过滤器 处理或者产生的一个图片格式
     
     You use CIImage objects in conjunction with other Core Image classes—such as CIFilter, CIContext, CIVector, and CIColor—to take advantage of the built-in Core Image filters when processing images. You can create CIImage objects with data supplied from a variety of sources, including Quartz 2D images, Core Video image buffers (CVImageBufferRef), URL-based objects, and NSData objects.
     你可以使用CIImage, 配合其他的Core Image类, 比如CIFilter,CIContext,CIVector,CIColor, 以便充分地在处理图片时利用内置的Core Image过滤器. 
     你可以通过data创建CIImage, 这些data可以来自于 Quartz 2D, Core Video image缓存, URL 和 NSData.
     
     Although a CIImage object has image data associated with it, it is not an image. You can think of a CIImage object as an image “recipe.” A CIImage object has all the information necessary to produce an image, but Core Image doesn’t actually render an image until it is told to do so. This “lazy evaluation” method allows Core Image to operate as efficiently as possible.
     虽然CIImage对象有和其相关联的图片数据, 但是并不是一个图片. 
     你可以将CIImage看做是一个图片的图谱.
     CIImage对象拥有生产一个图片所需的全部信息, 但是Core Image实际上并不会渲染一个图片, 直到调用者告诉它要渲染一个图片. 
     这个"lazy evaluation"懒计算 可以使Core Image尽可能有效地工作.
     
     
     CIContext and CIImage objects are immutable, which means each can be shared safely among threads. Multiple threads can use the same GPU or CPU CIContext object to render CIImage objects. 
     CIContext 和 CIImage 对象是不可变的, 意味着每一个都可以在线程间共享. 多个线程可以使用相同的GPU和CPU CIContext对象来渲染CIImage对象.
     
     However, this is not the case for CIFilter objects, which are mutable. A CIFilter object cannot be shared safely among threads. If you app is multithreaded, each thread must create its own CIFilter objects. Otherwise, your app could behave unexpectedly.
     然而, 对于CIFilter不是同样的情况, 它是可变的. CIFilter对象不能在多个线程间共享.
     如果你的APP是多线程的, 每一个线程都必须创建自己的CIFilter. 否则你的APP可能会出现异常.
     
     Core Image also provides autoadjustment methods. These methods analyze an image for common deficiencies and return a set of filters to correct those deficiencies. 
     The filters are preset with values for improving image quality by altering values for skin tones, saturation, contrast, and shadows and for removing red-eye or other artifacts caused by flash. (See Getting Autoadjustment Filters.)
     Core Image也提供了自动调整的方法. 这些方法 分析了一个图片常出现的缺陷, 并且返回一个过滤器集合用来纠正这些缺陷. 
     过滤器提前预制了一些提高图片质量的值, 可以修改给 色调, 饱和度, 对比度 和 阴影 以及 移除红眼 或者 其他由闪光造成的影线 相关的值.
     
     
     For a discussion of all the methods you can use to create CIImage objects on iOS and macOS, see Core Image Programming Guide.
     */
    
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    
    if (self.isCancelled) return nil;
    
    UIImage *sepiaImage = nil;
    //> 开启上下文
    CIContext *context = [CIContext contextWithOptions:nil];
    //> filer <- filter values + inputImage
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues:kCIInputImageKey, inputImage, @"inputIntensity", @(0.8), nil];
    //> outputImage <- filter
    CIImage *outputImage = [filter outputImage];
    
    if (self.isCancelled) return nil;
    //> outputimage <- context
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    if (self.isCancelled) {
        CGImageRelease(outputImageRef);
        return nil;
    };
    
    //> image <- outputImageRef
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    
    CGImageRelease(outputImageRef);
    
    return sepiaImage;
}


@end
