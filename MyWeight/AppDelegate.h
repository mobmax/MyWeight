//
//  AppDelegate.h
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Profile.h"
#import "MeasurmentResult.h"

@protocol BTDeviceProtocol <NSObject>

- (void)didDiscoveredDevice:(CBPeripheral *)peripheral;

@optional

- (void)measurmentResut:(MeasurmentResult *)result;
- (void)didDiconnect;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) CBCentralManager *manager;
@property (strong, nonatomic) CBCharacteristic * weightMeasurementChar;
@property (strong, nonatomic) CBCharacteristic * measurmentControlChar;

@property (assign, nonatomic) MaxUnits selectedUnits;

@property (strong, nonatomic) Profile* currentProfile;
@property (assign, nonatomic) id<BTDeviceProtocol>uiDelegate;

- (void)saveContext;
- (void)retreiveProfile;
- (void)saveProfile;
- (NSURL *)applicationDocumentsDirectory;

- (void)startScan;
- (void)stopScan;
- (BOOL)isLECapableHardware;
- (NSArray *)retrieveConnectedPrephirals;
- (void)doMeasurment:(CBPeripheral *)peripheral;

@end

