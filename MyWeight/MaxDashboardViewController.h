//
//  MaxDashboardViewController.h
//  MyWeight
//
//  Created by Maxim Donchenko on 28/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MaxDashboardViewController : UITableViewController <BTDeviceProtocol>

@property (weak, nonatomic) IBOutlet UILabel* resultLabel;

@end
