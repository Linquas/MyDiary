//
//  LogInVC.m
//  MyDiary
//
//  Created by Linquas on 05/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "LogInVC.h"
#import "User.h"
#import "RealmManager.h"
#import "KFKeychain.h"
@import LGButton;

#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface LogInVC ()
@property (weak, nonatomic) IBOutlet LGButton *googleBtn;
@property (weak, nonatomic) IBOutlet LGButton *facebookBtn;
@property (weak, nonatomic) IBOutlet LGButton *offlineBtn;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@end

@implementation LogInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    [[GIDSignIn sharedInstance] signInSilently];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if ([self.userDefaults objectForKey:@"isOffline"]) {
        if ([self.userDefaults boolForKey:@"isOffline"])
            [self performSegueWithIdentifier:@"logInToDiary" sender:nil];
    }else if ([FBSDKAccessToken currentAccessToken]) {
        [self performSegueWithIdentifier:@"logInToDiary" sender:nil];
    }else if ([KFKeychain loadObjectForKey:@"google"]) {
        [self performSegueWithIdentifier:@"logInToDiary" sender:nil];
    }
}

#pragma mark -- GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error == nil) {
        
        GIDAuthentication *authentication = user.authentication;
        //save token to keychain
        [KFKeychain saveObject:authentication.idToken forKey:@"google"];
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        __block GIDGoogleUser *usr = user;
        __weak LogInVC *weakself = self;
        //use credential to sign in firebase
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      LogInVC* innerSelf = weakself;
                                      if (error) {
                                          NSLog(@"FireBase signin failed with google account.\n%@",error);
                                          self.googleBtn.isLoading = NO;
                                          [self.facebookBtn setEnabled:YES];
                                          [self.offlineBtn setEnabled:YES];
                                          return;
                                      }
                                      NSLog(@"Google FireBase Logged IN");
                                      [innerSelf saveGoogleUserData:usr];
                                      innerSelf.googleBtn.isLoading = NO;
                                      [self.facebookBtn setEnabled:YES];
                                      [self.offlineBtn setEnabled:YES];
                                      [weakself.userDefaults setBool:YES forKey:@"UsingFirebase"];
                                      [weakself.userDefaults synchronize];
                                      [innerSelf performSegueWithIdentifier:@"logInToDiary" sender:nil];
                                  }];
        } else {
            self.googleBtn.isLoading = NO;
            [self.facebookBtn setEnabled:YES];
            [self.offlineBtn setEnabled:YES];
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}

- (void)saveGoogleUserData:(GIDGoogleUser *)user {
    User *usr = [[User alloc]init];
    
    if ([GIDSignIn sharedInstance].currentUser.profile.hasImage)
    {
        NSUInteger dimension = round(CGSizeMake(130, 150).width * [[UIScreen mainScreen] scale]);
        NSURL *imageURL = [user.profile imageURLWithDimension:dimension];
        NSData *img = [NSData dataWithContentsOfURL:imageURL];
        if (img) {
            usr.photo = img;
        }
    }
    usr.userId = [FIRAuth auth].currentUser.uid;
    usr.key = user.userID.integerValue;
    usr.email = user.profile.email;
    usr.fullName = user.profile.name;
    usr.familyName = user.profile.familyName;
    usr.givenName = user.profile.givenName;
    [[RealmManager instance] addOrUpdateObject:usr];
//    NSLog(@"%@",usr.debugDescription);
}

- (IBAction)googleLoginBtn:(id)sender {
    self.googleBtn.isLoading = YES;
    [[GIDSignIn sharedInstance] signIn];
    [self.facebookBtn setEnabled:NO];
    [self.offlineBtn setEnabled:NO];
}

- (IBAction)fbLoginBtn:(id)sender {
    LGButton *btn = (LGButton*)sender;
    btn.isLoading = YES;
    [self.googleBtn setEnabled:NO];
    [self.offlineBtn setEnabled:NO];
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             NSLog(@"%@", error.localizedDescription);
             btn.isLoading = NO;
             [self.googleBtn setEnabled:YES];
             [self.offlineBtn setEnabled:YES];
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
             btn.isLoading = NO;
             [self.googleBtn setEnabled:YES];
             [self.offlineBtn setEnabled:YES];
         } else {
             NSLog(@"Logged in");
             FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                              credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
             __weak LogInVC *weakself = self;
             [[FIRAuth auth] signInWithCredential:credential
                                       completion:^(FIRUser *user, NSError *error) {
                                           LogInVC *innerSelf = weakself;
                                           if (error) {
                                               NSLog(@"Firebase signin failed with FB account.\n%@",error);
                                               btn.isLoading = NO;
                                               [self.googleBtn setEnabled:YES];
                                               [self.offlineBtn setEnabled:YES];
                                               return;
                                           }
                                           NSLog(@"Google Firebase Logged IN");
                                           [innerSelf saveFbUserData];
                                           btn.isLoading = NO;
                                           [self.googleBtn setEnabled:YES];
                                           [self.offlineBtn setEnabled:YES];
                                           [weakself.userDefaults setBool:YES forKey:@"UsingFirebase"];
                                           [weakself.userDefaults synchronize];
                                           [innerSelf performSegueWithIdentifier:@"logInToDiary" sender:nil];
                                       }];
             

         }
     }];
    
}

- (void)saveFbUserData {
    User *usr = [[User alloc]init];
    FBSDKGraphRequest *graphRequest = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me"parameters:@{@"fields":@"email,name,picture.type(large)"}];
    [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSDictionary *res = [[NSDictionary alloc]initWithDictionary:result];
            if ([res objectForKey:@"id"]) {
                NSString *str = [res objectForKey:@"id"];
                usr.userId = [FIRAuth auth].currentUser.uid;
                usr.key = str.integerValue;
            }
            if ([res objectForKey:@"email"]) {
                usr.email = [res objectForKey:@"email"];
            }
            if ([res objectForKey:@"name"]) {
                usr.fullName = [res objectForKey:@"name"];
            }
            if ([[[res objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]) {
                NSString *urlstr = [[[res objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                NSURL *url = [NSURL URLWithString:urlstr];
                NSData *img = [NSData dataWithContentsOfURL:url];
                if (img) {
                    usr.photo = img;
                }
            }
            [[RealmManager instance] addOrUpdateObject:usr];
//            NSLog(@"%@",usr.debugDescription);
        }
    }];

}

- (IBAction)loginOffline:(id)sender {
    [self performSegueWithIdentifier:@"loginToUserinfo" sender:nil];
}

@end
