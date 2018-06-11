//
//  DeviceConfigViewController.m
//  iBreezeeConfig
//
//  Created by Tang Retouch on 2018/3/22.
//  Copyright © 2018年 Tang Retouch. All rights reserved.
//

#import "DeviceConfigViewController.h"
#import "RootTableViewCell.h"
#import "RTHBluetooth.h"
#import "CBPeripheral+ConfigStatus.h"

static  NSString *const BLE_SERVICE_UUID =               @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
static  NSString *const BlE_CHARACTERISTIC_WRITE_UUID =  @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
static  NSString *const BLE_CHARACTERISTIC_NOTIFY_UUID = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString *const reuseIdentifer = @"cell";

@interface DeviceConfigViewController ()<UITableViewDelegate,UITableViewDataSource,RTHBluetoothDelegate>{
    RTHBluetooth *_bleManager;
    NSString *_ssid;
    NSString *_psd;
}

@property (strong, nonatomic) UITableView       *tableView;
@property (strong, nonatomic) UIView            *editingView;
@property (nonatomic, strong) NSData *configurationCommand;

@end



@implementation DeviceConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@----%@",_ssid,_psd);
    
    [self initUI];
    
    [self customMJRefresh];
    
    _bleManager = [RTHBluetooth shareInstance];
    _bleManager.delegate = self;
}

- (void)customMJRefresh{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadDataFromNetwork)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    header.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.tableView.mj_header = header;
    
    [header beginRefreshing];
}

- (void)loadDataFromNetwork{
    [_bleManager reScanPeripherals];
    [self.tableView.mj_header endRefreshing];
}

- (void)initUI{
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.editingView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.editingView.mas_top);
    }];
    
    [self.editingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.view).offset(50);
    }];
}

- (IBAction)rightBarItemClick:(UIBarButtonItem *)item{
    if ([item.title isEqualToString:@"编辑"]) {
        if (_bleManager.discoverPeripherals.count == 0) {
            return;
        }
        item.title = @"取消";
        [self.tableView setEditing:YES animated:YES];
        [self showEitingView:YES];
    }else{
        item.title = @"编辑";
        [self.tableView setEditing:NO animated:YES];
        
        [self showEitingView:NO];
    }
    
}



#pragma mark -- event response
- (void)p__buttonClick:(UIButton *)sender{
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"删除"]) {
        NSMutableIndexSet *insets = [[NSMutableIndexSet alloc] init];
        [[self.tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [insets addIndex:obj.row];
        }];
        [_bleManager.discoverPeripherals removeObjectsAtIndexes:insets];
        [self.tableView deleteRowsAtIndexPaths:[self.tableView indexPathsForSelectedRows] withRowAnimation:UITableViewRowAnimationFade];
        
        /** 数据清空情况下取消编辑状态*/
        if (_bleManager.discoverPeripherals.count == 0) {
            self.navigationItem.rightBarButtonItem.title = @"编辑";
            [self.tableView setEditing:NO animated:YES];
            [self showEitingView:NO];
            /** 带MJ刷新控件重置状态
             [self.tableView.footer resetNoMoreData];
             [self.tableView reloadData];
             */
        }
        
    }else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"全选"]) {
        [_bleManager.discoverPeripherals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
        
        [sender setTitle:@"全不选" forState:UIControlStateNormal];
    }else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"全不选"]){
        [self.tableView reloadData];
        [sender setTitle:@"全选" forState:UIControlStateNormal];
        
    }
}

- (void)showEitingView:(BOOL)isShow{
    [self.editingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(isShow?0:50);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}




#pragma mark  -  BlueTooth CentreManager Delegate
- (BOOL)filterOnDiscoverPeripherals:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([advertisementData[@"kCBAdvDataLocalName"] hasPrefix:@"iBreezee"]) {
        return YES;
    }
    return NO;
}

- (BOOL)filterOnconnectToPeripherals:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    return NO;
}

