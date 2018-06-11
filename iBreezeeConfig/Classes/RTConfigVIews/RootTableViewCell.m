//
//  RootTableViewCell.m
//  iBreezeeConfig
//
//  Created by Tang Retouch on 2018/3/21.
//  Copyright © 2018年 Tang Retouch. All rights reserved.
//

#import "RootTableViewCell.h"

@interface RootTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *wifiName;
@property (weak, nonatomic) IBOutlet UILabel *wifiState;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;


@end


@implementation RootTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)freshCellWithPeripheral:(CBPeripheral *)peripheral{
    self.wifiName.text = peripheral.name;
    
    if (peripheral.isConfigMode) {
        [self.activityIndicatorView startAnimating];
    }else{
        [self.activityIndicatorView stopAnimating];
    }
    
    switch (peripheral.configStatus) {
        case 0x01:{
            self.wifiState.text = @"连接路由中...";
        }
            break;
        case 0x02:{
            self.wifiState.text = @"连接服务器...";
        }
            break;
        case 0x03:{
            self.wifiState.text = @"连接服务器...";
        }
            break;
        case 0x04:{
            self.wifiState.text = @"配置成功，设备可以正常使用！";
        }
            break;
        default:{
            self.wifiState.text = @"";
        }
            break;
    }
}






@end
