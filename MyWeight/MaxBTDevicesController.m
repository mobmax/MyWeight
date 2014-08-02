//
//  MaxBTDevicesController.m
//  MyWeight
//
//  Created by Maxim Donchenko on 28/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "MaxBTDevicesController.h"
#import "AppDelegate.h"
#import "Device.h"

@interface MaxBTDevicesController ()

@property (strong) NSMutableArray *devices;

- (IBAction)refreshDevices:(id)sender;

@end

@implementation MaxBTDevicesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.devices = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if([appDelegate isLECapableHardware]) {
        [appDelegate stopScan];
        appDelegate.uiDelegate = self;
        [appDelegate startScan];
        [self.tableView reloadData];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate stopScan];
    appDelegate.uiDelegate = nil;
    self.devices = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)refreshDevices:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if([appDelegate isLECapableHardware]) {
        [appDelegate stopScan];
        [self.devices removeAllObjects];
        [self.tableView reloadData];
        [appDelegate startScan];
    }
}

#pragma mark - BTDeviceProtocol

- (void)didDiscoveredDevice:(CBPeripheral *)peripheral {
    if( ![self.devices containsObject:peripheral]) {
        [self.devices addObject:peripheral];
        [self.tableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"btDeviceCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.devices objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [self.devices objectAtIndex:indexPath.row];
    if (self.profile) {
        NSArray *devices = self.profile.devices.allObjects;
        NSInteger number = 0;
        for (Device* device in devices) {
            if ([device.number integerValue] > number) number = [device.number integerValue] + 1;
            if ([device.deviceID isEqualToString:[peripheral.identifier description]]) {
                number = [device.number integerValue];
                [self.profile removeDevicesObject:device];
            }
        }
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        Device* newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:appDelegate.managedObjectContext];
        newDevice.number = [NSNumber numberWithInteger:number];
        newDevice.deviceName = peripheral.name;
        newDevice.deviceID = [peripheral.identifier description];
        [self.profile addDevicesObject:newDevice];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
