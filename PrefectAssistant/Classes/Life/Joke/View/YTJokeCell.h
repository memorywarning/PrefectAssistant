//
//  YTJokeCell.h
//  PrefectAssistant
//
//  Created by HelloWorld on 16/4/6.
//  Copyright © 2016年 HelloWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTJoke;

@interface YTJokeCell : UITableViewCell

@property (nonatomic, strong) YTJoke *joke;

+ (instancetype)jokeCellWithTableView:(UITableView *)tableView;

@end
