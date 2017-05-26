//
//  ViewController.m
//  NSOperation
//
//  Created by Genius on 2017/5/25.
//  Copyright © 2017年 Genius. All rights reserved.
//

#import "ViewController.h"
#import "PhotoRecord.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "ImageFiltration.h"

#import "AFNetworking/AFNetworking.h"


@interface ViewController () <UITableViewDelegate, UITableViewDataSource,
ImageDownloadDelegate, ImageFiltrationDelegate>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;
/** listM */
@property (nonatomic, strong) NSMutableArray *photos;
/** op */
@property (nonatomic, strong) PendingOperations *pendingOperations;

@end


static NSString *const kCellIdentify = @"cell identify";


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80.f;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentify];
    
    [self.tableView reloadData];
    
    
}


- (void)didReceiveMemoryWarning {
    [self cancelAllOperations];
    [super didReceiveMemoryWarning];
}


#pragma mark - TableViewDelegate/Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentify];
    if (cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }
    
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    
    // 图片下载完成
    if (aRecord.hasImage) {
        [(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
        cell.imageView.image = aRecord.image;
        cell.textLabel.text = aRecord.name;
    }
    // 图片下载失败
    else if(aRecord.isFailed) {
        [(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
        cell.imageView.image = nil;
        cell.textLabel.text = @"failed to load";
    }
    // 图片还未开始下载
    else {
        [(UIActivityIndicatorView *)cell.accessoryView startAnimating];
        cell.imageView.image = nil;
        cell.textLabel.text = @"loading";
        
        if (!self.tableView.dragging && !self.tableView.decelerating) {
            [self startOperationForPhotoRecord:aRecord adIndexPath:indexPath];
        }
        
        
    }
    
    return cell;
}


#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self suspendAllOperations];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImageForOnscreenCells];
        [self resumeAllOperations];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImageForOnscreenCells];
    [self resumeAllOperations];
}


#pragma mark - Cancelling suspending resuming queues/operations
- (void)suspendAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:YES];
    [self.pendingOperations.filtrationQueue setSuspended:YES];
}


- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    [self.pendingOperations.filtrationQueue setSuspended:NO];
}

- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    [self.pendingOperations.filtrationQueue cancelAllOperations];
}

- (void)loadImageForOnscreenCells {
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    ///> 正在下载和滤镜的cell
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    ///> 需要被操作的行 = 可见的 - 挂起的
    [toBeStarted minusSet:pendingOperations];
    
    ///> 需要被取消的行 = 挂起的 - 可见的
    [toBeCancelled minusSet:visibleRows];
    
    
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadInProgress removeObjectForKey:anIndexPath];
        
        ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:anIndexPath];
        [pendingFiltration cancel];
        
        [self.pendingOperations.filtrationsInProgress removeObjectForKey:anIndexPath];
    }
    
    
    toBeCancelled = nil;
    
    
    for (NSIndexPath *anIndexPath in toBeStarted) {
        PhotoRecord *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
        [self startOperationForPhotoRecord:recordToProcess adIndexPath:anIndexPath];
    }
    
    toBeStarted = nil;
    
}




#pragma mark - Download/Filter
// 开启 图片下载和滤镜操作
- (void)startOperationForPhotoRecord:(PhotoRecord *)record adIndexPath:(NSIndexPath *)indexPath {
    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record adIndexPath:indexPath];
    }
    
    if (!record.isFiltered) {
        [self startImageFiltrationForRecord:record adIndexPath:indexPath];
    }
}

// 下载图片
- (void)startImageDownloadingForRecord:(PhotoRecord *)record adIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.pendingOperations.downloadInProgress.allKeys containsObject:indexPath]) {
        
        ///> 创建图片下载器
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
 
}

// 图片滤镜
- (void)startImageFiltrationForRecord:(PhotoRecord *)record adIndexPath:(NSIndexPath *)indexPath {
    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath]) {
        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithRecord:record adIndexPath:indexPath delegate:self];
        
        ///> 如果图片正在下载, 则添加依赖. 等图片下载完执行 滤镜操作
        ImageDownloader *dependency = [self.pendingOperations.downloadInProgress objectForKey:indexPath];
        if (dependency) {
            [imageFiltration addDependency:dependency];
            
            [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
            [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
        }
    }
}


#pragma mark - CustomDelegate
// 图片下载完成 回调
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    //> 下载完成后 刷新行
    //> 从操作缓存中移除下载器
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.pendingOperations.downloadInProgress removeObjectForKey:indexPath];
}

// 滤镜完成 回调
- (void)imageFiltrationDidfinish:(ImageFiltration *)filtration {
    NSIndexPath *indexPath = filtration.indexPathInTableView;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
}



#pragma mark - Setter&Gettter
- (NSMutableArray *)photos {
    if (!_photos) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ClassicPhotosDictionary.plist" ofType:nil];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSMutableArray *records = [NSMutableArray array];
        for (NSString *key in dict) {
            
            @autoreleasepool {
                PhotoRecord *record = [[PhotoRecord alloc] init];
                record.url = [NSURL URLWithString:[dict objectForKey:key]];
                record.name = key;
                
                [records addObject:record];
                record = nil;
            }
            
        }
        self.photos = records;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    return _photos;
}


- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}








@end

















