//
//  DiaryView.m
//  MyDiary
//
//  Created by Linquas on 12/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "DiaryView.h"

@interface DiaryView ()
@property (weak, nonatomic) IBOutlet UIView *bottomRec;

@end

@implementation DiaryView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.bottomRec.layer setCornerRadius:0.5];
    [self.bottomRec.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.bottomRec.layer setCornerRadius:5.0];
    [self.bottomRec.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [self.bottomRec.layer setShadowOpacity:0.6f];
    
}



@end
