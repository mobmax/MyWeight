//
//  Device.h
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSString * deviceID;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Profile *profile;

@end
