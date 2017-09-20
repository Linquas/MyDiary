//
//  DiariesCell.m
//  MyDiary
//
//  Created by Linquas on 30/08/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "DiariesCell.h"
#import "Diary.h"
#import "NSDate+YearMonthDay.h"
#import "Masonry.h"

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
    self.layer.shadowRadius = 4.0;
    self.layer.shadowOffset = CGSizeMake(1.0, 3.0);
    
    self.weatherImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"clear sky.png"]];
    [self addSubview:self.weatherImg];
}

- (void)updateConstraints {
    [self.weatherImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.equalTo(self);
    }];
    [super updateConstraints];
}

- (void)updateCell:(int)num {
    self.dateLabel.text = [NSString stringWithFormat:@"10"];
}

-(void)update:(Diary*)diary {
    self.titleLabel.text = diary.title;
    self.contentLabel.text = diary.text;
    self.dateLabel.text = [diary.date dayInString];
    self.timeLabel.text = [diary.date timeInString];
    self.weekDayLabel.text = [diary.date weekdayShortInString];
    NSString *weather = diary.weather;
    if ([weather isEqualToString:@"NO DATA"]) {
        self.weatherImg.hidden = YES;
    } else {
        self.weatherImg.image = [UIImage imageNamed:weather];
        self.weatherImg.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
