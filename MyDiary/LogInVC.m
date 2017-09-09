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
@import LGButton;

#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface LogInVC ()
@property (weak, nonatomic) IBOutlet LGButton *googleBtn;

@end

@implementation LogInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    [[GIDSignIn sharedInstance] signInSilently];
    
}

- (void)viewDidAppear:(BOOL)animated {
    if ([FBSDKAccessToken currentAccessToken]) {
        [self performSegueWithIdentifier:@"logInToDiary" sender:nil];
    }
}

#pragma mark -- GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error == nil) {
        
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        __block GIDGoogleUser *u = user;
        //use credential to sign in firebase
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error) {
                                          NSLog(@"FireBase signin failed with google account.\n%@",error);
                                          self.googleBtn.isLoading = NO;
                                          return;
                                      }
                                      NSLog(@"Google FireBase Logged IN");
                                      [self saveGoogleUserData:u];
                                      self.googleBtn.isLoading = NO;
                                      [self performSegueWithIdentifier:@"logInToDiary" sender:nil];
                                  }];
        } else {
        // ...
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
}

- (IBAction)fbLoginBtn:(id)sender {
    LGButton *btn = (LGButton*)sender;
    btn.isLoading = YES;
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             NSLog(@"%@", error.localizedDescription);
             btn.isLoading = NO;
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
             btn.isLoading = NO;
         } else {
             NSLog(@"Logged in");
             FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                              credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
             __weak LogInVC *weakself = self;
             [[FIRAuth auth] signInWithCredential:credential
                                       completion:^(FIRUser *user, NSError *error) {
                                           LogInVC *innerSelf = weakself;
                                           if (error) {
                                               NSLog(@"FireBase signin failed with FB account.\n%@",error);
                                               btn.isLoading = NO;
                                               return;
                                           }
                                           NSLog(@"Google FireBase Logged IN");
                                           [innerSelf saveFbUserData];
                                           btn.isLoading = NO;
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


@end
