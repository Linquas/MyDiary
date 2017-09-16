//
//  HttpResponseErrorCode.m
//  MyDiary
//
//  Created by Linquas on 15/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "HttpResponseErrorCode.h"

NSInteger getErrorStatusCode (NSURLSessionDataTask *task) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
    return (NSInteger)httpResponse.statusCode;
}
NSInteger getErrorCode (NSError *error) {
    if (!error.userInfo[AFNetworkingOperationFailingURLRequestErrorKey]) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:(NSData*)error.userInfo[AFNetworkingOperationFailingURLRequestErrorKey] options:0 error:nil];
        NSString *errorCode = responseDict[@"errorCode"];
        return errorCode.intValue;
    } else {
        return 901;
    }
}
NSDictionary *getError (NSError *error) {
    if (!error.userInfo[AFNetworkingOperationFailingURLRequestErrorKey]) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:(NSData*)error.userInfo[AFNetworkingOperationFailingURLRequestErrorKey] options:0 error:nil];
        return responseDict;
    } else {
        return nil;
    }
}
