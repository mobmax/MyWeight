//
//  AppDelegate.m
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) CBPeripheral *testPeripheral;

- (void)getWeight:(NSInteger)profileNum gender:(NSInteger)gender level:(NSInteger)level Height:(NSInteger)height Age:(NSInteger)age unit:(NSInteger)unit;
- (void)shutdown;

@end

@implementation AppDelegate

@synthesize manager = _manager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self manager];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self stopScan];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([self isLECapableHardware])
        [self startScan];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (CBCentralManager *)manager{
    if (_manager == nil) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _manager;
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
            state = @"Unknow.";
            break;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    return FALSE;
}

- (NSArray *)retrieveConnectedPrephirals {
   return [self.manager retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFF0"]]];
}

- (void)doMeasurment:(CBPeripheral *)peripheral {
    self.testPeripheral = peripheral;
    [self.manager connectPeripheral:self.testPeripheral options:nil];
}

- (void)getWeight:(NSInteger)profileNum gender:(NSInteger)gender level:(NSInteger)level Height:(NSInteger)height Age:(NSInteger)age unit:(NSInteger)unit {
    // = {0xFE, 0x03, 0x01, 0x00, 0xAA, 0x19, 0x01, 0xB0}
    char dataToSend[8] = {0};
    
    dataToSend[0] = 0xFE;
    dataToSend[1] = profileNum;
    dataToSend[2] = gender;
    dataToSend[3] = level;
    dataToSend[4] = height;
    dataToSend[5] = age;
    dataToSend[6] = unit;
    dataToSend[7] = dataToSend[1] ^ dataToSend[2] ^ dataToSend[3] ^ dataToSend[4] ^ dataToSend[5] ^ dataToSend[6];
    [self.testPeripheral writeValue:[NSData dataWithBytes:dataToSend length:sizeof(dataToSend)] forCharacteristic:self.measurmentControlChar type:CBCharacteristicWriteWithResponse];
    
}

- (void)shutdown {
    char dataToSend[] = {0xFD, 0x35, 0, 0, 0, 0, 0, 0x35};
    
    [self.testPeripheral writeValue:[NSData dataWithBytes:dataToSend length:sizeof(dataToSend)] forCharacteristic:self.measurmentControlChar type:CBCharacteristicWriteWithResponse];
    
}


#pragma mark - CBManagerDelegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self isLECapableHardware])
        [self startScan];
}

/*
 Invoked when the central discovers thermometer peripheral while scanning.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData);
    
    if (self.uiDelegate) {
        [self.uiDelegate performSelector:@selector(didDiscoveredDevice:) withObject:peripheral];
    }

    [self.manager retrievePeripheralsWithIdentifiers:@[peripheral.identifier]];
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %lu - %@", (unsigned long)[peripherals count], peripherals);
    
    [self stopScan];
    
    /* If there are any known devices, automatically connect to it.*/
    if([peripherals count] >=1)
    {
        self.testPeripheral = [peripherals objectAtIndex:0];
        [self.manager connectPeripheral:self.testPeripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect to peripheral: %@", peripheral);
    
    self.testPeripheral = peripheral;
    [self.testPeripheral setDelegate:self];
    [self.testPeripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did Disconnect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);
    [self.testPeripheral setDelegate:nil];
    self.testPeripheral = nil;
    
    if ([self.uiDelegate respondsToSelector:@selector(didDiconnect)]) {
        [self.uiDelegate performSelector:@selector(didDiconnect) withObject:nil];
    }

    [self startScan];

}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);
    [self.testPeripheral setDelegate:nil];
    self.testPeripheral = nil;
}

#pragma mark - CBPeripheralDelegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    for (CBService * service in peripheral.services)
    {
        NSLog(@"Service found with UUID: %@", service.UUID);
        
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"FFF0"]])
        {
            /* Thermometer Service - discover termperature measurement, intermediate temperature measturement and measurement interval characteristics */
            [peripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:@"FFF1"], [CBUUID UUIDWithString:@"FFF4"], nil] forService:service];
        }
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"FFF0"]])
    {
        for (CBCharacteristic * characteristic in service.characteristics)
        {
            NSLog(@"Serviсe %@ characteristic %@ found", service.UUID, characteristic.UUID);
            
            /* Set indication on temperature measurement */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]])
            {
                self.measurmentControlChar = characteristic;
                //                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                
                //                [peripheral readValueForCharacteristic:characteristic];
                
            }
            /* Set notification on intermediate temperature measurement */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF4"]])
            {
                NSLog(@"Subscribe for notification for serviсe %@ characteristic %@", service.UUID, characteristic.UUID);
                self.weightMeasurementChar = characteristic;
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                //                [peripheral readValueForCharacteristic:characteristic];
                
            }
        }
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    } else {
        NSLog(@"Characteristic %@ value %@", characteristic.UUID, characteristic.value);
        
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF4"]])
        {
            NSLog(@"Got result");
            
            MeasurmentResult *result = [MeasurmentResult resultWithData:characteristic.value units:self.selectedUnits];
            if ([self.uiDelegate respondsToSelector:@selector(measurmentResut:)]) {
                [self.uiDelegate performSelector:@selector(measurmentResut:) withObject:result];
            }
            [self shutdown];
//            [self startScan];
        }
    }
}

/*
 Invoked upon completion of a -[writeValue:forCharacteristic:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error writing value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
}

/*
 Invoked upon completion of a -[setNotifyValue:forCharacteristic:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating notification state for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    [self getWeight:0 gender:[self.currentProfile.gender intValue]  level:[self.currentProfile.level intValue] Height:[self.currentProfile.height intValue] Age:[self.currentProfile.age intValue] unit:self.selectedUnits == Metric ? 1 : 0];
    NSLog(@"Updated notification state for characteristic %@ (newState:%@)", characteristic.UUID, [characteristic isNotifying] ? @"Notifying" : @"Not Notifying");
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mobmax.MyWeight" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyWeight" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MyWeight.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)setSelectedUnits:(MaxUnits)selectedUnits {
    _selectedUnits = selectedUnits;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:_selectedUnits forKey:@"SelectedUnits"];
    [defaults synchronize];
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)retreiveProfile {
    if (self.currentProfile == nil) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        self.selectedUnits = [defaults integerForKey:@"SelectedUnits"];
        NSString* profileString = [defaults objectForKey:@"SelectedProfile"];
        
       if (profileString) {
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            // Set example predicate and sort orderings...
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"userName == %@", profileString];
            [request setPredicate:predicate];
            
            NSError *error;
            NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
            if (array) {
                self.currentProfile = [array firstObject];
            }
        }
    }
}

- (void)saveProfile {
    
    if (self.currentProfile) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.currentProfile.userName forKey:@"SelectedProfile"];
        [defaults synchronize];
    }
}

@end
