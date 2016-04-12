//
//  YTTVCategoryController.m
//  PrefectAssistant
//
//  Created by HelloWorld on 16/4/6.
//  Copyright © 2016年 HelloWorld. All rights reserved.
//

#import "YTTVCategoryController.h"
#import "YTChannelListController.h"

@interface YTTVCategoryController ()

@property (nonatomic, weak) UIButton *lastTVTypeBtn;

@end

@implementation YTTVCategoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view setBackgroundColor:YTRandomColor];
    
    CGFloat margin = 10;
    UIView *tvCategoryView = [self setupRadioViewWithRadioNames:@[@"央视", @"卫视", @"数字", @"城市", @"CETV", @"原创"]
                                                        action:@selector(tvTypeBtnDidClick:)]; {
        [tvCategoryView setBackgroundColor:YTRandomColor];
        [tvCategoryView setOrigin:CGPointMake(-1, 64 + margin)];
    }
    [self.view addSubview:tvCategoryView];
    
    UIButton *queryBtn = [UIButton buttonWithType:UIButtonTypeCustom]; {
        [queryBtn setBackgroundColor:YTRandomColor];
        [queryBtn setFrame:CGRectMake(20, tvCategoryView.bottomY + margin, YTSCREEN_W-2*20, 40)];
        [queryBtn addTarget:self action:@selector(tvPlaybillQuery) forControlEvents:UIControlEventTouchUpInside];
        [queryBtn setTitle:@"查询" forState:UIControlStateNormal];
    }
    [self.view addSubview:queryBtn];
}

- (UIView *)setupRadioViewWithRadioNames:(NSArray *)radioNames action:(SEL)action {
    
    UIView *radioView = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, YTSCREEN_W+2, 0)]; {
        CGFloat margin = 40;
        CGFloat padding = 9;
        NSInteger colCount = 2;
        CGFloat height = 40;
        CGFloat width = (radioView.width - 2*margin) * 0.5;
        for (NSUInteger index = 0; index<radioNames.count; index++) {
            UIButton *radioBtn = [UIButton buttonWithType:UIButtonTypeCustom]; {
                [radioBtn setTag:index+1];
                [radioBtn setTitle:radioNames[index] forState:UIControlStateNormal];
                [radioBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [radioBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [radioBtn setImage:[UIImage imageNamed:@"btn_more_choice_nor"] forState:UIControlStateNormal];
                [radioBtn setImage:[UIImage imageNamed:@"btn_more_choice_pre"] forState:UIControlStateSelected];
                [radioBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, padding, 0, 0)];
                [radioBtn setFrame:CGRectMake(margin + width*(index%colCount), (index/2)*height, width, height)];
                [radioBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
                [radioView addSubview:radioBtn];
            }
            if (index == 0) {   //模拟一次点击
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:action withObject:radioBtn];
            }
        }
        NSInteger rowCount = radioNames.count/colCount + radioNames.count%colCount;
        CGFloat radioViewHeight = rowCount * height;
        [radioView setFrame:CGRectMake(0, 0, radioView.width, radioViewHeight)];
        [radioView.layer setBorderColor:YTRandomColor.CGColor];
        [radioView.layer setBorderWidth:0.5];
    }
    return radioView;
}

- (void)tvTypeBtnDidClick:(UIButton *)typeBtn {
    
    [self.lastTVTypeBtn setSelected:NO];
    [typeBtn setSelected:YES];
    self.lastTVTypeBtn = typeBtn;
    
}

- (void)tvPlaybillQuery {
    
    YTChannelListController *playbillVC = [[YTChannelListController alloc] init];
    playbillVC.categoryId = [NSString stringWithFormat:@"%zi", self.lastTVTypeBtn.tag];
    [self.navigationController pushViewController:playbillVC animated:YES];
    
}

@end
