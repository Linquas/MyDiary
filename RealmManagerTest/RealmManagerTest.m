//
//  RealmManagerTest.m
//  RealmManagerTest
//
//  Created by Linquas on 13/10/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RealmManager.h"
#import "Diary.h"


@interface RealmManagerTest : XCTestCase{
    RealmManager *manager;
    Diary *testDiary;
}

@end

@implementation RealmManagerTest

- (void)setUp {
    [super setUp];
    // Use an in-memory Realm identified by the name of the current test.
    // This ensures that each test can't accidentally access or modify the data
    // from other tests or the application itself, and because they're in-memory,
    // there's nothing that needs to be cleaned up.
    testDiary = [[Diary alloc] init];
    testDiary.title = @"title";
    testDiary.text = @"text";
    testDiary.user = @"user";
    testDiary.weather = @"weather";
    testDiary.loaction = @"location";
    testDiary.key = 1;
    
    manager = [RealmManager instance];
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.inMemoryIdentifier = @"test database";
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    RLMRealm *testRealm = [RLMRealm defaultRealm];
    [testRealm beginWriteTransaction];
    [testRealm deleteAllObjects];
    [testRealm commitWriteTransaction];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddObject {
    RLMRealm* realm = [RLMRealm defaultRealm];
    [manager addOrUpdateObject:testDiary];
    
    XCTestExpectation *e = [self expectationWithDescription:@"object get"];
    RLMNotificationToken *token = [realm addNotificationBlock:^(RLMNotification  _Nonnull notification, RLMRealm * _Nonnull realm) {
        [e fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    RLMResults *results = [Diary allObjects];
    Diary *d = [results lastObject];
    XCTAssertTrue([d.text isEqualToString:@"text"]);
    XCTAssertTrue([d.title isEqualToString:@"title"]);
    XCTAssertTrue([d.user isEqualToString:@"user"]);
    XCTAssertTrue([d.weather isEqualToString:@"weather"]);
    XCTAssertTrue([d.loaction isEqualToString:@"location"]);
    XCTAssertTrue(d.key == 1);
}

- (void)testUpdateObject {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    [realm addOrUpdateObject:testDiary];
    
    RLMResults *oldResult = [Diary allObjects];
    Diary *old = [oldResult lastObject];
    XCTAssertTrue([old.title isEqualToString:@"title"]);
    
    testDiary.title = @"newTitle";

    [realm addOrUpdateObject:testDiary];
    
    [realm commitWriteTransaction];
    
    RLMResults *newResult = [Diary allObjects];
    Diary *new = [newResult lastObject];
    XCTAssertTrue([new.title isEqualToString:@"newTitle"]);
}


@end
