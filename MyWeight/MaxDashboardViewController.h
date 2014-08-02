//
//  MaxDashboardViewController.h
//  MyWeight
//
//  Created by Maxim Donchenko on 28/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

#pragma mark - Line Chart

#define kJBColorLineChartControllerBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartHeader UIColorFromHex(0x1c474e)
#define kJBColorLineChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kJBColorLineChartDefaultSolidLineColor [UIColor colorWithWhite:1.0 alpha:0.5]
#define kJBColorLineChartDefaultSolidSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedLineColor [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]

#define localize(key, default) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], default, nil)

#define kJBStringLabelMm localize(@"label.kg", @"kg")
#define kJBStringLabelNationalAverage localize(@"label.date", @"Date")

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
@property (weak, nonatomic) IBOutlet UISegmentedControl* chartFilterSelector;
@property (weak, nonatomic) IBOutlet UITableViewCell* chartCell;

- (IBAction)saveMeasurment:(id)sender;
- (IBAction)filterChanged:(id)sender;

@end
