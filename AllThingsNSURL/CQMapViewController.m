//
//  CQMapViewController.m
//  AllThingsNSURL
//
//  Created by mar Jinn on 12/14/13.
//  Copyright (c) 2013 mar Jinn. All rights reserved.
//

#import "CQMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

NSString *const FlickrAPIKey = @"562ce9dc2086e773508d66bed9a7c068";
NSString *const FlickrUserId = @"70227599@N07";

@interface CQMapViewController ()<MKMapViewDelegate>
   // private
{
@private
    NSMutableDictionary *parsedPhotosDictionary;
    NSUInteger totalNumberOfPhotos;
    NSUInteger updatesCount;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (void)searchFlickrPhotos;
- (void)saveGeoCodeData:(NSData *)data;
- (void)populateMapWithPhotoAnnotations;

@end

@implementation CQMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CLLocationCoordinate2D centerCoordinate;
    centerCoordinate.latitude = 38.311491;
    centerCoordinate.longitude = -105.24353;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 1.5f;
    span.longitudeDelta = 1.5f;
    
    MKCoordinateRegion region;
    region = MKCoordinateRegionMake(centerCoordinate, span);
    
    //set region
    [[self mapView]setRegion:region animated:YES];
    [[self mapView]setDelegate:self];
    
    [self searchFlickrPhotos];
    
    
    
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flickr API Processing

- (void)searchFlickrPhotos 
{
    
}

- (void)saveData:(NSData *)data 
{
    
}

- (void)saveGeoCodeData:(NSData *)data 
{
    
}

- (void)populateMapWithPhotoAnnotations
{
    
}



@end
