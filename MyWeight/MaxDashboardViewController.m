//
//  MaxDashboardViewController.m
//  MyWeight
//
//  Created by Maxim Donchenko on 28/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "MaxDashboardViewController.h"
#import "MaxProfileDetailController.h"
#import "AppDelegate.h"
#import "Measurment.h"

#import "NSDate+TKCategory.h"

#import "JBLineChartView.h"
#import "JBChartInformationView.h"
#import "JBChartTooltipView.h"
#import "JBChartTooltipTipView.h"

typedef NS_ENUM(NSInteger, JBLineChartLine){
    JBLineChartLineDashed,
    JBLineChartLineSolid,
    JBLineChartLineCount
};


typedef NS_ENUM(NSInteger, MaxChartFilters) {
    MaxChartFilterToday,
    MaxChartFilterWeek,
    MaxChartFilterMonth,
    MaxChartFilterAll
};

// Numerics
CGFloat const kJBLineChartViewControllerChartHeight = 250.0f;
CGFloat const kJBLineChartViewControllerChartPadding = 10.0f;
CGFloat const kJBLineChartViewControllerChartHeaderHeight = 75.0f;
CGFloat const kJBLineChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartSolidLineWidth = 6.0f;
CGFloat const kJBLineChartViewControllerChartDashedLineWidth = 2.0f;
NSInteger const kJBLineChartViewControllerMaxNumChartPoints = 7;

CGFloat const kJBBaseChartViewControllerAnimationDuration = 0.25f;


@interface MaxDashboardViewController () <JBLineChartViewDelegate, JBLineChartViewDataSource>

@property (nonatomic, strong) JBChartTooltipView *tooltipView;
@property (nonatomic, strong) JBChartTooltipTipView *tooltipTipView;
@property (nonatomic, assign) BOOL tooltipVisible;

// Settres
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint;
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated;

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) JBChartInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, assign) MaxChartFilters selectedFilter;

// Helpers
- (void)initData;

@property (strong, nonatomic) MeasurmentResult* result;
@property (strong, nonatomic) NSTimer* progressTimer;

@end

@implementation MaxDashboardViewController

