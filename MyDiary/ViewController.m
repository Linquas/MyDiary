//
//  ViewController.m
//  MyDiary
//
//  Created by Linquas on 30/08/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Realm/Realm.h>
#import "ViewController.h"
#import "DiariesCell.h"
#import "RealmManager.h"
#import "Diary.h"
#import "ReadingVC.h"
#import "NSDate+YearMonthDay.h"
@import Firebase;


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *bottomRec;
@property (weak, nonatomic) IBOutlet UITableView *diariesTableView;
@property (nonatomic) RealmManager *realmManager;
@property RLMResults *tableDataArray;
@property Diary *selected;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segementControl;
@property (nonatomic) BOOL isUsingFirebase;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *sectionData;

// realm notification
@property (strong, nonatomic) RLMNotificationToken *token;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //add refresh to top item of tableview
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    [self.diariesTableView insertSubview:refreshView atIndex:0];
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(reloadTableView) forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:self.refreshControl];
    
    [self.segementControl addTarget:self action:@selector(segementChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.diariesTableView.dataSource = self;
    self.diariesTableView.delegate = self;
    
    self.isUsingFirebase = [[NSUserDefaults standardUserDefaults] boolForKey:@"UsingFirebase"];
    
    __weak ViewController *weakSelf = self;
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *note, RLMRealm * realm) {
        ViewController *innerSelf = weakSelf;
        [innerSelf updateTableDataArray];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateTableDataArray];
}

- (void)updateTableDataArray {
    if (self.isUsingFirebase) {
        self.sectionData = [[RealmManager instance] loadDiaryInMonthWithUid:[FIRAuth auth].currentUser.uid];
    } else {
        self.sectionData = [[RealmManager instance] loadDiaryInMonthWithUid:[[NSUserDefaults standardUserDefaults] stringForKey: @"ID"]];
    }
    [self.diariesTableView reloadData];
}

- (IBAction)segementChanged:(id)sender {
    if (self.segementControl.selectedSegmentIndex == 1) {
        [self performSegueWithIdentifier:@"entriesToCalendar" sender:nil];
    }
    if (self.segementControl.selectedSegmentIndex == 2) {
        [self performSegueWithIdentifier:@"diaryToME" sender:nil];
    }
}

#pragma mark - tableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiariesCell *cell = (DiariesCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[DiariesCell alloc]init];
    }
    Diary *diary = self.sectionData[indexPath.section][indexPath.row];
    [cell update:diary];
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sectionData[section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 35)];
    [view setBackgroundColor:[UIColor clearColor]];
    UILabel *month = [[UILabel alloc]initWithFrame:CGRectMake(8, 5, 200, 40)];
    Diary *a = self.sectionData[section][0];
    month.text = [a.date monthInString];
    month.textColor = [UIColor whiteColor];
    [view addSubview:month];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selected = self.sectionData[indexPath.section][indexPath.row];
    [self performSegueWithIdentifier:@"reading" sender:nil];
}

- (IBAction)writeBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"writing" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"reading"]) {
        ReadingVC *vc = (ReadingVC*)segue.destinationViewController;
        vc.diary = self.selected;
    }
}

-(void)reloadTableView
{
    [self updateTableDataArray];
    [self.refreshControl endRefreshing];
}



@end
