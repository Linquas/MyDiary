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
        self.weatherDescription = weatherDesc;
        self.location = location;
    }
    return self;
}

@end
