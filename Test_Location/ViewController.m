//
//  ViewController.m
//  Test_Location
//
//  Created by CCKV on 2019/5/27.
//  Copyright © 2019年 CCKV. All rights reserved.
//

#import "ViewController.h"
#import "KVLocationManager.h"
#import "KVMapViewLocationManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getLocation];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self getLocation];
}

- (void)getLocation
{
    [[KVLocationManager shareInstance] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
        NSLog(@"");
    }];
    [[KVLocationManager shareInstance] getLocationCoordinate:^(CLLocationCoordinate2D coor) {
        NSLog(@"");
    } address:^(NSString *address) {
        NSLog(@"%@",address);
    }];
    [[KVLocationManager shareInstance] getLocationCoordinate:^(CLLocationCoordinate2D coor) {
        NSLog(@"");
    } detailAddress:^(KVLocation *loca) {
        NSLog(@"%@",loca.formatted_address);
    }];
    
    [[KVMapViewLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
        
    } error:^(NSError *error) {
        
    }];
    [[KVMapViewLocationManager shareLocation]getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
        
    } andAddress:^(KVMapViewLocation *loca) {
        
    } error:^(NSError *error) {
        
    }];
    
    [[KVMapViewLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
        
    } withAddress:^(NSString *addressString) {
        
    } error:^(NSError *error) {
        
    }];
}

@end
