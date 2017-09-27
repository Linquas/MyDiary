//
//  DatabaseServices.h
//  MyDiary
//
//  Created by Linquas on 06/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Diary;

@interface FirebaseManager : NSObject

+ (instancetype) instance;
- (void) storeDiary:(Diary*)diary;
- (void) deleteDiary:(Diary*)diary;
- (void) loadDiaryFromFirebase;





@end
