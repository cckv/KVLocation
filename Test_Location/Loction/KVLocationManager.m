//
//  KVLocationManager.m
//
//  https://github.com/cckv/KVLocation.git
//
//  Created by CCKV on 16-4-19.
//  Copyright (c) 2016年 CCKV. All rights reserved.
//

#import "KVLocationManager.h"

const double a = 6378245.0;
const double ee = 0.00669342162296594323;

#define IOS_Version [[UIDevice currentDevice].systemVersion floatValue]

@implementation KVLocation

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

@end

@interface KVLocationManager ()<CLLocationManagerDelegate>

// 保存block
@property (nonatomic, strong)locationBlock locationBlock;
@property (nonatomic, strong)addressBlock addressBlock;
@property (nonatomic, strong)detailAddressBlock detailAddressBlock;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation KVLocationManager

#pragma mark - Instance
static KVLocationManager *tool = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[KVLocationManager alloc] init];
    });
    return tool;
}

/**
 *  懒加载
 */
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        // 定位精准度
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 重新定位的距离
        _locationManager.distanceFilter = 1.0f;
    }
    return _locationManager;
}

/**
 *  开始加载
 */
- (void)startLocation
{
    // 判断定位操作是否被允许
    if (![CLLocationManager locationServicesEnabled]) {
        return;
    }
    // ios8后需要向用户请求权限
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    // 开始定位
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManager获取经纬度的代理方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation *newLocation = [locations firstObject];
    //判断是不是属于国内范围
    if (![KVLocationManager isLocationOutOfChina:[newLocation coordinate]]) {
        //转换后的coord
        CLLocationCoordinate2D coord = [KVLocationManager transformFromWGSToGCJ:[newLocation coordinate]];
        newLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    }

    CLLocationCoordinate2D coor = newLocation.coordinate;
//    NSString *x1 = [NSString stringWithFormat:@"%f", coor.longitude];
//    NSString *y1 = [NSString stringWithFormat:@"%f", coor.latitude];
    
    [self getAddressWithCoordinate:coor];

}

- (void)getLocationCoordinate:(locationBlock)locaiontBlock
{
    self.locationBlock = locaiontBlock;
    [self startLocation];
}

- (void)getLocationCoordinate:(locationBlock)locaiontBlock address:(addressBlock)addressBlock
{
    self.locationBlock = locaiontBlock;
    self.addressBlock = addressBlock;
    [self startLocation];
}

- (void)getLocationCoordinate:(locationBlock)locaiontBlock detailAddress:(detailAddressBlock)detailAddressBlock
{
    self.locationBlock = locaiontBlock;
    self.detailAddressBlock = detailAddressBlock;
    [self startLocation];
}

#pragma mark - 经纬度转地址
- (void)getAddressWithCoordinate:(CLLocationCoordinate2D)coor
{
    if (coor.latitude == 0 || coor.longitude == 0){
        NSLog(@"经纬度为空");
        return;
    }
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:coor.latitude longitude:coor.longitude];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (placemarks.count > 0)
         {
             CLPlacemark *placemark = placemarks.firstObject;
             
             NSDictionary *addressDict = placemark.addressDictionary;
             
             if (self.detailAddressBlock) {
                 KVLocation *location = [[KVLocation alloc] init];
                 location.province = [addressDict objectForKey:@"State"];
                 location.city = [addressDict objectForKey:@"City"];
                 location.district = [addressDict objectForKey:@"SubLocality"];
                 location.street = [addressDict objectForKey:@"Street"];
                 NSArray *addressArray = [addressDict objectForKey:@"FormattedAddressLines"];
                 location.formatted_address = addressArray.firstObject;
                 self.detailAddressBlock(location);
             }
             if (self.addressBlock) {
                 NSArray *addressArray = [addressDict objectForKey:@"FormattedAddressLines"];
                 self.addressBlock(addressArray.firstObject);
             }
             if (self.locationBlock) {
                 self.locationBlock(coor);
             }
         }
         
     }];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - WGS84ConvertToGCJ02
