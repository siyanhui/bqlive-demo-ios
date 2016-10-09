//
//  UIColor+BQMM.m
//  StampMeSDK
//
//  Created by ceo on 8/27/15.
//  Copyright (c) 2015 siyanhui. All rights reserved.
//

#import "UIColor+BQLive.h"

@implementation UIColor (BQLive)

+ (UIColor *)bml_colorWithHexColorString:(NSString *)hexString {
    NSString *colorStr = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    const NSInteger kNumberLength = 6;
    BOOL hasAlpha = YES;
    if (colorStr.length < kNumberLength) {
        return nil;
    }
    
    if ([colorStr hasPrefix:@"0X"]) {
        colorStr = [colorStr substringFromIndex:2];
    }
    
    if ([colorStr hasPrefix:@"#"]) {
        colorStr = [colorStr substringFromIndex:1];
    }

    if (colorStr.length == kNumberLength) {
        hasAlpha = NO;
    }else if (colorStr.length == kNumberLength + 2) {
        hasAlpha = YES;
    }else {
        return nil;
    }
    CGFloat alpha = 1;
    unsigned int r, g, b, a;
    int start = 0;
    if (hasAlpha) {
        NSString *alphaString = [colorStr substringWithRange:NSMakeRange(0, 2)];
        [[NSScanner scannerWithString:alphaString] scanHexInt:&a];
        alpha = a / 255.0;
        start += 2;
    }
    
    NSString *rString = [colorStr substringWithRange:NSMakeRange(start, 2)];
    NSString *gString = [colorStr substringWithRange:NSMakeRange(start + 2, 2)];
    NSString *bString = [colorStr substringWithRange:NSMakeRange(start + 4, 2)];

    
    if (rString.length == 0 || bString.length == 0 || gString.length == 0) {
        return nil;
    }
    


    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:alpha];
    
}

@end
