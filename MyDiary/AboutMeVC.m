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

@import LGButton;
@import GoogleSignIn;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import Firebase;

@interface AboutMeVC ()
@property (weak, nonatomic) IBOutlet GADBannerView *adBannerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property RLMResults *user;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet LGButton *syncBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@end

@implementation AboutMeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adBannerView.adUnitID = @"ca-app-pub-4649001250005093/7380402746";
    self.adBannerView.rootViewController = self;
    [self.adBannerView loadRequest:[GADRequest request]];
    
    [self checkFirebaseStatus];
    
    [self loadUserPhotoAndName];
    
    [self.segmentControl addTarget:self action:@selector(segementChanged:) forControlEvents:UIControlEventValueChanged];
    
    //data sync from firebase
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSync) name:@"dataSyncComplete" object:nil];
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UsingFirebase"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isOffline"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"backToLogin" sender:nil];
    }
}

- (IBAction)syncBtn:(id)sender {
    [[DatabaseServices instance] loadDiaryFromFirebase];
    self.syncBtn.isLoading = YES;
}

- (void) dataSync {
    self.syncBtn.isLoading = NO;
}

- (void) loadUserPhotoAndName {
    User *user = [self.user objectAtIndex:0];
    if (user) {
        if (user.fullName)
            self.nameLabel.text = user.fullName;
        if (user.photo)
            self.userImg.image = [UIImage imageWithData:user.photo];
    }
}

- (void) checkFirebaseStatus {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UsingFirebase"]) {
        [self.syncBtn setEnabled:YES];
        self.user = [[RealmManager instance] loadUserWithUid:[FIRAuth auth].currentUser.uid];
    } else {
        self.user = [[RealmManager instance] loadUserWithUid:[[NSUserDefaults standardUserDefaults] stringForKey:@"ID"]];
        [self.syncBtn setEnabled:NO];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dataSyncComplete" object:nil];
}


@end
