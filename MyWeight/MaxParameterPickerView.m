//
//  MaxParameterPickerView.m
//  MyWeight
//
//  Created by Maxim Donchenko on 08/08/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "MaxParameterPickerView.h"

@interface MaxParameterPickerView ()

@property (assign) Float32 minValue;
@property (assign) Float32 maxValue;
@property (strong, nonatomic) NSArray* units;

@end


@implementation MaxParameterPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
