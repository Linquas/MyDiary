//
//  RealmManager.h
//  MyDiary
//
//  Created by Linquas on 01/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Realm/Realm.h>

typedef  void (^onComplete)(void);

@interface RealmManager : NSObject

-(void)addOrUpdateObject:(RLMObject*)obj;
-(void)updateObject:(RLMObject*)obj;
-(void)deleteObject:(RLMObject*)obj;
-(void)deleteAllData;

@end
