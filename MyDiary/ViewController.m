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
        if (weakSelf.isUsingFirebase) {
            RLMResults *tmp = [[RealmManager instance] loadAllDataWithUid:[FIRAuth auth].currentUser.uid];
            if (!tmp || tmp.count != 0) {
                innerSelf.tableDataArray = tmp;
//                NSLog(@"%@", innerSelf.tableDataArray.debugDescription);
                [innerSelf.diariesTableView reloadData];
            }
        } else {
            RLMResults *tmp = [[RealmManager instance] loadAllDataWithUid:[[NSUserDefaults standardUserDefaults] stringForKey: @"ID"]];
            if (!tmp || tmp.count != 0) {
                innerSelf.tableDataArray = tmp;
//                NSLog(@"%@", innerSelf.tableDataArray.debugDescription);
                [innerSelf.diariesTableView reloadData];
            }
        }
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [self updateTableDataArray];
}

- (void)updateTableDataArray {
    if (self.isUsingFirebase) {
        self.tableDataArray = [[RealmManager instance] loadAllDataWithUid:[FIRAuth auth].currentUser.uid];
    } else {
        self.tableDataArray = [[RealmManager instance] loadAllDataWithUid:[[NSUserDefaults standardUserDefaults] stringForKey: @"ID"]];
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
    
    Diary *diary = [self.tableDataArray objectAtIndex:indexPath.row];
    [cell update:diary];
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDataArray count];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selected = [self.tableDataArray objectAtIndex:indexPath.row];
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
