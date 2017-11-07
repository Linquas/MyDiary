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
#import "FirebaseManager.h"
#import "User.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <FontAwesomeKit/FAKFontAwesome.h>

@import LGButton;
@import GoogleSignIn;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import Firebase;

@interface AboutMeVC ()
@property (weak, nonatomic) IBOutlet GADBannerView *adBannerView;
@property RLMResults *user;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet LGButton *syncBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@end

@implementation AboutMeVC
#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adBannerView.adUnitID = @"ca-app-pub-4649001250005093/7380402746";
    self.adBannerView.rootViewController = self;
    [self.adBannerView loadRequest:[GADRequest request]];
    
    //data sync from firebase
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSync) name:@"dataSyncComplete" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkFirebaseStatusAndGetUser];
    [self loadUserPhotoAndName];
}
#pragma mark - Actions

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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UsingGoogle"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.parentViewController.presentingViewController.presentingViewController) {
            [self.parentViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)syncBtn:(id)sender {
    [[FirebaseManager instance] loadDiaryFromFirebase];
    self.syncBtn.isLoading = YES;
    [self addHUD];
}
#pragma mark - Private Method
- (void) dataSync {
    self.syncBtn.isLoading = NO;
    
    [self dissmissHUD];
}

- (void)addHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Loading...";
    hud.minSize = CGSizeMake(100.f, 100.f);
    self.view.userInteractionEnabled = NO;
}

- (void)dissmissHUD {
    FAKFontAwesome *checkMarkIcon = [FAKFontAwesome checkIconWithSize:20];
    UIImage *checkmarkImage = [checkMarkIcon imageWithSize:CGSizeMake(40, 40)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:checkmarkImage];
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    hud.customView = imageView;
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = @"Done!";
    [hud hideAnimated:YES afterDelay:1.f];
    self.view.userInteractionEnabled = YES;
}

- (void) loadUserPhotoAndName {
    if (self.user.count > 0) {
        User *user = [self.user objectAtIndex:0];
        if (user.fullName)
            self.nameLabel.text = user.fullName;
        if (user.photo)
            self.userImg.image = [UIImage imageWithData:user.photo];
    }
}

- (void) checkFirebaseStatusAndGetUser {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UsingFirebase"]) {
        [self.syncBtn setEnabled:YES];
        self.user = [[RealmManager instance] loadUserWithUid:[FIRAuth auth].currentUser.uid];
    } else {
        self.user = [[RealmManager instance] loadUserWithUid:[[NSUserDefaults standardUserDefaults] stringForKey:@"ID"]];
        [self.syncBtn setEnabled:NO];
    }
}
#pragma mark - Controller life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dataSyncComplete" object:nil];
}


@end
