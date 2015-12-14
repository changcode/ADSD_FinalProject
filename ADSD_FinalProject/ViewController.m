//
//  ViewController.m
//  ADSD_FinalProject
//
//  Created by Chang on 12/13/15.
//  Copyright © 2015 changcode.github.io. All rights reserved.
//

#import "ViewController.h"
#import "HTTPTools.h"
#import "SVProgressHUD.h"

@import MapKit;
@import UIKit;

@interface ViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISlider *distance;
@property (weak, nonatomic) IBOutlet UILabel *disLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = 41.20389;
    mapRegion.center.longitude = -81.512107;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
//    CLLocationCoordinate2D startPosition = CLLocationCoordinate2DMake(41.20389, -81.512107);
    self.distance.minimumValue = 0;
    self.distance.maximumValue = 20;
    [self.distance addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.mapView setRegion:mapRegion animated: YES];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    
    [self.mapView addGestureRecognizer:lpgr];
    self.mapView.delegate = self;
}

- (void)valueChanged:(UISlider *)sender {
    self.disLabel.text = [NSString stringWithFormat:@"%.2lf miles", sender.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    [annot setTitle:@"Selected Point"];
    [annot setSubtitle:[NSString stringWithFormat:@"Lon:%lf, Lat:%lf",touchMapCoordinate.longitude ,touchMapCoordinate.latitude ]];
    [self.mapView addAnnotation:annot];
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:annot.coordinate radius:self.distance.value*1609.34];
    [self.mapView addOverlay:circle];
    
    [self show];
    [HTTPTools requestNearByPoint:[NSNumber numberWithDouble:self.distance.value] Longitude:[NSNumber numberWithDouble: touchMapCoordinate.longitude] Latitude: [NSNumber numberWithDouble:touchMapCoordinate.latitude] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showSuccessWithStatus];
        
        for (NSDictionary *point in responseObject[@"data"]) {
            MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
            CLLocationCoordinate2D markCoor = CLLocationCoordinate2DMake([point[@"location"][@"coordinates"][1] doubleValue], [point[@"location"][@"coordinates"][0] doubleValue]);
            annot.coordinate = markCoor;
            annot.title = point[@"title"];
            
            [self.mapView addAnnotation:annot];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showErrorWithStatus];
    }];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    if(annotation!= self.mapView.userLocation)
    {
        
        static NSString *defaultPin = @"pinIdentifier";
        pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPin];
        if(pinView == nil)
            pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:defaultPin];
        pinView.pinColor = MKPinAnnotationColorPurple; //Optional
        if ([annotation.title isEqualToString:@"Selected Point"] ) {
            pinView.pinTintColor = MKPinAnnotationColorRed;
        }
        pinView.canShowCallout = YES; // Optional
        pinView.animatesDrop = YES;
    }
    else
    {
        [self.mapView.userLocation setTitle:@"You are Here!"];
    }
    return pinView;
}
- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor blueColor];
    circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    return circleView;
}


- (void)show {
    [SVProgressHUD show];

}

- (void)showWithStatus {
    [SVProgressHUD showWithStatus:@"Doing Stuff"];
}

- (void)dismiss {
    [SVProgressHUD dismiss];
}

- (void)showInfoWithStatus{
    [SVProgressHUD showInfoWithStatus:@"Useful Information."];
    
}

- (void)showSuccessWithStatus {
    [SVProgressHUD showSuccessWithStatus:@"Load Success!"];
}

- (void)showErrorWithStatus {
    [SVProgressHUD showErrorWithStatus:@"Failed with Error"];
}

@end
