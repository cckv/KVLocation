//
//  KVMapViewLocationManager.m
//
//  https://github.com/cckv/KVLocation.git
//
//  Created by CCKV on 16-4-19.
//  Copyright (c) 2016年 CCKV. All rights reserved.
//

#import "KVMapViewLocationManager.h"

@implementation KVMapViewLocation

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

@end

@interface KVMapViewLocationManager ()<MKMapViewDelegate>

@property(nonatomic,strong) MKMapView *mapView;

@property (nonatomic, strong) NSStringBlock addressBlock;
@property (nonatomic, strong) LocationBlock locationBlock;
@property (nonatomic, strong) LocationErrorBlock errorBlock;
@property (nonatomic, strong) AddressBlock detailAddressBlock;

@end

@implementation KVMapViewLocationManager

+ (KVMapViewLocationManager *)shareLocation;
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void) getLocationCoordinate:(LocationBlock) locaiontBlock error:(LocationErrorBlock) errorBlock
{
    self.locationBlock = [locaiontBlock copy];
    self.errorBlock = [errorBlock copy];
    [self startLocation];
}

- (void) getLocationCoordinate:(LocationBlock) locaiontBlock  withAddress:(NSStringBlock) addressBlock error:(LocationErrorBlock) errorBlock
{
    self.locationBlock = [locaiontBlock copy];
    self.addressBlock = [addressBlock copy];
    self.errorBlock = [errorBlock copy];
    [self startLocation];
}

- (void) getLocationCoordinate:(LocationBlock) locaiontBlock  andAddress:(AddressBlock) addressBlock error:(LocationErrorBlock) errorBlock
{
    self.locationBlock = [locaiontBlock copy];
    self.detailAddressBlock = [addressBlock copy];
    self.errorBlock = [errorBlock copy];
    [self startLocation];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocation * newLocation = userLocation.location;
    
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
    {

        if (placemarks.count > 0)
        {
            CLPlacemark *placemark = placemarks.firstObject;
            
            NSDictionary *addressDic=placemark.addressDictionary;
            
            NSString *CountryCode=[addressDic objectForKey:@"CountryCode"];
            NSString *Country=[addressDic objectForKey:@"Country"];
            NSString *state=[addressDic objectForKey:@"State"];
            NSString *city=[addressDic objectForKey:@"City"];
            NSString *subLocality=[addressDic objectForKey:@"SubLocality"];
            NSString *street=[addressDic objectForKey:@"Street"];
//            NSString *Name=[addressDic objectForKey:@"Name"];
            NSString *SubThoroughfare=[addressDic objectForKey:@"SubThoroughfare"];
            
            NSArray *FormattedAddressLines=[addressDic objectForKey:@"FormattedAddressLines"];
            NSString *detailAddress=FormattedAddressLines.firstObject;

            if (self.addressBlock) {
                self.addressBlock(detailAddress);
            }
            if (self.locationBlock) {
                self.locationBlock(newLocation.coordinate);
            }
            if (self.detailAddressBlock) {
                KVMapViewLocation *location = [KVMapViewLocation new];
                location.formatted_address = detailAddress;
                location.CountryCode = CountryCode;
                location.Country = Country;
                location.province = state;
                location.city = city;
                location.district = subLocality;
                location.street = street;
                location.street_number = SubThoroughfare;
                self.detailAddressBlock(location);
            }
            
        }else{
            if (self.errorBlock) {
                NSError *error = [NSError errorWithDomain:@"KVMapViewLocationManager" code:400 userInfo:@{@"msg":@"获取地理信息失败"}];
                self.errorBlock(error);
            }
        }
        
        [self stopLocation];

    };
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [clGeoCoder reverseGeocodeLocation:newLocation completionHandler:handle];
}

-(void)startLocation
{
    if (_mapView) {
        _mapView = nil;
    }
    
    _mapView = [[MKMapView alloc] init];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
}

-(void)stopLocation
{
    _mapView.showsUserLocation = NO;
    _mapView = nil;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self stopLocation];
}

@end
