//
//  Weather.h
//  MyDiary
//
//  Created by Linquas on 16/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property (nonatomic, copy) NSString* weatherDescription;
@property (nonatomic, copy) NSString* location;


- (instancetype)initWithWeatherDescription:(NSString*) weatherDesc withLocation:(NSString*)location;
- (instancetype)initWithJson:(id) jsonData;

@end
