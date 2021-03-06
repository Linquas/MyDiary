//
//  CalendarView.m
//  MyDiary
//
//  Created by Linquas on 12/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "CalendarView.h"
@import FSCalendar;

@interface CalendarView ()
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;

@end

@implementation CalendarView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.calendarView.layer setCornerRadius:0.5];
    [self.calendarView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.calendarView.layer setCornerRadius:5.0];
    [self.calendarView.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [self.calendarView.layer setShadowOpacity:0.6f];
    
    
}

@end
