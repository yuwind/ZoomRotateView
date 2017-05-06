//
//  ViewController.m
//  ZoomRotateView
//
//  Created by hxw on 2017/5/5.
//  Copyright © 2017年 hxw. All rights reserved.
//

#import "ViewController.h"
#import "HHRotateView.h"
#import "UIViewController+Common.h"

@interface ViewController ()<HHRotateViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *alertArray;


@end

@implementation ViewController

- (NSMutableArray<NSString *> *)alertArray
{
    if (!_alertArray) {
        _alertArray = [NSMutableArray arrayWithObjects:@"恭喜你经过不懈努力成功刷新出了一条数据",@"继续努力，下次说不定还能刷新出两条呢",@"其实我是不想告诉你的，我就一条数据",@"世间安得双全法，不负如来不负卿。", nil];
    }
    return _alertArray;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"helloWord1",@"helloWord2", @"helloWord3",  nil];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *imageArray = [NSArray arrayWithObjects:@"http://images.jhrx.cn/attachment/forum/pw/Mon_1206/48_158056_6e7ad5b6cc4f406.jpg",@"http://www.pptbz.com/pptpic/UploadFiles_6909/201110/20111014111307895.jpg",@"http://pic1.win4000.com/wallpaper/4/5599f66607098_270_185.jpg", nil];
    
    NSArray *titleArray = [NSArray arrayWithObjects:@"1,nihao,nijiaoshenmmingzi",@"2,wojiaoshuishuishui",@"3ozhidoale,zaijian", nil];
    
    
//    self.tableView.tableHeaderView= [HHRotateView rotateViewWithFrame:CGRectMake(0, 0, 0, 200) imageArray:imageArray describeArray:titleArray showScale:YES];
    
    
    HHRotateView *rotateView = [HHRotateView rotateViewWithFrame:CGRectMake(0, 0, 0, 200) imageArray:imageArray describeArray:titleArray showScale:YES];
    rotateView.rotateMode = RotateMode3D;
    rotateView.pageColor = pageColorMake([UIColor redColor],[UIColor yellowColor]);
    rotateView.labelAttribute = labelAttributeMake([UIColor yellowColor], 20);
    rotateView.pageImage = pageImageMake(@"dianhui",@"dianhong");
    rotateView.waveColor = [UIColor whiteColor];
    rotateView.waveFrequency = 5.0f;
    
    self.tableView.tableHeaderView = rotateView;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

-(void)rotateView:(HHRotateView *)rotateView didClickImage:(NSInteger)index
{
    NSLog(@"点击了第%ld张图片",index);
}
/**
 *  刷新请求
 */
- (void)pullToSendNetworkRequest:(HHRotateView *)rotateView
{
    NSLog(@"发送网络请求");
    [self showWaitHud];
    __weak __typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        /**
         *  数据请求成功回调
         */
        [wSelf hideWaitHud];
        [rotateView stopWave];
        [wSelf showText:self.alertArray[arc4random_uniform((u_int32_t)[self.alertArray count])]];
        
        [wSelf.dataArray addObject:[NSString stringWithFormat:@"helloWord%ld",self.dataArray.count+1]];
        [wSelf.tableView reloadData];
        
    });
    
}
- (void)pushToSendNetworkRequest:(HHRotateView *)rotateView
{
    [self showWaitHud];
    __weak __typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        /**
         *  数据请求成功回调
         */
        [wSelf hideWaitHud];
        [rotateView stopPushRefresh];
        [wSelf showText:self.alertArray[arc4random_uniform((u_int32_t)[self.alertArray count])]];
        
        [wSelf.dataArray addObject:[NSString stringWithFormat:@"helloWord%ld",self.dataArray.count+1]];
        [wSelf.tableView reloadData];
        
    });
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selectedRow");
}



@end
