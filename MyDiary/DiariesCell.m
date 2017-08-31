//
//  DiariesCell.m
//  MyDiary
//
//  Created by Linquas on 30/08/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "DiariesCell.h"

@interface DiariesCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation DiariesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius =  5.0;
    self.layer.masksToBounds = YES;
    self.layer.shadowColor = [UIColor colorWithRed:157.0 / 255.0 green:157.0 / 255.0 blue:157.0 / 255.0 alpha:0.8].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOffset = CGSizeMake(1.0, 3.0);
    
}

- (void)updateCell:(int)num {
    self.dateLabel.text = [NSString stringWithFormat:@"10"];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
