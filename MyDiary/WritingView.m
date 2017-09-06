//
//  WritingView.m
//  MyDiary
//
//  Created by Linquas on 01/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "WritingView.h"
#import "PlaceHoldUITextView.h"
#import "NSDate+YearMonthDay.h"

#define TEXTCOLOR [UIColor colorWithRed:0.53 green:0.71 blue:0.76 alpha:1.0]
#define FONTNAME @"Helvetica Neue"


@interface WritingView ()
@property (weak, nonatomic) IBOutlet UILabel *monthLAbel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *titleTextView;
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIView *upperView;


@end

@implementation WritingView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleTextView.textContainer.maximumNumberOfLines = 1;
    
    [self updateDate];
    
    self.contentTextView.attributedPlaceholder = [self generateAttributedStringWithString:@"Diary" Color:TEXTCOLOR FontName:FONTNAME FontSize:20.0];
    self.titleTextView.attributedPlaceholder = [self generateAttributedStringWithString:@"Title" Color:TEXTCOLOR FontName:FONTNAME FontSize:35.0];
    
    self.upperView.layer.shadowColor = [UIColor colorWithRed:157.0 / 255.0 green:157.0 / 255.0 blue:157.0 / 255.0 alpha:0.8].CGColor;
    self.upperView.layer.shadowOpacity = 0.8;
    self.upperView.layer.shadowRadius = 5.0;
    self.upperView.layer.shadowOffset = CGSizeMake(1.0, 3.0);
}

- (void)updateDate {
    NSDate *today = [NSDate date];
    self.dayLabel.text = [today dayInString];
    self.weekLabel.text = [today weekdayInString];
    self.yearLabel.text = [today yearInString];
    self.monthLAbel.text = [today monthInString];
}

- (NSMutableAttributedString*)generateAttributedStringWithString:(NSString*)str Color:(UIColor*)color FontName:(NSString*) fontname FontSize:(NSInteger) fontsize {
    
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    UIFont *font = [UIFont fontWithName:fontname size:fontsize];
    [attrDict setObject:font forKey:NSFontAttributeName];
    return [[NSMutableAttributedString alloc] initWithString:str attributes: attrDict];
}


@end
