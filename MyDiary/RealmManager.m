//
//  RealmManager.m
//  MyDiary
//
//  Created by Linquas on 01/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "RealmManager.h"
@import Firebase;
#import "Diary.h"
#import "User.h"
#import "NSDate+YearMonthDay.h"

@interface RealmManager()

@property RLMRealm *realm;

@end

@implementation RealmManager

+(instancetype)instance {
    RealmManager *sharedInstance = nil;
    
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[RealmManager alloc]init];
        }
    }
    return sharedInstance;
}

-(void)addOrUpdateObject:(RLMObject*)obj {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMRealm* realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    });
}

-(void)updateObject:(RLMObject*)obj {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMRealm* realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    });
}

-(void)deleteObject:(RLMObject*)obj {
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:obj];
    [realm commitWriteTransaction];
}

-(void)deleteAllData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMRealm* realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
    });
}

-(RLMResults*)loadAllDataWithUid:(NSString*)uid {
    if ([uid isEqualToString:@""] || !uid) {
        NSLog(@"Empty uid");
        return nil;
    }
    RLMResults<Diary *> *diaries = [Diary objectsWhere: [NSString stringWithFormat:@"user = '%@'",uid]];
    return [diaries sortedResultsUsingKeyPath:@"key" ascending:YES];
}

- (RLMResults*)loadUserWithUid:(NSString*)uid {
    if ([uid isEqualToString:@""] || !uid) {
        NSLog(@"Empty uid");
        return nil;
    }
    RLMResults<User *> *Users = [User objectsWhere: [NSString stringWithFormat:@"userId = '%@'",uid]];
    return Users;
}

-(RLMResults*)loadAllUser {
    return [User allObjects];
}

-(void)saveDatafromFirebase:(NSDictionary*)data {
    if (!data) {
        NSLog(@"No data from firebase");
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Start to save to realm");
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMddHHmmss"];

        RLMRealm* realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        for (NSString *key in data) {
            if ([data objectForKey:key] == [NSNull null])
                break;
            Diary *usr = [[Diary alloc]init];
            usr.key = [NSString stringWithFormat:@"%@", [[data objectForKey:key] objectForKey:@"date"]].integerValue;
            usr.title = [[data objectForKey:key] objectForKey:@"title"];
            usr.text = [[data objectForKey:key] objectForKey:@"text"];
            usr.weather = [[data objectForKey:key] objectForKey:@"weather"];
            usr.date = [dateFormat dateFromString:[NSString stringWithFormat:@"%@", [[data objectForKey:key] objectForKey:@"date"]]];
            usr.user = [FIRAuth auth].currentUser.uid;
            [realm addOrUpdateObject:usr];
        }
        [realm commitWriteTransaction];
        NSLog(@"Sync Conplete");
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"dataSyncComplete" object:self];
        });
    });
}

-(NSArray*)loadDiaryInMonthWithUid:(NSString*)uid {
    RLMResults<Diary *> *diaries = [Diary objectsWhere: [NSString stringWithFormat:@"user = '%@'",uid]];
    return [self relocateDataInMonth:[diaries sortedResultsUsingKeyPath:@"key" ascending:YES]];
}

// separate diary data into group of month
-(NSArray*)relocateDataInMonth:(RLMResults*)result{
//    NSLog(@"%@", result.debugDescription);
    NSMutableArray *head = [[NSMutableArray alloc]init];
    NSMutableArray *days = [[NSMutableArray alloc]init];
    NSMutableString *month = [[NSMutableString alloc]init];
    Diary *first = result[0];
    month = [NSMutableString stringWithString:[first.date monthInString]];
    for (Diary* d in result) {
        if ( ![[d.date monthInString] isEqualToString:month]) {
            [head addObject:[days copy]];
            month = [NSMutableString stringWithString:[d.date monthInString]];
            [days removeAllObjects];
            [days addObject:d];
            continue;
        }
        [days addObject:d];
    }
    [head addObject:[days copy]];
    return head;
}

@end
