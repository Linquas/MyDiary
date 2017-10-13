//
//  WeatherTest.m
//  WeatherTest
//
//  Created by Linquas on 12/10/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Weather.h"

@interface WeatherTest : XCTestCase {
    @private
    Weather *weatherData;
    NSDictionary *data;
}
@end

@implementation WeatherTest

- (void)setUp {
    [super setUp];
    // Using bundleForClass:[self class]
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"weatherTestData.json" ofType:nil];
    NSData *d = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    id dd = [NSJSONSerialization JSONObjectWithData:d options:kNilOptions error:&error];
    NSLog(@"obj: %@ ; error: %@",dd, error);
    data = (NSDictionary*)dd;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    weatherData = nil;
    data = nil;
    [super tearDown];
}

- (void)testWeatherJsonParser {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    weatherData = [[Weather alloc] initWithJson:data];
    NSString *location = weatherData.location;
    XCTAssertNotNil(location);
    XCTAssertTrue([location isEqualToString:@"Tawarano"]);
}

- (void)testWeatherWithNilInput {
    weatherData = nil;
    weatherData = [[Weather alloc] initWithJson:nil];
    XCTAssertNil(weatherData);
}


@end
