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

@property (assign) NSInteger selectedRow;

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
        self.genderCell.detailTextLabel.text = [self.profile.gender integerValue] ? @"Male" : @"Female";
        self.ageCell.detailTextLabel.text = [self.profile.age stringValue];
        self.heightCell.detailTextLabel.text = [self.profile.height stringValue];
        switch ([self.profile.level integerValue]) {
            case 1:
                self.levelCell.detailTextLabel.text = @"Amateur";
                break;
            case 2:
                self.levelCell.detailTextLabel.text = @"Professional";
                break;
                
            default:
                self.levelCell.detailTextLabel.text = @"Normal";
                break;
        }
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row ) {
        case 1: {
            self.pickerContainerView = [[MaxParameterPickerView alloc] initWithTitle:@"Gender" min:0 max:0 uints:@[@"Female", @"Male"] forView:self.view.superview];
            [self.pickerContainerView.pickerView selectRow:[self.profile.gender integerValue] inComponent:0 animated:NO];
            self.pickerContainerView.pickerDelegate = self;
            [self.pickerContainerView showPickerContainerView];
            self.view.userInteractionEnabled = NO;
            self.selectedRow = indexPath.row;
            break;
        }
        case 2: {
            self.pickerContainerView = [[MaxParameterPickerView alloc] initWithTitle:@"Age" min:5 max:75 uints:nil forView:self.view.superview];
            [self.pickerContainerView selectFromInterger:[self.profile.age integerValue] animated:NO];
            self.pickerContainerView.pickerDelegate = self;
            [self.pickerContainerView showPickerContainerView];
            self.selectedRow = indexPath.row;
            self.view.userInteractionEnabled = NO;
            break;
        }
        case 3: {
            self.pickerContainerView = [[MaxParameterPickerView alloc] initWithTitle:@"Height" min:50 max:250 uints:@[@"sm", @"in"] forView:self.view.superview];
            [self.pickerContainerView selectFromInterger:[self.profile.height integerValue] animated:NO];
            self.pickerContainerView.pickerDelegate = self;
            [self.pickerContainerView showPickerContainerView];
            self.selectedRow = indexPath.row;
            self.view.userInteractionEnabled = NO;
            break;
        }
        case 4: {
            self.pickerContainerView = [[MaxParameterPickerView alloc] initWithTitle:@"Level" min:0 max:0 uints:@[@"Normal", @"Amateur", @"Professional"] forView:self.view.superview];
            [self.pickerContainerView.pickerView selectRow:[self.profile.level integerValue] inComponent:0 animated:NO];
            self.pickerContainerView.pickerDelegate = self;
            [self.pickerContainerView showPickerContainerView];
            self.view.userInteractionEnabled = NO;
            self.selectedRow = indexPath.row;
            break;
        }

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onCancel:(MaxParameterPickerView *)pickerView {
    [pickerView hidePickerContainerView];
    [self.pickerContainerView removeFromSuperview];
    self.pickerContainerView = nil;
    self.view.userInteractionEnabled = YES;
}

- (void)onDone:(MaxParameterPickerView *)pickerView {
    switch (self.selectedRow) {
        case 1: {
            self.profile.gender = [NSNumber numberWithInteger:[pickerView.pickerView selectedRowInComponent:0]];
            self.genderCell.detailTextLabel.text = [self.profile.gender integerValue] ? @"Male" : @"Female";
            break;
        }
        case 2: {
            self.profile.age = [NSNumber numberWithInteger:[pickerView getIntegerValue]];
            self.ageCell.detailTextLabel.text = [self.profile.age stringValue];
            break;
        }
        case 3: {
            self.profile.height = [NSNumber numberWithInteger:[pickerView getIntegerValue]];
            self.heightCell.detailTextLabel.text = [self.profile.height stringValue];
            break;
        }
        case 4: {
            self.profile.level = [NSNumber numberWithInteger:[pickerView.pickerView selectedRowInComponent:0]];
            switch ([self.profile.level integerValue]) {
                case 1:
                    self.levelCell.detailTextLabel.text = @"Amateur";
                    break;
                case 2:
                    self.levelCell.detailTextLabel.text = @"Professional";
                    break;
            
                default:
                    self.levelCell.detailTextLabel.text = @"Normal";
                    break;
            }
            break;
        }
    }
    [pickerView hidePickerContainerView];
    [self.pickerContainerView removeFromSuperview];
    self.pickerContainerView = nil;
    self.view.userInteractionEnabled = YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    MaxBTDevicesController *detailVC = [segue destinationViewController];
    detailVC.profile = self.profile;
}


@end
