//
//  NSDate+YearMonthDay.h
//  MyDiary
//
//  Created by Linquas on 02/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDate_YearMonthDay)

- (NSString*)dayInString;
- (NSString*)weekdayInString;
- (NSString*)yearInString;
- (NSString*)monthInString;
- (NSString*)timeInString;
- (NSString*)weekdayShortInString;
- (NSInteger)getYearMonthDayOfTodayInInteger;
- (NSInteger)timeInInteger;

@end
