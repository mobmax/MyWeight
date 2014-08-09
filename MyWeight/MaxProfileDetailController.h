//
//  MaxProfileDetailController.h
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaxParameterPickerView.h"

@class Profile;

@interface MaxProfileDetailController : UITableViewController <MaxParameterPickerViewDelegate>

@property (assign, nonatomic) Profile* profile;
@property (weak, nonatomic) IBOutlet UITextField* userName;

@property  (weak, nonatomic) IBOutlet UITableViewCell* deviceCell;
@property  (weak, nonatomic) IBOutlet UITableViewCell* genderCell;
@property  (weak, nonatomic) IBOutlet UITableViewCell* ageCell;
@property  (weak, nonatomic) IBOutlet UITableViewCell* heightCell;
@property  (weak, nonatomic) IBOutlet UITableViewCell* levelCell;

@property  (strong, nonatomic) MaxParameterPickerView* pickerContainerView;

@end
