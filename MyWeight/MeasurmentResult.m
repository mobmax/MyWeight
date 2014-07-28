//
//  MeasurmentResult.m
//  MyWeight
//
//  Created by Maxim Donchenko on 28/07/14.
//  Copyright (c) 2014 Maxim Donchenko. All rights reserved.
//

#import "MeasurmentResult.h"

@implementation MeasurmentResult

+ (MeasurmentResult *)resultWithData:(NSData *)data {
    if (data) {
        MeasurmentResult *result = [[MeasurmentResult alloc] init];
        unsigned char *bytes = (unsigned char *)data.bytes;
        
        if (bytes[0] == 0xFD) {
            //Error handling
            result.isValid = NO;
            switch (bytes[1]) {
                case 0x31:
                    result.errorDescription = NSLocalizedString(@"Bluetooth Connection Error", @"Bluetooth Connection Error");
                    break;
                case 0x33:
                    result.errorDescription = NSLocalizedString(@"Body Fat Measuring Error", @"Body Fat Measuring Error");
                    break;
                    
                default:
                    result.errorDescription = NSLocalizedString(@"Unknow error", @"Unknow error");
                    break;
            }
        } else if (bytes[0] == 0xCF | bytes[0] == 0xCE |bytes[0] == 0xCB | bytes[0] == 0xCA) {
            result.isValid = YES;
            result.weight = (bytes[5] + bytes[4] * 256) * 0.1;
            result.level = bytes[1] >> 4;
            result.group = bytes[1] & 0xF;
            result.gender = bytes[2] >> 7;
            result.age = bytes[2] & 0x7F;
            result.height = bytes[3];
            result.fat = (bytes[7] + bytes[6] * 256) * 0.1;
            result.bone = bytes[8] * 0.1 / result.weight * 100;
            result.muscule = (bytes[10] + bytes[9] * 256) * 0.1;
            result.visceralFat = bytes[11];
            result.water = (bytes[13] + bytes[12] * 256) * 0.1;
            result.Kcal = bytes[15] + bytes[14] * 256;
        }
        return result;
    }
    return nil;
}

- (NSString *)description {
    if (self.isValid)
        return [NSString stringWithFormat:@"Level: %ld, Group: %ld, Gender: %@, Age: %ld, Height: %ld, Weight: %.2f, Fat %.2f%%, Bone: %.2f%%, Muscule %.2f%%, Visceral Fat %ld, Water: %.2f%%, Kcal: %ld", (long)self.level, (long)self.group, (self.gender ? @"Male" : @"Female"), (long)self.age, (long)self.height, self.weight, self.fat, self.bone, self.muscule, (long)self.visceralFat, self.water, (long)self.Kcal];
    else
        return [NSString stringWithFormat:@"Error: %@", self.errorDescription];
}


@end
