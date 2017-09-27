//
//  DatabaseServices.m
//  MyDiary
//
//  Created by Linquas on 06/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "FirebaseManager.h"
#import "RealmManager.h"
#import "NSDate+YearMonthDay.h"
#import "Diary.h"
@import Firebase;
@import FirebaseDatabase;
#define USER_UID [FIRAuth auth].currentUser.uid
#define DB_REF [[FIRDatabase database] reference]
#define DIARY_KEY [NSString stringWithFormat:@"%ld",diary.key]

@interface FirebaseManager ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation FirebaseManager

+ (instancetype) instance {
    static FirebaseManager *sharedInstance = nil;
    
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[FirebaseManager alloc] initPrivate];
        }
    }
    return sharedInstance;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use instance" userInfo:nil];
}

- (instancetype)initPrivate {
    self = [super init];
    return self;
}


- (void) storeDiary:(Diary*)diary {
    self.ref = DB_REF;
    NSString *usr_uid = USER_UID;
    NSDictionary *post = @{@"weather": diary.weather,
                           @"location": diary.loaction,
                           @"date": [NSNumber numberWithInteger:diary.key],
                           @"title": diary.title,
                           @"text": diary.text,
                           @"time": diary.date.timeInString};
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/%ld", usr_uid, (long)diary.key]: post};
    [self.ref updateChildValues:childUpdates];
}

- (void) deleteDiary:(Diary*)diary {
    self.ref = [[FIRDatabase database] reference];
    [[[[self.ref child:@"users"] child:USER_UID] child:[NSString stringWithFormat:@"%ld",(long)diary.key]] removeValue];
}

- (void) loadDiaryFromFirebase {
    self.ref = [[FIRDatabase database] reference];
    [[[self.ref child:@"users"] child:USER_UID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.hasChildren) {
            [[RealmManager instance]saveDatafromFirebase:snapshot.value];
        } else {
            NSLog(@"No data from firebase");
        }
        
    }];
}

@end
