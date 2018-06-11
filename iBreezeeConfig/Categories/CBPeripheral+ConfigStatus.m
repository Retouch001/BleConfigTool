//
//  CBPeripheral+ConfigStatus.m
//  iBreezeeConfig
//
//  Created by Tang Retouch on 2018/3/23.
//  Copyright © 2018年 Tang Retouch. All rights reserved.
//

#import "CBPeripheral+ConfigStatus.h"
#import <objc/runtime.h>

static void *strKey = @"key";

static void *strKey1 = @"key1";


@implementation CBPeripheral (ConfigStatus)

- (void)setConfigStatus:(NSInteger)configStatus{
    objc_setAssociatedObject(self, &strKey, @(configStatus), OBJC_ASSOCIATION_ASSIGN);
}


- (NSInteger)configStatus{
    NSNumber *number = objc_getAssociatedObject(self, &strKey);
    return [number integerValue];
}






- (void)setConfigMode:(BOOL)configMode{
    objc_setAssociatedObject(self, &strKey1, @(configMode), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isConfigMode{
    NSNumber *number = objc_getAssociatedObject(self, &strKey1);;
    return  [number boolValue];
}


@end
