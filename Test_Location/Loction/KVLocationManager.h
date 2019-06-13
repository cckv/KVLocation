//
//  KVLocationManager.h
//
//  https://github.com/cckv/KVLocation.git
//
//  Created by CCKV on 16-4-19.
//  Copyright (c) 2016年 CCKV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface KVLocation : NSObject

@property (nonatomic, copy) NSString *formatted_address;    // 地名全称
@property (nonatomic, copy) NSString *province;             // 省名
@property (nonatomic, copy) NSString *city;                 // 市名
@property (nonatomic, copy) NSString *district;             // 区名
@property (nonatomic, copy) NSString *street;               // 路名
@property (nonatomic, copy) NSString *street_number;        // 路号

@end

typedef void(^locationBlock)(CLLocationCoordinate2D coor);
typedef void(^addressBlock)(NSString *address);
typedef void(^detailAddressBlock)(KVLocation *loca);

@interface KVLocationManager : NSObject

+ (instancetype)shareInstance;

/**
 *  获取纠偏后的经纬度
 */
- (void) getLocationCoordinate:(locationBlock) locaiontBlock;

/**
 *  获取纠偏后的经纬度
 */
- (void) getLocationCoordinate:(locationBlock) locaiontBlock address:(addressBlock) addressBlock;

/**
 *  获取纠偏后的经纬度和详细地址
 */
- (void) getLocationCoordinate:(locationBlock) locaiontBlock detailAddress:(detailAddressBlock) detailAddressBlock;

@end

