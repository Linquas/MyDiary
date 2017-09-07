//
//  ReadingVC.m
//  MyDiary
//
//  Created by Linquas on 02/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "ReadingVC.h"
#import "NSDate+YearMonthDay.h"
#import "PlaceHoldUITextView.h"
#import "RealmManager.h"
#import "DatabaseServices.h"

@interface ReadingVC ()
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *titleTextView;
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;

@end

@implementation ReadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleTextView.text = self.diary.title;
    [self.titleTextView setEditable:NO];
    self.contentTextView.text = self.diary.text;
    [self.titleTextView setEditable:NO];
    [self updateDate];
    
}

- (void)updateDate {
    self.monthLabel.text = [self.diary.date monthInString];
    self.dayLabel.text = [self.diary.date dayInString];
    self.yearLabel.text = [self.diary.date yearInString];
    self.weekdayLabel.text = [self.diary.date weekdayInString];
}

- (IBAction)deleteBtn:(id)sender {
    [[DatabaseServices instance] deleteDiary:self.diary];
    [[RealmManager instance] deleteObject: self.diary];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
