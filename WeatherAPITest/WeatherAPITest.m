//
//  WeatherAPITest.m
//  WeatherAPITest
//
//  Created by Linquas on 12/10/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OpenWeatherAPI.h"
#import "Weather.h"
#import <CoreLocation/CoreLocation.h>

@interface WeatherAPITest : XCTestCase {

    @private
    CLLocation *gps;
    OpenWeatherAPI *weather;
    NSInteger status;
    NSString *location;
}

@end

@implementation WeatherAPITest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    gps = [[CLLocation alloc] initWithLatitude:25.010790 longitude:121.474183];
    location = @"";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    gps = nil;
    weather = nil;
    
    [super tearDown];
}

- (void)testWeatherAPI {
    XCTestExpectation *dataExpextation = [self expectationWithDescription:@"data get"];
    weather = [OpenWeatherAPI requestWithCompleteBlock:^(id data) {
        NSDictionary *json = data;
        Weather *w = [[Weather alloc]initWithJson:json];
        if (w) {
            // Fulfill the expectation-this will cause -waitForExpectation
            // to invoke its completion handler and then return.
            location = [w.location copy];
            [dataExpextation fulfill];
        }
    } failedBlock:^(NSInteger statusCode, NSInteger errorCode) {
        status = statusCode;
        [dataExpextation fulfill];
    }];
    [weather getWeatherDataWithCityGPSCordinate:gps];
    
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    XCTAssertNotNil(location);
    XCTAssertTrue([location isEqualToString:@"Banqiao"]);
}


@end
