//
//  Measurment.h
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile;

@interface Measurment : NSManagedObject

@property (nonatomic, retain) NSDate * fromDate;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * fat;
@property (nonatomic, retain) NSNumber * bone;
@property (nonatomic, retain) NSNumber * water;
@property (nonatomic, retain) NSNumber * muscule;
@property (nonatomic, retain) NSNumber * visceralFat;
@property (nonatomic, retain) NSNumber * kcal;
@property (nonatomic, retain) Profile *profile;

@end
