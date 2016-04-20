//
//  ViewController.m
//  CoreLocation
//
//  Created by apple on 16/4/20.
//  Copyright © 2016年 何万牡. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>

/**
 *  定位核心类
 */
@property (nonatomic,strong)CLLocationManager * locationM;

/**
 *  地理编码类
 */
@property (nonatomic,strong)CLGeocoder * geocoder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开！");
        return;
    }
    [self initLocationMnager];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        //请求前台定位授权
        [self.locationM requestWhenInUseAuthorization];
        //请求前后台授权
//        [self.locationM requestAlwaysAuthorization];
    }
    self.geocoder = [[CLGeocoder alloc] init];
    [self getCoordinateByAddress:@"三清山"];
    [self getCoordinateByLatitude:23 longitude:114];
}

/**
 *  创建CLLocationManager对象并启动定位
 */
-(void)initLocationMnager
{
    //创建CLLocationManager对象并设置代理
    self.locationM = [[CLLocationManager alloc] init];
    self.locationM.delegate = self;
    //设置定位精度和位置更新最小距离
    self.locationM.distanceFilter = 100;
    /**
     * kCLLocationAccuracyBestForNavigation 最适合导航
     * kCLLocationAccuracyBest 精度最好的
     * kCLLocationAccuracyNearestTenMeters 附近10米
     * kCLLocationAccuracyHundredMeters 附近100米
     * kCLLocationAccuracyKilometer 附近1000米
     * kCLLocationAccuracyThreeKilometers 附近3000米
     */
    
    self.locationM.desiredAccuracy = kCLLocationAccuracyBest;
}

/**
 *  当用户授权状态发生变化时调用
 *
 *  @param manager <#manager description#>
 *  @param status  <#status description#>
 */
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"用户还未决定");
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"定位关闭或者用户未授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"获得前后台定位授权");
            [self.locationM startUpdatingLocation];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"获得前台定位授权");
            [self.locationM startUpdatingLocation];
            break;
        }
        default:
            break;
    }
}

/**
 *  在对应的代理方法中获取位置信息
 *
 *  @param manager   <#manager description#>
 *  @param locations <#locations description#>
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation * location = [locations firstObject];//取出第一个位置
    /**
     *  使用位置前,务必判断当前获取的位置是否有效
     *  如果水平精度小于零,代表虽然可以获取位置对象,但是数据错误,不可用
     */
    if (location.horizontalAccuracy<0) {
        return;
    }
    CLLocationCoordinate2D coordinate = location.coordinate;//位置坐标
    CGFloat longitude = coordinate.longitude;//经度
    CGFloat latitude = coordinate.latitude;//纬度
    CGFloat altitude = location.altitude;//海拔
    CGFloat course = location.course;//方向
    CGFloat speed = location.speed;//速度
    NSLog(@"经度:%f,纬度:%f",longitude,latitude);
    NSLog(@"海拔:%f,方向:%f,速度:%f",altitude,course,speed);
    //如果不需要定位,使用完即可关闭定位服务
//    [self.locationM stopUpdatingLocation];
    
}

#pragma mark 根据地名确定地理坐标
-(void)getCoordinateByAddress:(NSString *)address
{
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //取得第一个地标,地标中存储了详细的地址信息,注意:一个地名可能搜索出多个地址
//        CLPlacemark * placemark = [placemarks firstObject];
        /*
         NSString *name = placemark.name;//地名
         NSString *thoroughfare = placemark.thoroughfare;//街道
         NSString *subThoroughfare = placemark.subThoroughfare; //街道相关信息，例如门牌等
         NSString *locality = placemark.locality; // 城市
         NSString *subLocality = placemark.subLocality; // 城市相关信息，例如标志性建筑
         NSString *administrativeArea = placemark.administrativeArea; // 州
         NSString *subAdministrativeArea = placemark.subAdministrativeArea; //其他行政区域信息
         NSString *postalCode = placemark.postalCode; //邮编
         NSString *ISOcountryCode = placemark.ISOcountryCode; //国家编码
         NSString *country = placemark.country; //国家
         NSString *inlandWater = placemark.inlandWater; //水源、湖泊
         NSString *ocean = placemark.ocean; // 海洋
         NSArray *areasOfInterest = placemark.areasOfInterest; //关联的或利益相关的地标
         */
        for (CLPlacemark * placemark in placemarks) {
            CLLocation * location = placemark.location;//位置
            CLRegion * region = placemark.region;//区域
            NSDictionary * addressDic = placemark.addressDictionary;//详细地址信息字典
                        NSLog(@"位置:%@,区域:%@,详细信息:%@",location,region,[NSString stringWithFormat:@"%@-%@-%@",[addressDic objectForKey:@"City"],[addressDic objectForKey:@"Country"],[[addressDic objectForKey:@"FormattedAddressLines"]firstObject]]);
        }
        
    }];
}
#pragma mark 根据坐标取得地名
-(void)getCoordinateByLatitude:(CLLocationDegrees)latitude
                     longitude:(CLLocationDegrees)longitude
{
    //反地理编码
    CLLocation * location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        NSLog(@"%@",error.localizedDescription);
        CLPlacemark * placemark = [placemarks firstObject];
        NSLog(@"详细信息:%@", placemark.addressDictionary);
    }];
}
@end
