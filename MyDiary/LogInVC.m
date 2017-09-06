//
//  LogInVC.m
//  MyDiary
//
//  Created by Linquas on 05/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "LogInVC.h"
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
    [[GIDSignIn sharedInstance] signInSilently];
    
    GIDSignInButton *button = [[GIDSignInButton alloc]init];
    [button setFrame:CGRectMake(0, 0, DEVICE_WIDTH / 3, 50)];
    [button setCenter:self.view.center];
    [self.view addSubview:button];
    
}


- (IBAction)signOut:(id)sender {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
    } else {
        NSLog(@"Logout");
    }
}

// GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error == nil) {
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
                                      NSLog(@"FireBase Logged IN");
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



@end
