//
//  MaxParameterPickerView.m
//  MyWeight
//
//  Created by Maxim Donchenko on 08/08/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "MaxParameterPickerView.h"

#define kSelfHeight 260
#define kSelfWidth 320


#define kSHOW_OFFSCREEN CGRectMake(0, ([UIScreen mainScreen].bounds.size.height+1), kSelfWidth, kSelfHeight);
#define kSHOW_ONSCREEN CGRectMake(0, (self.parentView.bounds.size.height-kSelfHeight), kSelfWidth, kSelfHeight);


@interface MaxParameterPickerView ()

@property (assign) Float32 minValue;
@property (assign) Float32 maxValue;
@property (strong, nonatomic) NSArray* units;

@property (nonatomic) UIView *parentView;

@end


@implementation MaxParameterPickerView


- (id)initWithinView:(UIView *)view {
    if (self = [super init]) {
        
        self.parentView = [[UIView alloc] init];
        self.parentView = view;
        self.backgroundColor = [UIColor whiteColor];
        
        self.frame = kSHOW_OFFSCREEN;
        
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kSelfWidth, 44)];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) { // for iOS 7 and above
            [self.toolbar setTintColor:[UIColor whiteColor]];
            [self.toolbar setBarTintColor:[UIColor blackColor]];
        } else {
            [self.toolbar setBarStyle:UIBarStyleBlack];
        }
        
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, kSelfWidth, 216)];
        self.pickerView.showsSelectionIndicator = YES;
        
        [self addSubview:self.toolbar];
        [self addSubview:self.pickerView];
    }
    
    return self;
}


- (instancetype)initWithTitle:(NSString *)title min:(Float32)min max:(Float32)max uints:(NSArray *)units forView:(UIView *)view {
    self = [self initWithinView:view];
    if (self) {
        self.maxValue = max;
        self.minValue = min;
        self.units = units;
        
        [self.pickerView setDataSource:self];
        [self.pickerView setDelegate:self];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain  target:self action:@selector(cancelButtonAction:)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UILabel *viewTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
        viewTitle.textColor = [UIColor whiteColor];
        viewTitle.textAlignment = NSTextAlignmentCenter;
        viewTitle.font = [UIFont boldSystemFontOfSize:20];
        viewTitle.text = title;
        UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:viewTitle];
        
        [self setToolbarItems:@[cancelButton,spacer,titleButton,spacer,doneButton]];
        
        [view addSubview:self];
    }
    return self;
}

#pragma mark - Show/hide view

- (void)showPickerContainerView {
    
    [UIView animateWithDuration:0.333 animations:^ {
        self.frame = kSHOW_ONSCREEN
    }];
    
}


- (void)hidePickerContainerView {
    
    [UIView animateWithDuration:0.333 animations:^ {
        self.frame = kSHOW_OFFSCREEN;
    }];
    
}

#pragma mark -

- (void)setToolbarItems:(NSArray *)toolbarItems {
    self.toolbar.items = nil;
    self.toolbar.items = toolbarItems;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.minValue == self.maxValue) {
        return 1;
    }
    NSInteger number = self.units == nil ? 0 : 1;
    number += [[NSString stringWithFormat:@"%.0f", self.maxValue] length];
    return number;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.minValue == self.maxValue) {
        return [self.units count];
    }
    NSString* maxString = [NSString stringWithFormat:@"%.0f", self.maxValue];
    if (component >= [maxString length]) {
        return [self.units count];
    }
    if (component > 0) {
        return 10;
    }
    NSString* fromatString = [NSString stringWithFormat:@"%%0%ld.0f", [maxString length]];
    NSString* minString = [NSString stringWithFormat:fromatString, self.minValue];
    return [[maxString substringWithRange:NSMakeRange(component, 1)] integerValue] - [[minString substringWithRange:NSMakeRange(component, 1)] integerValue] + 1;
}

#pragma mark - UIPickreViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    if (self.minValue == self.maxValue) {
        return [self.units objectAtIndex:row];
    }
    NSString* maxString = [NSString stringWithFormat:@"%.0f", self.maxValue];
    if (component >= [maxString length]) {
        return [self.units objectAtIndex:row];
    }
    return [NSString stringWithFormat:@"%ld", row];
}

#pragma mark - Actions

- (IBAction)doneButtonAction:(id)sender {
    if (self.pickerDelegate) {
        [self.pickerDelegate onDone:self];
    }
}

- (IBAction)cancelButtonAction:(id)sender {
    if (self.pickerDelegate) {
        [self.pickerDelegate onCancel:self];
    }
}

#pragma mark - Public methods

- (void)selectFromInterger:(NSInteger)value animated:(BOOL)animated {
    int numComponents =  (int)(self.units ? self.pickerView.numberOfComponents - 1 : self.pickerView.numberOfComponents);
    int devider = 10;
    for (int i = numComponents - 1; i >= 0; i--) {
        NSInteger row = value % 10;
        value = value / devider;
        [self.pickerView selectRow:row inComponent:i animated:animated];
    }
}

- (NSInteger)getIntegerValue {
    NSInteger value = 0;
    int numComponents =  (int)(self.units ? self.pickerView.numberOfComponents - 1 : self.pickerView.numberOfComponents);
    
    for(int i = 0; i < numComponents; i++) {
        value = value * 10 + [self.pickerView selectedRowInComponent:i];
    }
    return value;
}


@end
