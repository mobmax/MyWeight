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

@property (weak, nonatomic) IBOutlet UILabel* weightLabel;
@property (weak, nonatomic) IBOutlet UILabel* unitLabel;

@property (weak, nonatomic) IBOutlet UILabel* fatLabel;
@property (weak, nonatomic) IBOutlet UILabel* boneLabel;
@property (weak, nonatomic) IBOutlet UILabel* musculeLabel;
@property (weak, nonatomic) IBOutlet UILabel* waterLabel;
@property (weak, nonatomic) IBOutlet UILabel* viscelarFatLabel;
@property (weak, nonatomic) IBOutlet UILabel* kcalLabel;

@property (weak, nonatomic) IBOutlet UIImageView* scaleImg;

@property (weak, nonatomic) IBOutlet UIButton* saveButton;
@property (weak, nonatomic) IBOutlet UITableViewCell* chatCell;

- (IBAction)saveMeasurment:(id)sender;

@end
