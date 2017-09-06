//
//  RealmManager.m
//  MyDiary
//
//  Created by Linquas on 01/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "RealmManager.h"

@interface RealmManager()

@property RLMRealm *realm;

@end

@implementation RealmManager


-(void)addOrUpdateObject:(RLMObject*)obj {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMRealm* realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:obj];
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



@end
