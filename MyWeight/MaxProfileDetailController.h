//
//  MaxProfileDetailController.h
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Profile;

@interface MaxProfileDetailController : UITableViewController

@property (assign, nonatomic) Profile* profile;
@property (weak, nonatomic) IBOutlet UITextField* userName;
@property (weak, nonatomic) IBOutlet UITextField* gender;
@property (weak, nonatomic) IBOutlet UITextField* age;
@property (weak, nonatomic) IBOutlet UITextField* height;
@property (weak, nonatomic) IBOutlet UITextField* level;

@property  (weak, nonatomic) IBOutlet UITableViewCell* deviceCell;

@end