#pragma mark - Setters

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint
{
    _tooltipVisible = tooltipVisible;
    
    JBChartView *chartView = [self chartView];
    
    if (!chartView)
    {
        return;
    }
    
    if (!self.tooltipView)
    {
        self.tooltipView = [[JBChartTooltipView alloc] init];
        self.tooltipView.alpha = 0.0;
        [self.chatCell.contentView addSubview:self.tooltipView];
    }
    
    if (!self.tooltipTipView)
    {
        self.tooltipTipView = [[JBChartTooltipTipView alloc] init];
        self.tooltipTipView.alpha = 0.0;
        [self.chatCell.contentView addSubview:self.tooltipTipView];
    }
    
    dispatch_block_t adjustTooltipPosition = ^{
        CGPoint originalTouchPoint = [self.chatCell.contentView convertPoint:touchPoint fromView:chartView];
        CGPoint convertedTouchPoint = originalTouchPoint; // modified
        JBChartView *chartView = [self chartView];
        if (chartView)
        {
            CGFloat minChartX = (chartView.frame.origin.x + ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x < minChartX)
            {
                convertedTouchPoint.x = minChartX;
            }
            CGFloat maxChartX = (chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x > maxChartX)
            {
                convertedTouchPoint.x = maxChartX;
            }
            self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5), CGRectGetMaxY(chartView.headerView.frame) + 40, self.tooltipView.frame.size.width, self.tooltipView.frame.size.height);
            
            CGFloat minTipX = (chartView.frame.origin.x + self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x < minTipX)
            {
                originalTouchPoint.x = minTipX;
            }
            CGFloat maxTipX = (chartView.frame.origin.x + chartView.frame.size.width - self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x > maxTipX)
            {
                originalTouchPoint.x = maxTipX;
            }
            self.tooltipTipView.frame = CGRectMake(originalTouchPoint.x - ceil(self.tooltipTipView.frame.size.width * 0.5), CGRectGetMaxY(self.tooltipView.frame), self.tooltipTipView.frame.size.width, self.tooltipTipView.frame.size.height);
        }
    };
    
    dispatch_block_t adjustTooltipVisibility = ^{
        self.tooltipView.alpha = _tooltipVisible ? 1.0 : 0.0;
        self.tooltipTipView.alpha = _tooltipVisible ? 1.0 : 0.0;
    };
    
    if (tooltipVisible)
    {
        adjustTooltipPosition();
    }
    
    if (animated)
    {
        [UIView animateWithDuration:kJBBaseChartViewControllerAnimationDuration animations:^{
            adjustTooltipVisibility();
        } completion:^(BOOL finished) {
            if (!tooltipVisible)
            {
                adjustTooltipPosition();
            }
        }];
    }
    else
    {
        adjustTooltipVisibility();
    }
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated
{
    [self setTooltipVisible:tooltipVisible animated:animated atTouchPoint:CGPointZero];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible
{
    [self setTooltipVisible:tooltipVisible animated:NO];
}

#pragma mark - Result

- (void)showResult:(BOOL)notFake {
    self.weightLabel.text = !notFake ? @"---.-" : [NSString stringWithFormat:@"%.1f", self.result.weight];
    self.unitLabel.text = @"kg";
    
    self.fatLabel.text = !notFake ? @"0%" : [NSString stringWithFormat:@"%.f%%", self.result.fat];
    self.boneLabel.text = !notFake ? @"0%" : [NSString stringWithFormat:@"%.f%%", self.result.bone];
    self.musculeLabel.text = !notFake ? @"0%" : [NSString stringWithFormat:@"%.f%%", self.result.muscule];
    self.waterLabel.text = !notFake ? @"0%" : [NSString stringWithFormat:@"%.f%%", self.result.water];
    self.viscelarFatLabel.text = !notFake ? @"0" : [NSString stringWithFormat:@"%lu", (long)self.result.visceralFat];
    self.kcalLabel.text = !notFake ? @"0" : [NSString stringWithFormat:@"%lu", (long)self.result.Kcal];
}

#pragma mark - Data

- (void)initData
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Measurment" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate;
    
    switch (self.selectedFilter) {
        case MaxChartFilterToday:
            predicate = [NSPredicate predicateWithFormat:@"profile == %@ AND fromDate >= %@ AND fromDate < %@", appDelegate.currentProfile, [NSDate yesterday], [NSDate tomorrow]];
            break;
            
        case MaxChartFilterWeek: {
            NSDate* from  = [NSDate week];
            NSDate* to = [NSDate nextWeek];
            predicate = [NSPredicate predicateWithFormat:@"profile == %@ AND fromDate >= %@ AND fromDate < %@", appDelegate.currentProfile, from, to];
            break;
        }

        case MaxChartFilterMonth:
            predicate = [NSPredicate predicateWithFormat:@"profile == %@ AND fromDate >= %@ AND fromDate < %@", appDelegate.currentProfile, [NSDate month], [NSDate nextMonth]];
            break;
            
        default:
            predicate = [NSPredicate predicateWithFormat:@"profile == %@", appDelegate.currentProfile];
            break;
    }
    [request setPredicate:predicate];
    
    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"fromDate" ascending:YES]];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];

    _chartData = [NSArray arrayWithArray:array];
}

#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate retreiveProfile];
    
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.frame = CGRectMake(kJBLineChartViewControllerChartPadding, kJBLineChartViewControllerChartPadding + 35, self.chatCell.contentView.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeight);
    self.lineChartView.delegate = self;
    self.lineChartView.dataSource = self;
    self.lineChartView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
    self.lineChartView.backgroundColor = kJBColorLineChartBackground;
    
    self.lineChartView.headerView = nil;
    self.lineChartView.footerView = nil;
    
    self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, CGRectGetMaxY(self.lineChartView.frame) - 52, self.chatCell.contentView.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), CGRectGetMaxY(self.lineChartView.frame) - 195)];
    [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:0.1 alpha:0.75]];
    [self.informationView setTitleTextColor:kJBColorLineChartHeader];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:kJBColorLineChartHeaderSeparatorColor];
    
    [self.chatCell.contentView addSubview:self.informationView];
    [self.chatCell.contentView addSubview:self.lineChartView];
    
    self.selectedFilter = [[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedFilter"];
    [self.chartFilterSelector setSelectedSegmentIndex:self.selectedFilter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.currentProfile) {
        self.title = appDelegate.currentProfile.userName;
        [self initData];
        [self.lineChartView reloadData];
        self.result = nil;
        [self showResult:NO];
        self.saveButton.enabled = NO;
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MaxProfileDetailController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"profileDetailPage"];
        Profile* profile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:appDelegate.managedObjectContext];
        detailVC.profile = profile;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    appDelegate.uiDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.uiDelegate = nil;
}

