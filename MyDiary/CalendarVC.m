//
//  CalendarVC.m
//  MyDiary
//
//  Created by Linquas on 04/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "CalendarVC.h"

#import <Realm/Realm.h>
#import "Diary.h"
#import "DiariesCell.h"
#import "ReadingVC.h"
@import Firebase;

@interface CalendarVC () 
@property (weak, nonatomic) IBOutlet UISegmentedControl *segementControl;
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) UIButton *previousButton;
@property (weak, nonatomic) UIButton *nextButton;
@property RLMResults *diariesArray;
@property (strong, nonatomic) NSMutableArray *fillColors;
@property (nonatomic, strong) RLMNotificationToken *token;
@property (strong, nonatomic) NSMutableArray *selectedDiary;
@property Diary *selected;

@end

@implementation CalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.segementControl addTarget:self action:@selector(segementChanged:) forControlEvents:UIControlEventValueChanged];
    self.selectedDiary = [[NSMutableArray alloc]init];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy/MM/dd";
    
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    
    self.calendar.dataSource = self;
    self.calendar.delegate = self;

    self.calendar = self.calendar;
    self.calendar.layer.cornerRadius = 10.0;
    
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *note, RLMRealm * realm) {
        [self loadDiaries];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadDiaries];
    [self loadToday];
}

- (IBAction)segementChanged:(id)sender {
    if (self.segementControl.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"calendarToEntries" sender:nil];
    }
    if (self.segementControl.selectedSegmentIndex == 2) {
        [self performSegueWithIdentifier:@"calendarToMe" sender:nil];
    }
}

// calendar delegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    [self.selectedDiary removeAllObjects];
    for (Diary *d in self.diariesArray) {
        NSString *tappedDate = [self.dateFormatter stringFromDate:date];
        if ([[self.dateFormatter stringFromDate:d.date] isEqualToString:tappedDate]) {
            [self.selectedDiary addObject:d];
        }
    }
    [self.tableview reloadData];
}

//color the days contains diary
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date {
    if ([self.fillColors containsObject:[self.dateFormatter stringFromDate:date]]) {
        return [UIColor purpleColor];
    }
    return nil;
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date {
    if ([self.fillColors containsObject:[self.dateFormatter stringFromDate:date]]) {
        return [UIColor whiteColor];
    }
    return nil;
}

// load data from realm
- (void)loadDiaries {
    RLMResults<Diary *> *All = [Diary objectsWhere: [NSString stringWithFormat:@"user = '%@'",[FIRAuth auth].currentUser.uid]];
    self.diariesArray = [All sortedResultsUsingKeyPath:@"key" ascending:YES];
    self.fillColors = [[NSMutableArray alloc]init];
    for (Diary *d in self.diariesArray) {
        [self.fillColors addObject: [self.dateFormatter stringFromDate:d.date]];
    }
}

//show today's diary
- (void)loadToday {
    [self.selectedDiary removeAllObjects];
    for (Diary *d in self.diariesArray) {
        NSString *today = [self.dateFormatter stringFromDate:[NSDate date]];
        if ([[self.dateFormatter stringFromDate:d.date] isEqualToString:today]) {
            [self.selectedDiary addObject:d];
            [self.tableview reloadData];
        }
    }
}

// tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectedDiary.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiariesCell *cell = (DiariesCell*)[self.tableview dequeueReusableCellWithIdentifier:@"calendarCell"];
    if (!cell) {
        cell = [[DiariesCell alloc]init];
    }
    Diary *diary = [self.selectedDiary objectAtIndex:indexPath.row];
    [cell update:diary];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selected = [self.selectedDiary objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"calendarReading" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"calendarReading"]) {
        ReadingVC *vc = (ReadingVC*)segue.destinationViewController;
        vc.diary = self.selected;
    }
}





@end
