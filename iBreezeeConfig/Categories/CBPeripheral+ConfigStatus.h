//
//  CBPeripheral+ConfigStatus.h
//  iBreezeeConfig
//
//  Created by Tang Retouch on 2018/3/23.
//  Copyright © 2018年 Tang Retouch. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (ConfigStatus)

@property (nonatomic, assign) NSInteger configStatus;

@property (nonatomic, assign, getter=isConfigMode) BOOL configMode;


@end
