//
//  HttpResponseErrorCode.h
//  MyDiary
//
//  Created by Linquas on 15/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NSInteger getErrorStatusCode (NSURLSessionDataTask *task);
NSInteger getErrorCode (NSError *error);
NSDictionary *getError (NSError *error);
