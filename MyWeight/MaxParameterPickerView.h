//
//  MaxParameterPickerView.h
//  MyWeight
//
//  Created by Maxim Donchenko on 08/08/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MaxParameterPickerView;

@protocol MaxParameterPickerViewDelegate <NSObject>

- (void)onDone:(MaxParameterPickerView *)pickerView;
- (void)onCancel:(MaxParameterPickerView *)pickerView;

@end

@interface MaxParameterPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) id<MaxParameterPickerViewDelegate> pickerDelegate;

@property (nonatomic) UIToolbar *toolbar;
@property (nonatomic) UIPickerView *pickerView;

@property (nonatomic) UIBarButtonItem *doneButton;
@property (nonatomic) UIBarButtonItem *cancelButton;


- (instancetype)initWithinView:(UIView *)view;
- (instancetype)initWithTitle:(NSString *)title min:(Float32)min max:(Float32)max uints:(NSArray *)units forView:(UIView *)view;

- (void)showPickerContainerView;
- (void)hidePickerContainerView;

- (void)setToolbarItems:(NSArray *)toolbarItems;

- (NSInteger)getIntegerValue;
- (void)selectFromInterger:(NSInteger)value animated:(BOOL)animated;

@end
