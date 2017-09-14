//
//  AboutMeView.m
//  MyDiary
//
//  Created by Linquas on 07/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "AboutMeView.h"

@interface AboutMeView ()
@property (weak, nonatomic) IBOutlet UIImageView *personImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *upperRec;

@end

@implementation AboutMeView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.personImg.layer.cornerRadius = self.personImg.frame.size.width / 2;
    self.personImg.clipsToBounds = YES;
    self.personImg.layer.borderWidth = 3.0;
    self.personImg.layer.borderColor = [UIColor colorWithRed:0.19 green:0.57 blue:0.77 alpha:1.0].CGColor;
    self.personImg.layer.shadowColor = [UIColor colorWithRed:157.0 / 255.0 green:157.0 / 255.0 blue:157.0 / 255.0 alpha:0.8].CGColor;
    self.personImg.layer.shadowOpacity = 0.8;
    self.personImg.layer.shadowRadius = 5.0;
    self.personImg.layer.shadowOffset = CGSizeMake(1.0, 3.0);
    
    [self.upperRec.layer setCornerRadius:0.5];
    [self.upperRec.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.upperRec.layer setCornerRadius:5.0];
    [self.upperRec.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [self.upperRec.layer setShadowOpacity:0.6f];
}


@end
