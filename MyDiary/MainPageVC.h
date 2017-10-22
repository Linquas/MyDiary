//
//  MainPageVC.h
//  MyDiary
//
//  Created by Linquas on 20/10/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarVC.h"
#import "AboutMeVC.h"
#import "DiariesVC.h"

#define deviceWidth [UIScreen mainScreen].bounds.size.width
#define deviceHeight [UIScreen mainScreen].bounds.size.height

@interface MainPageVC : UIViewController

@property (nonatomic ,strong) UIViewController *currentVC;

@property (nonatomic, strong) DiariesVC *diaries;
@property (nonatomic, strong) AboutMeVC *aboutMe;
@property (nonatomic, strong) CalendarVC *calendar;
+ (MainPageVC*) storyboardInstance;


@end
