//
//  YTCookDetailController.m
//  PrefectAssistant
//
//  Created by HelloWorld on 16/3/24.
//  Copyright © 2016年 HelloWorld. All rights reserved.
//

#import "YTCookDetailController.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import "YTDish.h"
#import "YTCookDetail.h"
#import "UINavigationBar+Extension.h"

//顶部ImageView的初始高度
static CGFloat const kHeaderImageViewH = 150;
//图片的最大高度
static CGFloat const kHeaderImageViewMaxH = (kHeaderImageViewH+100);

@interface YTCookDetailController () <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIImageView *dishImageView;
@property (nonatomic, weak) UIWebView *cookStepView;

@end

@implementation YTCookDetailController

+ (instancetype)cookDetailVCWithDish:(YTDish *)dish {
    
    YTCookDetailController *detailVC = [[self alloc] init];
    detailVC.dish = dish;
    
    return detailVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.dish.name;
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationController.navigationBar setCurrentBarBackgroundColor:[UIColor clearColor]];
    
    [self setupUIConfig];
    
    [self loadCookDetailFromNetwork];
}

- (void)setupUIConfig {
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *dishImageView = [[UIImageView alloc] init]; {
        [dishImageView setContentMode:UIViewContentModeScaleAspectFill];
        [dishImageView setFrame:CGRectMake(0, 0, YTSCREEN_W, kHeaderImageViewH)];
    }
    [self.view addSubview:dishImageView];
    self.dishImageView = dishImageView;
    
    UIWebView *cookStepView = [[UIWebView alloc] init]; {
        [cookStepView.scrollView setDelegate:self];
        [cookStepView.scrollView setShowsVerticalScrollIndicator:NO];
        [cookStepView.scrollView setContentInset:UIEdgeInsetsMake(kHeaderImageViewH, 0, 0, 0)];
        [cookStepView setFrame:CGRectMake(0, 64, YTSCREEN_W, YTSCREEN_H-64)];
        [cookStepView setBackgroundColor:[UIColor clearColor]];
    }
    [self.view addSubview:cookStepView];
    self.cookStepView = cookStepView;
}

- (void)reloadDataWithCookDetail:(YTCookDetail *)cookDetail {
    
    [self.dishImageView sd_setImageWithURL:({
        NSString *urlStr = [@"http://tnfs.tngou.net/image" stringByAppendingPathComponent:cookDetail.img];
        [NSURL URLWithString:urlStr];
    })];
    [self.cookStepView loadHTMLString:cookDetail.message baseURL:nil];
}

- (void)loadCookDetailFromNetwork {

    NSDictionary *parameters = @{@"id" : self.dish.idStr};
    [YTHTTPTool bdGet:APICookShowQ parameters:parameters success:^(id responseObject) {
        NSDictionary *responseObj = responseObject;
        if (![responseObj isKindOfClass:[NSDictionary class]]) {
            [YTAlertView showAlertMsg:YTHTTPDataException];
            return;
        }
        if (responseObj.count == 0) {
            [YTAlertView showAlertMsg:YTHTTPDataZero];
            return;
        }
        
        YTCookDetail *cookDetail = [YTCookDetail mj_objectWithKeyValues:responseObject];
        [self reloadDataWithCookDetail:cookDetail];
    } failure:^(NSError *error) {
        [YTAlertView showAlertMsg:YTHTTPFailure];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.y>0) return;   //防止上滑offsetY到kHeaderImageViewMaxH后出现异常
    
    /**待优化，耦合性较强*/
    CGFloat scrollH = fabs(scrollView.contentOffset.y); //滚动时imageView的高度
    //限制下拉尺度
    if (scrollH > kHeaderImageViewMaxH) {
        [scrollView setContentOffset:CGPointMake(0, -kHeaderImageViewMaxH)]; //固定scrollView的下拉
        return;
    }
    
    //开始放大
    [self.dishImageView setFrame:({
        CGRect headerImageFrame = self.dishImageView.frame;
        headerImageFrame.size.height = scrollH;
        CGFloat offsetW = (scrollH - kHeaderImageViewH);   //校正图片的宽度，出现小拉放大效果
        if (offsetW>0) {
            headerImageFrame.size.width = offsetW + YTSCREEN_W;
            headerImageFrame.origin.x = -(offsetW*0.5);
        }
        headerImageFrame;
    })];
}
@end
