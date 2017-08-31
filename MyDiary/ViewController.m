//
//  ViewController.m
//  MyDiary
//
//  Created by Linquas on 30/08/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "ViewController.h"
#import "DiariesCell.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *bottomRec;
@property (weak, nonatomic) IBOutlet UITableView *diariesTableView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.bottomRec.layer setCornerRadius:0.5];
    [self.bottomRec.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.bottomRec.layer setCornerRadius:5.0];
    [self.bottomRec.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [self.bottomRec.layer setShadowOpacity:0.6f];
    
    self.diariesTableView.dataSource = self;
    self.diariesTableView.delegate = self;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiariesCell *cell = (DiariesCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[DiariesCell alloc]init];
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DiariesCell *Cell = (DiariesCell*)cell;
    [Cell updateCell:20];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (IBAction)writeBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"writing" sender:nil];
}

@end