- (NSString *)deviceServiceUUID{
    return BLE_SERVICE_UUID;
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    [self.tableView reloadData];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    [service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.UUID.UUIDString isEqualToString:BlE_CHARACTERISTIC_WRITE_UUID]) {
            [peripheral rt_writeValue:self.configurationCommand forCharacteristic:obj];
            NSLog(@"数据已发送--%@",self.configurationCommand);
        }else if([obj.UUID.UUIDString isEqualToString:BLE_CHARACTERISTIC_NOTIFY_UUID]){
            [peripheral setNotifyValue:YES forCharacteristic:obj];
        }
    }];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    Byte *bytes = (Byte *)[characteristic.value bytes];
    peripheral.configStatus = bytes[4];
    if (bytes[4] == 0x04) {
        peripheral.configMode = NO;
        [_bleManager cancelPeripheralConnection:peripheral];
    }
    [self.tableView reloadData];
}





#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _bleManager.discoverPeripherals.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer forIndexPath:indexPath];
    cell.multipleSelectionBackgroundView = [UIView new];
    cell.backgroundColor = UIColorHex(0x141414);
    cell.contentView.backgroundColor = UIColorHex(0x141414);
    
    CBPeripheral *peripheral = _bleManager.discoverPeripherals[indexPath.row];
    [cell freshCellWithPeripheral:peripheral];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *peripheral = _bleManager.discoverPeripherals[indexPath.row];
    [_bleManager connectToPeripheral:peripheral];
    peripheral.configMode = YES;
    [self timerForPeripheral:peripheral];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}



# pragma mark -Private Method
-(void)timerForPeripheral:(CBPeripheral *)peripheral {
    //单次定时器
    double delayInSeconds = 60.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //__block RTHBluetooth *weakBleManager = _bleManager;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_bleManager cancelPeripheralConnection:peripheral];
    });
}




# pragma mark  -Getter  Setter-
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource      = self;
        _tableView.delegate        = self;
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.separatorColor = UIColorHex(0x272727);
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RootTableViewCell class]) bundle:nil] forCellReuseIdentifier:reuseIdentifer];
    }
    return _tableView;
}

- (UIView *)editingView{
    if (!_editingView) {
        _editingView = [[UIView alloc] init];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = UIColorHex(0xF19837);
        [button setTitle:@"批量" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p__buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editingView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(_editingView);
            make.width.equalTo(_editingView).multipliedBy(0.5);
        }];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor darkGrayColor];
        [button setTitle:@"全选" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p__buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editingView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(_editingView);
            make.width.equalTo(_editingView).multipliedBy(0.5);
        }];
    }
    return _editingView;
}



- (NSData *)configurationCommand{
    NSMutableData *totalDataM = [NSMutableData data];
    NSData *ssidData = [_ssid dataUsingEncoding:NSUTF8StringEncoding];
    NSData *pwdData = [_psd dataUsingEncoding:NSUTF8StringEncoding];
    
    Byte firstPositionByte[] = {0x24, 0x02};//睡眠带 WiFi版
    [totalDataM appendData:[NSData dataWithBytes:firstPositionByte length:sizeof(firstPositionByte)]];
    
    
    unsigned int totalSize = (int)ssidData.length + (int)pwdData.length + 4;
    NSData *totalSizeData = [NSData dataWithBytes:&totalSize length:1];
    [totalDataM appendData:totalSizeData];
    
    
    Byte commendID[] = {0x31};//操作指令
    [totalDataM appendData:[NSData dataWithBytes:commendID length:1]];
    
    
    unsigned int ssidSize = (int)ssidData.length;
    NSData *ssidSizeData = [NSData dataWithBytes:&ssidSize length:1];
    [totalDataM appendData:ssidSizeData];
    
    unsigned int pwdSize = (int)pwdData.length;
    NSData *pwdSizeData = [NSData dataWithBytes:&pwdSize length:1];
    [totalDataM appendData:pwdSizeData];
    
    [totalDataM appendData:ssidData];
    [totalDataM appendData:pwdData];
    
    Byte endPositionByte[] = {0xff, 0x69, 0x42};
    [totalDataM appendData:[NSData dataWithBytes:endPositionByte length:sizeof(endPositionByte)]];
    
    _configurationCommand = (NSData *)totalDataM;
        
    return _configurationCommand;
}


@end
