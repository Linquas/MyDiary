//
//  YahooWeatherAPI.m
//  MyDiary
//
//  Created by Linquas on 15/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "OpenWeatherAPI.h"
#import "HttpResponseErrorCode.h"

@interface OpenWeatherAPI ()


@end

@implementation OpenWeatherAPI

- (id)initWithDoenloadCompleteBlock:(downloadComplete) completionHandler failedBlock:(downloadFailed) failHandler {
    self = [super init];
    if (self) {
        _downloadComplete = completionHandler;
        _downloadFailed = failHandler;
    }
    return self;
}

+ (OpenWeatherAPI*)requestWithCompleteBlock:(downloadComplete) completionHandler failedBlock: (downloadFailed) failHandler {
    return [[OpenWeatherAPI alloc]initWithDoenloadCompleteBlock:completionHandler failedBlock:failHandler];
}

- (void)getWeatherDataWithCityGPSCordinate:(CLLocation*)location {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *lontitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", BASE_URL, LATITUDE, latitude, LONGITUDE,lontitude, APP_ID, API_KEY];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", nil];
    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseData = (NSDictionary*) responseObject;
        self.downloadComplete(responseData);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSInteger statusCode = getErrorStatusCode(task);
        NSInteger errorCode = getErrorCode(error);
        NSDictionary *errorDict = getError(error);
        NSString *errorMsg = errorDict[@"message"];
        NSLog(@"error : %@", errorMsg);
        self.downloadFailed(statusCode, errorCode);
    }];
    
}



@end
