//
//  ReadingView.m
//  MyDiary
//
//  Created by Linquas on 02/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "ReadingView.h"
#import "PlaceHoldUITextView.h"
#import "NSDate+YearMonthDay.h"

@interface ReadingView ()
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *titleTextView;
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;


@end

@implementation ReadingView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.shadowColor = [UIColor colorWithRed:157.0 / 255.0 green:157.0 / 255.0 blue:157.0 / 255.0 alpha:0.8].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOffset = CGSizeMake(1.0, 3.0);
}


@end
