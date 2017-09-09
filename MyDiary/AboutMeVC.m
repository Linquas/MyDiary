//
//  AboutMeVC.m
//  MyDiary
//
//  Created by Linquas on 04/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "AboutMeVC.h"
#import <Realm/Realm.h>
#import "RealmManager.h"
#import "DatabaseServices.h"
#import "User.h"
@import GoogleSignIn;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import Firebase;

@interface AboutMeVC ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property RLMResults *user;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@end

@implementation AboutMeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [[RealmManager instance] loadUserWithUid:[FIRAuth auth].currentUser.uid];
    User *user = [self.user objectAtIndex:0];
    if (user) {
        if (user.fullName)
            self.nameLabel.text = user.fullName;
        if (user.photo)
            self.userImg.image = [UIImage imageWithData:user.photo];
    }
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
- (IBAction)logoutBtn:(id)sender {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    
    if ([GIDSignIn sharedInstance].currentUser) {
        [[GIDSignIn sharedInstance] signOut];
    } else if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKLoginManager alloc]init] logOut];
    }
    
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
    } else {
        NSLog(@"Logout");
        [self performSegueWithIdentifier:@"backToLogin" sender:nil];
    }
}
- (IBAction)syncBtn:(id)sender {
    [[DatabaseServices instance] loadDiaryFromFirebase];
}


@end
