//
//  NSDate+YearMonthDay.m
//  MyDiary
//
//  Created by Linquas on 02/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "NSDate+YearMonthDay.h"

#define WEEKDAYS [@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday"]
#define MONTHS [@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"]
#define WEEKDAYS_SHORT [@"Sun.",@"Mon.",@"Tue.",@"Wed.",@"Thu.",@"Fri.",@"Sat."]

@implementation NSDate (NSDate_YearMonthDay)

- (NSString*)dayInString {
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"dd"];
    return [formatter stringFromDate:self];
}

- (NSString*)weekdayInString {
    NSArray *weekdays = @WEEKDAYS;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitWeekday;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    return [weekdays objectAtIndex:[components weekday] - 1];
}

- (NSString*)yearInString {
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY"];
    return [formatter stringFromDate:self];

}

- (NSString*)monthInString {
    NSArray *months = @MONTHS;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"MM"];
    NSString *str = [formatter stringFromDate:self];
    return [months objectAtIndex:[str integerValue] - 1];
}

- (NSString*)weekdayShortInString {
    NSArray *weekdays = @WEEKDAYS_SHORT;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitWeekday;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    return [weekdays objectAtIndex:[components weekday] - 1];
}

- (NSString*)timeInString {
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:self];
}

- (NSInteger)getYearMonthDayOfTodayInInteger {
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    
    return [date integerValue];
}

- (NSInteger)timeInInteger {
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    
    return [date integerValue];

}



@end