+(CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc
{
    CLLocationCoordinate2D adjustLoc;
    if([self isLocationOutOfChina:wgsLoc]){
        adjustLoc = wgsLoc;
    }else{
        double adjustLat = [self transformLatWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        double adjustLon = [self transformLonWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        double radLat = wgsLoc.latitude / 180.0 * M_PI;
        double magic = sin(radLat);
        magic = 1 - ee * magic * magic;
        double sqrtMagic = sqrt(magic);
        adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
        adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
        adjustLoc.latitude = wgsLoc.latitude + adjustLat - 0.00039900; // 减去这个数字 完全是凑数，准确性有待验证
        adjustLoc.longitude = wgsLoc.longitude + adjustLon;
    }
    return adjustLoc;
}

//判断是不是在中国
+(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location
{
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

+(double)transformLatWithX:(double)x withY:(double)y
{
    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    lat += (20.0 * sin(6.0 * x * M_PI) + 20.0 *sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    lat += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    lat += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return lat;
}

+(double)transformLonWithX:(double)x withY:(double)y
{
    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    lon += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    lon += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    lon += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return lon;
}

//    CLLocation *location = [locations lastObject];
//    CLLocationCoordinate2D coor = location.coordinate;
//    NSLog(@"纬度：%.6f 经度%.6f", coor.latitude, coor.longitude);
//    NSString *x1 = [NSString stringWithFormat:@"%f", coor.longitude];
//    NSString *y1 = [NSString stringWithFormat:@"%f", coor.latitude];
//    NSLog(@"x1：%@  y1:%@", x1, y1);
//    [self getAddressWithCoordinate:coor];

//    // http://api.map.baidu.com/ag/coord/convert?from=0&to=2&x=113.377346&y=23.132648
//    NSDictionary *dict1 = @{@"from":@"0",
//                            @"to":@"2",
//                            @"x":x1,
//                            @"y":y1
//                            };
//
//    AFHTTPSessionManager *roManager = [AFHTTPSessionManager manager];
//
//    // 1、ios系统经纬度（国际标准）转谷歌经纬度
//    [roManager GET:@"http://api.map.baidu.com/ag/coord/convert" parameters:dict1 progress:^(NSProgress * _Nonnull downloadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if ([responseObject[@"error"] integerValue]) {
//            NSLog(@"ios系统经纬度（国际标准）转谷歌经纬度失败！！！");
//            return ;
//        }
//        NSString *resultX = [self base64Decode:responseObject[@"x"]];
//        NSString *resultY = [self base64Decode:responseObject[@"y"]];
//        NSDictionary *dict2 = @{@"from":@"2",
//                                @"to":@"4",
//                                @"x":resultX,
//                                @"y":resultY
//                                };
//
//        // 2、谷歌经纬度转百度经纬度
//        [roManager GET:@"http://api.map.baidu.com/ag/coord/convert" parameters:dict2 progress:^(NSProgress * _Nonnull downloadProgress) {
//
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            if ([responseObject[@"error"] integerValue]) {
//                NSLog(@"谷歌经纬度转百度经纬度失败！！！");
//                return ;
//            }
//            NSString *rx = [self base64Decode:responseObject[@"x"]];
//            NSString *ry = [self base64Decode:responseObject[@"y"]];
//            CLLocationCoordinate2D resultCoor = CLLocationCoordinate2DMake([ry floatValue], [rx floatValue]);
//            NSLog(@"转换后------------%f", [rx floatValue]);
//            // 给block赋值
//            if (_locationBlock) {
//                _locationBlock(resultCoor);
//            }
//
//            [self getAddressWithCoordinate:resultCoor];
//
//
//
//
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        }];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];

//#pragma mark - base64解密
//- (NSString *)base64Decode:(NSString *)str
//{
//    // 1、加密字符串转二进制数据
//    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    // 2、二进制数据转字符串
//    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//}

@end
