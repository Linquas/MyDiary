//
//  User.h
//  MyDiary
//
//  Created by Linquas on 07/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Realm/Realm.h>

@interface User : RLMObject

@property NSString *userId;
@property NSInteger key;
@property NSString *fullName;
@property NSString *givenName;
@property NSString *familyName;
@property NSString *email;
@property NSData *photo;

@end