- (void)timerFireMethod:(NSTimer *)timer {
    self.scaleImg.hidden = !self.scaleImg.hidden;
}

#pragma mark - BTDeviceProtocol

- (void)didDiscoveredDevice:(CBPeripheral *)peripheral {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.saveButton.enabled = NO;
    self.result = nil;
    [self showResult:NO];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [appDelegate doMeasurment:peripheral];
}

- (void)measurmentResut:(MeasurmentResult *)result {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    self.scaleImg.hidden = NO;
    
    if (result.isValid) {
        self.saveButton.enabled = YES;
        self.result = result;
        [self showResult:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Measument Error" message:self.result.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didDiconnect {
    if (self.progressTimer) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        self.result = nil;
    }
    self.scaleImg.hidden = NO;
}

#pragma mark - Actions

- (IBAction)saveMeasurment:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.currentProfile && self.result) {
        Measurment* measurment = [NSEntityDescription insertNewObjectForEntityForName:@"Measurment"
                                                               inManagedObjectContext:appDelegate.managedObjectContext];
        measurment.fromDate = [NSDate date];
        measurment.weight = [NSNumber numberWithFloat:self.result.weight];
        measurment.fat = [NSNumber numberWithFloat:self.result.fat];
        measurment.bone = [NSNumber numberWithFloat:self.result.bone];
        measurment.muscule = [NSNumber numberWithFloat:self.result.muscule];
        measurment.water = [NSNumber numberWithFloat:self.result.water];
        measurment.visceralFat = [NSNumber numberWithInteger:self.result.visceralFat];
        measurment.kcal = [NSNumber numberWithInteger:self.result.Kcal];
        measurment.profile = appDelegate.currentProfile;
        [appDelegate.currentProfile addMeasurmentsObject:measurment];
        [appDelegate saveContext];

        [self initData];
        [self.lineChartView reloadData];

        self.saveButton.enabled = NO;
    }
}

- (IBAction)filterChanged:(id)sender {
    BOOL changed = NO;
    switch (self.chartFilterSelector.selectedSegmentIndex) {
        case 0:
            self.selectedFilter = MaxChartFilterToday;
            changed = YES;
            break;
            
        case 1:
            self.selectedFilter = MaxChartFilterWeek;
            changed = YES;
            break;
            
        case 2:
            self.selectedFilter = MaxChartFilterMonth;
            changed = YES;
            break;

        case 3:
            self.selectedFilter = MaxChartFilterAll;
            changed = YES;
            break;

        default:
            break;
    }
    if (changed) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.chartFilterSelector.selectedSegmentIndex
                                                   forKey:@"SelectedFilter"];
        [self initData];
        [self.lineChartView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    Measurment* item = [self.chartData objectAtIndex:horizontalIndex];
    return [item.weight floatValue];
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    Measurment* item = [self.chartData objectAtIndex:horizontalIndex];
    NSNumber *valueNumber = item.weight;
    [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:@"kg"];
    [self.informationView setHidden:NO animated:YES];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    [self.tooltipView setText:[dateFormatter stringFromDate:item.fromDate]];

}

- (void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    NSUInteger number = 0;
    if (self.chatCell)
        number = [self.chartData count];
    return number;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidLineColor: kJBColorLineChartDefaultDashedLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidLineColor: kJBColorLineChartDefaultDashedLineColor;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBLineChartViewControllerChartSolidLineWidth: kJBLineChartViewControllerChartDashedLineWidth;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? 0.0: (kJBLineChartViewControllerChartDashedLineWidth * 4);
}

- (UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidSelectedLineColor: kJBColorLineChartDefaultDashedSelectedLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidSelectedLineColor: kJBColorLineChartDefaultDashedSelectedLineColor;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex != JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex != JBLineChartViewLineStyleSolid;
}

#pragma mark - Overrides

- (JBChartView *)chartView
{
    return self.lineChartView;
}


@end
