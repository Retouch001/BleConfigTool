//
//  RootTableViewCell.h
//  iBreezeeConfig
//
//  Created by Tang Retouch on 2018/3/21.
//  Copyright © 2018年 Tang Retouch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+ConfigStatus.h"


typedef NS_ENUM(NSInteger,RTDeviceConfigStatus){
    RTDeviceConfigStatusConnectingNone,
    RTDeviceConfigStatusConnectingRouter,
    RTDeviceConfigStatusConnectingServer,
    RTDeviceConfigStatusSuccess
};


@interface RootTableViewCell : UITableViewCell

- (void)freshCellWithPeripheral:(CBPeripheral *)peripheral;


@end
