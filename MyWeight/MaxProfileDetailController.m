//
//  MaxProfileDetailController.m
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "MaxProfileDetailController.h"
#import "AppDelegate.h"
#import "Device.h"
#import "MaxBTDevicesController.h"

@interface MaxProfileDetailController ()

- (void)doneEditing;

@end

@implementation MaxProfileDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.currentProfile) {
        self.userName.text = self.profile.userName;
        self.gender.text = [self.profile.gender stringValue];
        self.age.text = [self.profile.age stringValue];
        self.height.text = [self.profile.height stringValue];
        self.level.text = [self.profile.level stringValue];
        
        NSArray* devices = self.profile.devices.allObjects;
        if ([devices count] > 0) {
            Device* device = [devices firstObject];
            self.deviceCell.textLabel.text = device.deviceName;
            self.deviceCell.detailTextLabel.text = [device.number stringValue];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.currentProfile == nil) {
        [self.navigationItem setHidesBackButton:YES animated:NO];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    } else {
        NSArray* devices = self.profile.devices.allObjects;
        if ([devices count] > 0) {
            Device* device = [devices firstObject];
            self.deviceCell.textLabel.text = device.deviceName;
            self.deviceCell.detailTextLabel.text = [device.number stringValue];
        }
    }
}


- (void)doneEditing {
    if ([self.userName.text length] > 0) {
//        self.profile.userName = self.userName.text;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.currentProfile = self.profile;
        [appDelegate saveProfile];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.profile.userName = self.userName.text;
    self.profile.gender = [NSNumber numberWithInteger:[self.gender.text integerValue]];
    self.profile.age = [NSNumber numberWithInteger:[self.age.text integerValue]];
    self.profile.height = [NSNumber numberWithInteger:[self.height.text integerValue]];
    self.profile.level = [NSNumber numberWithInteger:[self.level.text integerValue]];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    MaxBTDevicesController *detailVC = [segue destinationViewController];
    detailVC.profile = self.profile;
}


@end
