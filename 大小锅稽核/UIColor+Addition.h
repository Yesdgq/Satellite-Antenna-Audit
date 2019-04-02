//
//  UIColor+Addition.h
//  SevenColorMovies
//
//  Created by yesdgq on 16/7/18.
//  Copyright © 2016年 yesdgq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Addition)
/*
 * 固定透明度的Hex方法
 */
+ (UIColor *)colorWithHex:(NSString *)hex;

/*
 * 可变透明度的Hex方法
 */
+ (UIColor *)colorWithHex:(NSString *)hex alpha:(float)alpha;

@end
