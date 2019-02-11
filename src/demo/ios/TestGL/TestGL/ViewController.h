//
//  ViewController.h
//  TestGL
//
//  Created by Graham Asher on 15/11/2017.
//  Copyright © 2017-2018 CartoType. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "CartoTypeMapView.h"

@interface ViewController : GLKViewController <UIGestureRecognizerDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

-(id)initWithFramework:(CartoTypeFramework*)aFramework;

@end
