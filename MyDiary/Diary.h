//
//  Diary.h
//  MyDiary
//
//  Created by Linquas on 01/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Realm/Realm.h>

@interface Diary : RLMObject

@property NSInteger key;
@property NSString *user;
@property NSString *title;
@property NSString *text;
@property NSString *weather;
@property NSString *mood;
@property NSString *loaction;
@property NSDate *date;





@end
