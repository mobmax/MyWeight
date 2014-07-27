//
//  Profile.h
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device, Goal, Measurment;

@interface Profile : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSSet *devices;
@property (nonatomic, retain) NSSet *measurments;
@property (nonatomic, retain) NSSet *goals;
@end

@interface Profile (CoreDataGeneratedAccessors)

- (void)addDevicesObject:(Device *)value;
- (void)removeDevicesObject:(Device *)value;
- (void)addDevices:(NSSet *)values;
- (void)removeDevices:(NSSet *)values;

- (void)addMeasurmentsObject:(Measurment *)value;
- (void)removeMeasurmentsObject:(Measurment *)value;
- (void)addMeasurments:(NSSet *)values;
- (void)removeMeasurments:(NSSet *)values;

- (void)addGoalsObject:(Goal *)value;
- (void)removeGoalsObject:(Goal *)value;
- (void)addGoals:(NSSet *)values;
- (void)removeGoals:(NSSet *)values;

@end
