//
//  KVMapViewLocationManager.h
//
//  https://github.com/cckv/KVLocation.git
//
//  Created by CCKV on 16-4-19.
//  Copyright (c) 2016年 CCKV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KVMapViewLocation : NSObject

@property (nonatomic,copy) NSString *CountryCode;           // 国家d代号
@property (nonatomic,copy) NSString *Country;               // 国家名
@property (nonatomic, copy) NSString *formatted_address;    // 地名全称
@property (nonatomic, copy) NSString *province;             // 省名
@property (nonatomic, copy) NSString *city;                 // 市名
@property (nonatomic, copy) NSString *district;             // 区名
@property (nonatomic, copy) NSString *street;               // 路名
@property (nonatomic, copy) NSString *street_number;        // 路号

@end


typedef void (^LocationBlock)(CLLocationCoordinate2D locationCorrrdinate);
typedef void (^LocationErrorBlock) (NSError *error);
typedef void(^NSStringBlock)(NSString *cityString);
typedef void(^NSStringBlock)(NSString *addressString);
typedef void(^AddressBlock)(KVMapViewLocation *loca);


@interface KVMapViewLocationManager : NSObject

+ (KVMapViewLocationManager *)shareLocation;

/**
 *  获取坐标
 *
 *  @param locaiontBlock locaiontBlock description
 */
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock error:(LocationErrorBlock) errorBlock;

/**
 *  获取坐标和地址
 *
 *  @param locaiontBlock locaiontBlock description
 *  @param addressBlock  addressBlock description
 */
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock  withAddress:(NSStringBlock) addressBlock error:(LocationErrorBlock) errorBlock;

/**
 *  获取坐标和地址模型
 *
 *  @param locaiontBlock locaiontBlock description
 *  @param addressBlock  AddressBlock description
 */
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock  andAddress:(AddressBlock) addressBlock error:(LocationErrorBlock) errorBlock;

@end
