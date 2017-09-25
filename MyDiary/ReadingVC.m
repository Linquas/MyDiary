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
#import "WritingVC.h"

@interface ReadingVC ()
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *titleTextView;
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (nonatomic) BOOL isUsingFirebase;

@end

@implementation ReadingVC
#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleTextView.text = self.diary.title;
    self.titleTextView.editable = NO;
    self.contentTextView.text = self.diary.text;
    self.contentTextView.editable = NO;
    self.isUsingFirebase = [[NSUserDefaults standardUserDefaults] boolForKey:@"UsingFirebase"];
    [self updateDate];
    
}
#pragma mark - Actions
- (IBAction)deleteBtn:(id)sender {
    UIAlertController* deleteAlert = [UIAlertController alertControllerWithTitle:@"你確定要刪除日記?" message:@"你的心情將深藏在你的心中" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* close = [UIAlertAction actionWithTitle:@"確定"
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction * action) {
                                                      if (self.isUsingFirebase) {
                                                          [[DatabaseServices instance] deleteDiary:self.diary];
                                                      }
                                                      [[RealmManager instance] deleteObject: self.diary];
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                  }];
    [deleteAlert addAction:close];
    UIAlertAction *resume = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                         [deleteAlert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [deleteAlert addAction:resume];
    [self presentViewController:deleteAlert animated:YES completion:nil];
}
- (IBAction)editBtn:(id)sender {
    [self performSegueWithIdentifier:@"readingToWriting" sender:nil];
}

- (IBAction)closeBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Private method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"readingToWriting"]) {
        WritingVC *vc =  (WritingVC*)segue.destinationViewController;
        vc.diary = self.diary;
    }
}

- (void)updateDate {
    self.monthLabel.text = [self.diary.date monthInString];
    self.dayLabel.text = [self.diary.date dayInString];
    self.yearLabel.text = [self.diary.date yearInString];
    self.weekdayLabel.text = [self.diary.date weekdayInString];
}


@end
