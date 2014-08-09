//
//  MaxParameterPickerView.h
//  MyWeight
//
//  Created by Maxim Donchenko on 08/08/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "PKHPickerContainerView.h"

@class MaxParameterPickerView;

@protocol MaxParameterPickerViewDelegate <NSObject>

- (void)onDone:(MaxParameterPickerView *)pickerView;
- (void)onCancel:(MaxParameterPickerView *)pickerView;

@end

@interface MaxParameterPickerView : PKHPickerContainerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) id<MaxParameterPickerViewDelegate> pickerDelegate;

- (instancetype)initWithTitle:(NSString *)title min:(Float32)min max:(Float32)max uints:(NSArray *)units forView:(UIView *)view;

- (NSInteger)getIntegerValue;
- (void)selectFromInterger:(NSInteger)value animated:(BOOL)animated;

@end
