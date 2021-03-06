//
//  YTTrainStationController.m
//  PrefectAssistant
//
//  Created by HelloWorld on 16/3/29.
//  Copyright © 2016年 HelloWorld. All rights reserved.
//

#import "YTTrainStationController.h"
#import "YTTrainInfoQuery.h"
#import "YTTrainStation.h"
#import "YTTrainNumberController.h"
#import "YTTrainStationCell.h"
#import <MJRefresh.h>

@interface YTTrainStationController ()

@property (nonatomic, copy) NSArray<YTTrainStation *> *trainInfos;

@end

@implementation YTTrainStationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"车站车次信息";
   
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadTrainStationInfoFromNetwork];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadTrainStationInfoFromNetwork {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"1.0" forKey:@"version"];
    [parameters setObject:self.trainQuery.stationName forKey:@"station"];
   
    [YTHTTPTool bdGet:APITrainStationAllTrainQ parameters:parameters success:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        
        NSDictionary *resultDict = responseObject[@"data"][@"trainInfo"];
        if (![resultDict isKindOfClass:[NSDictionary class]]) {
            [YTAlertView showAlertMsg:YTHTTPDataException];
            return;
        }
        if (resultDict.count == 0) {
            [YTAlertView showAlertMsg:YTHTTPDataZero];
            return;
        }
        self.trainInfos = [YTTrainStation mj_objectArrayWithKeyValuesArray:[resultDict allValues]];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [YTAlertView showAlertMsg:YTHTTPFailure];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.trainInfos.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTTrainStation *trainInfo = self.trainInfos[indexPath.row];
    YTTrainStationCell *cell = [YTTrainStationCell trainStationWithTableView:tableView];
    cell.trainInfo = trainInfo;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return YTTrainStationCellH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YTTrainStation *trainInfo = self.trainInfos[indexPath.row];
    
    YTTrainNumberController *trainNumVC = [[YTTrainNumberController alloc] init];
    trainNumVC.trainQuery = [YTTrainInfoQuery trainInfoQueryWithQueryType:YTTrainInfoQueryTypeTrainNo
                                                                  trainNo:trainInfo.code];
    [self.navigationController pushViewController:trainNumVC animated:YES];
}
@end
