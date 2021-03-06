//
//  YTJokeListController.m
//  PrefectAssistant
//
//  Created by HelloWorld on 16/4/6.
//  Copyright © 2016年 HelloWorld. All rights reserved.
//

#import "YTJokeListController.h"
#import <HMSegmentedControl.h>
#import "YTJoke.h"
#import "YTJokeCell.h"
#import <MJRefresh.h>

typedef NS_ENUM(NSUInteger, YTJokeTypes) {
    YTJokeTypeTextJoke,
    YTJokeTypeImgJoke,
};

@interface YTJokeListController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign) YTJokeTypes jokeType;

@property (nonatomic, assign) NSInteger textJokePage;
@property (nonatomic, assign) NSInteger imgJokePage;

@property (nonatomic, strong) NSMutableArray *jokes;
@property (nonatomic, strong) NSMutableArray *tempJokes;


@end

@implementation YTJokeListController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"搞笑生活"];
    _jokes = [NSMutableArray array];
    _tempJokes = [NSMutableArray array];
   
    [self setupUIConfig];
}

- (void)setupUIConfig {
  
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self.view setBackgroundColor:YTColorBackground];
    
    CGFloat margin = 10;
    HMSegmentedControl *segementControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"文字模式", @"图片模式"]]; {
        [segementControl setFrame:CGRectMake(-1, 64+margin, YTSCREEN_W+2, 40)];
        [segementControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationDown];
        [segementControl setIndexChangeBlock:^(NSInteger index) {
            if (index == 0) {
                self.jokeType = YTJokeTypeTextJoke;
            } else {
                self.jokeType = YTJokeTypeImgJoke;
                if (self.tempJokes.count==0) {
                    [self.tableView.mj_header beginRefreshing];
                }
            }
            NSMutableArray *tempArray = self.jokes;
            self.jokes = self.tempJokes;
            self.tempJokes = tempArray;
            [self.tableView reloadData];
        }];
    }
    [self.view addSubview:segementControl];
    
    CGFloat tableViewH = YTSCREEN_H - segementControl.bottomY;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, segementControl.bottomY, YTSCREEN_W, tableViewH)
                                                          style:UITableViewStylePlain]; {
        [tableView setBackgroundColor:YTColorBackground];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        [tableView setTableFooterView:[[UIView alloc] init]];
        
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            switch (self.jokeType) {
                case YTJokeTypeTextJoke: {
                    self.textJokePage = 0;
                    break;
                }
                case YTJokeTypeImgJoke: {
                    self.imgJokePage = 0;
                    break;
                }
            }
            [self loadJokesFromNetworkWithRefreshingHeader:YES];
        }];
        tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            switch (self.jokeType) {
                case YTJokeTypeTextJoke: {
                    self.textJokePage++;
                    break;
                }
                case YTJokeTypeImgJoke: {
                    self.imgJokePage++;
                    break;
                }
            }
            [self loadJokesFromNetworkWithRefreshingHeader:NO];
        }];
        [tableView.mj_header beginRefreshing];
    }
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)loadJokesFromNetworkWithRefreshingHeader:(BOOL)isRefreshingHeader {

    NSString *page = nil;
    NSString *urlString = nil;
    switch (self.jokeType) {
        case YTJokeTypeTextJoke: {
            urlString = APIJokeTextQ;
            page = [NSString stringWithFormat:@"%zi", (++self.textJokePage)];
            break;
        }
        case YTJokeTypeImgJoke: {
            urlString = APIJokeImgQ;
            page = [NSString stringWithFormat:@"%zi", (++self.imgJokePage)];
            break;
        }
    }
    
    NSDictionary *parameters = @{@"key"     : APIJokeKey,
                                 @"page"    : page,
                                 @"pagesize": @"20"};
    [YTHTTPTool get:urlString parameters:parameters success:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
       
        NSMutableArray *dateArray = responseObject[@"result"][@"data"];
        if (![dateArray isKindOfClass:[NSArray class]]) {
            [YTAlertView showAlertMsg:YTHTTPDataException];
            return;
        }
        if (dateArray.count == 0) {
            [YTAlertView showAlertMsg:YTHTTPDataZero];
            return;
        }
        NSMutableArray *pageJokes = [YTJoke mj_objectArrayWithKeyValuesArray:dateArray];
        if (isRefreshingHeader) {
            self.jokes = pageJokes;
        } else {
            [self.jokes addObjectsFromArray:pageJokes];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [YTAlertView showAlertMsg:YTHTTPFailure];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.jokes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTJoke *joke = self.jokes[indexPath.row];
    YTJokeCell *cell = [YTJokeCell jokeCellWithTableView:tableView];
    cell.joke = joke;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    YTJoke *joke = self.jokes[indexPath.row];
    return joke.totalHeight;
}
@end
