//
//  DatabaseServices.m
//  MyDiary
//
//  Created by Linquas on 06/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "DatabaseServices.h"
#import "RealmManager.h"
#import "NSDate+YearMonthDay.h"
#define USER_UID [FIRAuth auth].currentUser.uid
#define DB_REF [[FIRDatabase database] reference]
#define DIARY_KEY [NSString stringWithFormat:@"%ld",diary.key]

@interface DatabaseServices ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation DatabaseServices

+ (id) instance {
    static DatabaseServices *sharedInstance = nil;
    
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[DatabaseServices alloc]init];
        }
    }
    return sharedInstance;
}

- (void) storeDiary:(Diary*)diary {
    self.ref = DB_REF;
    NSString *usr_uid = USER_UID;
    NSDictionary *post = @{@"weather": @"sunny",
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
