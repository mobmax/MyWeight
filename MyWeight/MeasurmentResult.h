//
//  MeasurmentResult.h
//  MyWeight
//
//  Created by Maxim Donchenko on 28/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MaxUnits){
    Metric,
    Imperial
};

@interface MeasurmentResult : NSObject

@property (assign) Float32 weight;
@property (assign) NSInteger level;
@property (assign) NSInteger group;
@property (assign) NSInteger gender;
@property (assign) NSInteger age;
@property (assign) NSInteger height;
@property (assign) Float32 fat;
@property (assign) Float32 bone;
@property (assign) Float32 muscule;
@property (assign) NSInteger visceralFat;
@property (assign) Float32 water;
@property (assign) NSInteger Kcal;

@property (assign) BOOL isValid;
@property (copy, nonatomic) NSString* errorDescription;

+ (MeasurmentResult *)resultWithData:(NSData *)data units:(MaxUnits)units;

@end
