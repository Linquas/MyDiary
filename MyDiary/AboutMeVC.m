//
//  AboutMeVC.m
//  MyDiary
//
//  Created by Linquas on 04/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "AboutMeVC.h"

@interface AboutMeVC ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end

@implementation AboutMeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.segmentControl addTarget:self action:@selector(segementChanged:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)segementChanged:(id)sender {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"meToDiary" sender:nil];
    }
    if (self.segmentControl.selectedSegmentIndex == 1) {
        [self performSegueWithIdentifier:@"meToCalendar" sender:nil];
    }
}


@end
