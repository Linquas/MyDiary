//
//  Weather.m
//  MyDiary
//
//  Created by Linquas on 16/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "Weather.h"

@implementation Weather

- (instancetype)initWithWeatherDescription:(NSString*) weatherDesc withLocation:(NSString *)location {
    self = [super init];
    if (self) {
        _weatherDescription = weatherDesc;
        _location = location;
    }
    return self;
}
- (instancetype)initWithJson:(id) jsonData {
    return [self jsonParser:jsonData];
}

- (Weather*)jsonParser:(id)jsonData {
    if ([jsonData isKindOfClass:[NSDictionary class]] || jsonData ) {
        NSString *cityName = [jsonData objectForKey:@"name"];
        if ([[jsonData objectForKey:@"weather"] isKindOfClass:[NSArray class]]) {
            NSArray *weather = [jsonData objectForKey:@"weather"];
            NSDictionary *weatherData = weather[0];
            NSString *description = [weatherData objectForKey:@"description"];
            return [[Weather alloc]initWithWeatherDescription:description withLocation:cityName];
        }
    }
    return nil;
}
@end
