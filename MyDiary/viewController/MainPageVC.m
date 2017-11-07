//
//  MainPageVC.m
//  MyDiary
//
//  Created by Linquas on 20/10/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "MainPageVC.h"
#import "Masonry.h"


@interface MainPageVC ()

@property (nonatomic, strong) UISegmentedControl *mainSegmentControl;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation MainPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *superview = self.view;
    
    UIView *upperRec = [[UIView alloc] init];
    [upperRec setFrame:CGRectMake(0, 0, deviceWidth, 105)];
    upperRec.backgroundColor = [UIColor whiteColor];
    [upperRec.layer setCornerRadius:0.5];
    [upperRec.layer setShadowColor:[UIColor blackColor].CGColor];
    [upperRec.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [upperRec.layer setShadowOpacity:0.6f];
    [self.view addSubview:upperRec];
    
    self.mainSegmentControl = [[UISegmentedControl alloc] init];
    self.mainSegmentControl.frame = CGRectMake(30,deviceHeight*4/100,deviceWidth-60,24);
    [self.mainSegmentControl insertSegmentWithTitle:@"日記" atIndex:1 animated:NO];
    [self.mainSegmentControl insertSegmentWithTitle:@"月曆" atIndex:2 animated:NO];
    [self.mainSegmentControl insertSegmentWithTitle:@"關於我" atIndex:3 animated:NO];
    self.mainSegmentControl.selectedSegmentIndex = 0;
    [self.mainSegmentControl addTarget:self action:@selector(changeSubView:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.mainSegmentControl];
    [self.mainSegmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superview.mas_centerX);
        make.top.mas_equalTo(24);
    }];
    
    UIColor *textColor = [UIColor colorWithRed:0.19 green:0.57 blue:0.77 alpha:1.0];
    self.nameLabel = [[UILabel alloc]init];
    self.nameLabel.frame = CGRectMake((deviceWidth/2)-35,deviceHeight*9/100, 100, 30);
    self.nameLabel.textColor = textColor;
    self.nameLabel.font = [UIFont fontWithName:@"Times New Roman" size:22];
    self.nameLabel.text = @"回味過去";
    [self.view addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superview.mas_centerX);
        make.top.equalTo(self.mainSegmentControl.mas_bottom).with.offset(10);
    }];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    self.diaries = [sb instantiateViewControllerWithIdentifier:@"diariesVC"];
    [self.diaries.view setFrame:CGRectMake(0, 106, deviceWidth, deviceHeight-105)];
    [self addChildViewController:_diaries];
    
    self.calendar = [sb instantiateViewControllerWithIdentifier:@"calendarVC"];
    [self.calendar.view setFrame:CGRectMake(0, 106, deviceWidth, deviceHeight-105)];
    
    self.aboutMe = [sb instantiateViewControllerWithIdentifier:@"aboutMeVC"];
    [self.aboutMe.view setFrame:CGRectMake(0, 106, deviceWidth, deviceHeight-105)];    
    
    [self.view addSubview:self.diaries.view];
    self.currentVC = self.diaries;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panRecognizer];
    
}

- (void)changeSubView:(UISegmentedControl*)seg {
    if (seg.selectedSegmentIndex == 0) {
        self.mainSegmentControl.selectedSegmentIndex = 0;
        self.nameLabel.text = @"回味過去";
        [self replaceController:self.currentVC newController:self.diaries];
    }
    if (seg.selectedSegmentIndex == 1) {
        self.nameLabel.text = @"故事線";
        self.mainSegmentControl.selectedSegmentIndex = 1;
        [self replaceController:self.currentVC newController:self.calendar];
    }
    if (seg.selectedSegmentIndex == 2) {
        self.nameLabel.text = @"你好";
        self.mainSegmentControl.selectedSegmentIndex = 2;
        [self replaceController:self.currentVC newController:self.aboutMe];
    }
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{    
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentVC = newController;
            
        }else{
            self.currentVC = oldController;
        }
    }];
}

+ (MainPageVC*) storyboardInstance {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageVC *mainVC = [sb instantiateViewControllerWithIdentifier:@"mainPageVC"];
    return mainVC;
}

- (void)pan:(UIPanGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gr translationInView:self.view];
        if (translation.x > 8) {
            NSInteger index = self.mainSegmentControl.selectedSegmentIndex - 1;
            if (index >= 0) {
//                NSLog(@"Right");
                self.mainSegmentControl.selectedSegmentIndex = index;
                [self.mainSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
        if (translation.x < -8) {
            NSInteger index = self.mainSegmentControl.selectedSegmentIndex + 1;
            if (index <= 2) {
//                NSLog(@"Left");
                self.mainSegmentControl.selectedSegmentIndex = index;
                [self.mainSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
        [gr setTranslation:CGPointZero inView:self.view];
    }
}


@end
