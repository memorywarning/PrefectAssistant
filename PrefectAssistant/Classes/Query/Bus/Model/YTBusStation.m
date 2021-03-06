//
//  YTBusStation.m
//  PrefectAssistant
//
//  Created by HelloWorld on 16/4/11.
//  Copyright © 2016年 HelloWorld. All rights reserved.
//

#import "YTBusStation.h"
#import "YTBusLine.h"

const CGFloat YTBusStationHeight = 60;

@implementation YTBusStation

+ (NSString *)mj_replacedKeyFromPropertyName121:(NSString *)propertyName {
    
    return [propertyName mj_underlineFromCamel];
}

+ (NSDictionary *)mj_objectClassInArray {
    
    return @{@"stationdes" : [YTBusLine class]};
    
}

- (void)setStartTime:(NSString *)startTime {
    
    NSMutableString *mString = [NSMutableString stringWithString:startTime];
    [mString insertString:@":" atIndex:2];
    _startTime = [mString copy];
}

- (void)setEndTime:(NSString *)endTime {
    NSMutableString *mString = [NSMutableString stringWithString:endTime];
    [mString insertString:@":" atIndex:2];
    _endTime = [mString copy];
}

- (void)setLength:(NSString *)length {
    
    CGFloat fLength = length.doubleValue;
    
    _length = [NSString stringWithFormat:@"%0.2f公里", fLength];
}

@end
