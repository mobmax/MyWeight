//
//  MaxBTDevicesController.h
//  MyWeight
//
//  Created by Maxim Donchenko on 28/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreBluetooth/CoreBluetooth.h"
#import "AppDelegate.h"
#import "Profile.h"

@interface MaxBTDevicesController : UITableViewController <BTDeviceProtocol>

@property (assign, nonatomic) Profile* profile;

@end
