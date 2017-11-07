//
//  Diary.m
//  MyDiary
//
//  Created by Linquas on 01/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "Diary.h"

@implementation Diary

+ (NSString *)primaryKey {
    return @"key";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"user" : @0, @"title": @"NO DATA", @"text": @"NO DATA", @"weather": @"NO DATA", @"mood": @"NO DATA", @"loaction": @"NO DATA", @"date": [NSDate date]};
}

@end
