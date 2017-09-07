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
#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface LogInVC ()

@end

@implementation LogInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    [[GIDSignIn sharedInstance] signInSilently];
    
    GIDSignInButton *button = [[GIDSignInButton alloc]init];
    [button setFrame:CGRectMake(0, 0, DEVICE_WIDTH / 3, 50)];
    [button setCenter:self.view.center];
    [self.view addSubview:button];
    
}

// GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error == nil) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveUserData:user];
        });
        
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        
        //use credential to sign in firebase
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error) {
                                          NSLog(@"FireBase sign failed.\n%@",error);
                                          return;
                                      }
                                      NSLog(@"Google FireBase Logged IN");
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

- (void)saveUserData:(GIDGoogleUser *)user {
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
    usr.userId = user.userID;
    usr.key = user.userID.integerValue;
    usr.email = user.profile.email;
    usr.fullName = user.profile.name;
    usr.familyName = user.profile.familyName;
    usr.givenName = user.profile.givenName;
    [[RealmManager instance] addOrUpdateObject:usr];
//    NSLog(@"%@",usr.debugDescription);
}


@end
