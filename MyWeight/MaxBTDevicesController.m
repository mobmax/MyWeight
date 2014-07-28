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
@property (strong) CBCentralManager *manager;

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
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self isLECapableHardware]) {
        [self startScan];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScan];
    self.manager = nil;
    self.devices = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)refreshDevices:(id)sender {
    [self stopScan];
    [self.devices removeAllObjects];
    [self.tableView reloadData];
    [self startScan];
}


#pragma mark - Start/Stop Scan methods
/*
 Request CBCentralManager to scan for health thermometer peripherals using service UUID 0xFFF0
 */
- (void)startScan
{
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [self.manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFF0"]] options:options];
}

/*
 Request CBCentralManager to stop scanning for health thermometer peripherals
 */
- (void)stopScan
{
    [self.manager stopScan];
}

- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([self.manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    return FALSE;
}


#pragma mark - CBManagerDelegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
    
}

/*
 Invoked when the central discovers thermometer peripheral while scanning.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData);
    
    if( ![self.devices containsObject:peripheral] )
        [self.devices addObject:peripheral];

    [self.tableView reloadData];
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
        for (Device* device in devices) {
            [self.profile removeDevicesObject:device];
        }
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        Device* newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:appDelegate.managedObjectContext];
        newDevice.number = [NSNumber numberWithInteger:0];
        newDevice.deviceName = peripheral.name;
        newDevice.deviceID = [peripheral.identifier description];
        [self.profile addDevicesObject:newDevice];
        [self.navigationController popViewControllerAnimated:YES];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
