//
//  MaxProfileTableViewController.m
//  MyWeight
//
//  Created by Maxim Donchenko on 27/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "MaxProfileTableViewController.h"
#import "AppDelegate.h"
#import "MaxProfileDetailController.h"
#import "MaxDashboardViewController.h"
#import "Profile.h"

@interface MaxProfileTableViewController () {
    BOOL _ignoreChanges;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController;

@end

@implementation MaxProfileTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    _ignoreChanges = NO;
    [self fetch];   // start fetching profiles from our data store
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!_ignoreChanges) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate saveContext];
    }
    _ignoreChanges = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"profileCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Profile *profile = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = profile.userName;
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Profile* profile = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (profile == appDelegate.currentProfile) return NO;

    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Profile* profile = [self.fetchedResultsController objectAtIndexPath:indexPath];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.managedObjectContext deleteObject:profile];

//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    Profile* profile = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.currentProfile = profile;
    [appDelegate saveProfile];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    MaxProfileDetailController *detailVC = [segue destinationViewController];
    if ([sender isKindOfClass:[Profile class]]) {
        detailVC.profile = sender;
        _ignoreChanges = YES;
    } else {
        detailVC.profile = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
    }
}

#pragma mark - Internal

- (IBAction)addNewProfile:(id)sender {
    [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:self.fetchedResultsController.managedObjectContext];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController == nil) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Profile" inManagedObjectContext:appDelegate.managedObjectContext]];
        NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"userName" ascending:YES]];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)fetch {
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    NSAssert2(success, @"Unhandled error performing fetch at MaxProfileTableViewController.m, line %d: %@", __LINE__, [error localizedDescription]);
    [self.tableView reloadData];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
        {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            Profile *profile = [controller objectAtIndexPath:newIndexPath];
            [self performSegueWithIdentifier:@"showProfile" sender:profile];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            Profile *profile = [controller objectAtIndexPath:indexPath];
            cell.textLabel.text = profile.userName;
            break;
        }
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
