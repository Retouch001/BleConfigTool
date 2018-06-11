//
//  SSIDPSWViewController.m
//  iBreezeeConfig
//
//  Created by Tang Retouch on 2018/3/22.
//  Copyright © 2018年 Tang Retouch. All rights reserved.
//

#import "SSIDPSWViewController.h"
#import "BaseTextField.h"

@interface SSIDPSWViewController ()
@property (weak, nonatomic) IBOutlet BaseTextField *ssidTextField;
@property (weak, nonatomic) IBOutlet BaseTextField *psdTextField;
@end

@implementation SSIDPSWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *de = [NSUserDefaults standardUserDefaults];
    self.ssidTextField.text = [de objectForKey:@"key_ssid"];
    self.psdTextField.text = [de objectForKey:@"key_psd"];
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (self.ssidTextField.text.length > 0 && self.psdTextField.text.length > 0) {
        return YES;
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入完整的wifi信息"];
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id vc = segue.destinationViewController;
    [vc setValue:self.ssidTextField.text forKey:@"_ssid"];
    [vc setValue:self.psdTextField.text forKey:@"_psd"];
    
    NSUserDefaults *de = [NSUserDefaults standardUserDefaults];
    
    [de setObject:self.ssidTextField.text forKey:@"key_ssid"];
    [de setObject:self.psdTextField.text forKey:@"key_psd"];
}


@end
