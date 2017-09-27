//
//  YahooWeatherAPI.h
//  MyDiary
//
//  Created by Linquas on 15/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@class CLLocation;

typedef  void (^downloadComplete)(id data);
typedef void (^downloadFailed)(NSInteger statusCode, NSInteger errorCode);

static NSString * const BASE_URL = @"https://api.openweathermap.org/data/2.5/weather?";
static NSString * const LATITUDE = @"lat=";
static NSString * const LONGITUDE = @"&lon=";
static NSString * const APP_ID = @"&appid=";
static NSString * const API_KEY = @"42a1771a0b787bf12e734ada0cfc80cb";


@interface OpenWeatherAPI : NSObject

@property (nonatomic, copy) void (^downloadComplete)(id);
@property (nonatomic, copy) void (^downloadFailed)(NSInteger, NSInteger);

- (id)initWithDoenloadCompleteBlock:(downloadComplete) completionHandler failedBlock:(downloadFailed) failHandler;

+ (OpenWeatherAPI*)requestWithCompleteBlock:(downloadComplete) completionHandler failedBlock: (downloadFailed) failHandler;

- (void)getWeatherDataWithCityGPSCordinate:(CLLocation*) loaction;

@end
