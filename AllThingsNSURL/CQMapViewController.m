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


#import "CQPhotoAnnotation.h"

#define DOWNLOADNOTIFICATION "download.completed.notificon"

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



-(void)viewWillAppear:(BOOL)animated
{
    //subscribe to Download done notification
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(saveData:)
     name:@"download.completed.notificon"
     object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    //Remove to Download done notification
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:@"download.completed.notificon"
     object:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flickr API Processing

//In this step you’ll add implementation for the searchFlickrPhotos method.
//Find the empty placeholder for the method, which was added in step 12, and
//insert code for it as shown in Figure 3-24 (DemoMonkey step ‘‘08
//MapViewController.m searchFlickrPhotos’’). In this method you construct a URL
//string that will initiate a search request to the Flickr server (the format
//of the URL request and available parameters are provided in Flickr
//documentation, at http://flickr.com/services/api/; in our case, we specified
//the API key, user ID, geotag option, and response format). Note that you’re
//outputting the URL you just built to the console for testing purposes. In the
//next couple of lines, you create an NSURL object with the constructed string
//and dispatch synchronous download request for the contents of that URL by
//calling the dataWithContentsOfURL: static method on NSData. Note that the
//download request is performed in a background thread----otherwise the UI may
//become unresponsive to the user. Right before the request is sent, start your
//Activity Indicator, so you can see the progress. (Upon completion of the data
//transfer you’ll invoke the saveData: selector, in which you parse the JSON
//data, save it in a usable format, and perform other necessary operations with
//the fetched data. This step is coming shortly.)

#pragma mark Flicker API
#pragma mark -
- (void)searchFlickrPhotos
{
    //start the activity indicator
    [[self activityIndicator]startAnimating];
    
    //Build  the string to call the FLicker API
    NSString* urlString = nil;
    urlString = [NSString stringWithFormat:
                 @"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&user_id=%@&has_geo=1&format=json&nojsoncallback=1",
                 FlickrAPIKey,FlickrUserId];
    //Log it
    NSLog(@"urlString%@",urlString);
    
    //Start Download in  a thread
    dispatch_async(
                   dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //
        NSData* data = nil;
        data = [NSData dataWithContentsOfURL:
                [NSURL URLWithString:urlString]];
        
        //post Notification when Download is done
        [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"download.completed.notificon"
         object:self];
                       
        
    });
    
}

- (void)saveData:(NSData *)data 
{
    __autoreleasing NSError* error = nil;
    NSDictionary* response = nil;
    response = [NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingMutableContainers
                                      error:&error];
    NSArray* photos = nil;
    if (response)
    {
        NSLog(@"response-%@",response);
        photos = [[response objectForKey:@"photos"] objectForKey:@"photo"];
    }
    else
    {
        NSLog(@"NSJSON Response error-%@",error);
    }
    
    //get total number of photos
    totalNumberOfPhotos = 0;
    if (photos) {
        totalNumberOfPhotos = [photos count];
        if (totalNumberOfPhotos) {
            //create photo dictionary
            parsedPhotosDictionary =
            [NSMutableDictionary dictionaryWithCapacity:totalNumberOfPhotos];
            
            //enumerate through the "photos" array
            [photos enumerateObjectsUsingBlock:
             ^(id obj, NSUInteger idx, BOOL *stop) {
                //
                 if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                     //
                     //get thumbnailURL
                     NSString* thumbnailURLString = nil;
                     thumbnailURLString =
                     [NSString
                      stringWithFormat:
                      @"http://fram%@.static.flickr.com/%@/%@_%@_t.jpg",
                      [obj objectForKey:@"farm"],
                      [obj objectForKey:@"server"],
                      [obj objectForKey:@"id"],
                      [obj objectForKey:@"secret"]
                      ];
                     
                     //Construct the URL to where the medium size image is
                     //located on Flicr (to zoom to when requested)
                     NSString* photoURLString = nil;
                     photoURLString =
                     [NSString
                      stringWithFormat:
                      @"http://fram%@.static.flickr.com/%@/%@_%@.jpg",
                      [obj objectForKey:@"farm"],
                      [obj objectForKey:@"server"],
                      [obj objectForKey:@"id"],
                      [obj objectForKey:@"secret"]
                      ];
                     
                     //Construct the URL to location information
                     //where image was taken(for geotagged images)
                     NSString* photoGeoInfoURLString = nil;
                     photoGeoInfoURLString = [NSString
                                              stringWithFormat:
                                              @"http://api.flickr.com/services/\
                                              rest/?method=\
                                              flickr.photos.geo.getLocation&api_key=\
                                              %@&photo_id=%@&format=json&nojsoncallback=1",
                                              FlickrAPIKey,
                                              [obj objectForKey:@"id"]
                                              ];
                     
                   // Save the constructe URLs for later use;
                     [obj setObject:[NSURL URLWithString:thumbnailURLString]
                             forKey:@"thumbnailurl"];
                     [obj setObject:[NSURL URLWithString:thumbnailURLString]
                             forKey:@"mediumimageurl"];
                     
                     [parsedPhotosDictionary setObject:obj
                                                forKey:
                      [obj valueForKey:@"id"]];
                     
                     //Send request to get geocode for each photo
                     dispatch_async(
                                    dispatch_get_global_queue
                                    (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                    ^{//
                                        NSData* data = nil;
                                        data =
                                        [NSData dataWithContentsOfURL:
                                         [NSURL URLWithString:
                                          photoURLString]];
                                       [self
                                        performSelectorOnMainThread:
                                        @selector(saveGeoCodeData:)
                                        withObject:data waitUntilDone:YES];
                                        
                                    });//dispatch_async

                 }//[obj isKindOfClass:[NSMutableDictionary class]
                
             }];// photos enumerateObjectsUsingBlock
            
            
            
        }//totalNumberOfPhotos!=nil
    }//photos!=nil
        updatesCount = 0;
    
    
    
}

- (void)saveGeoCodeData:(NSData *)data 
{
    
}

- (void)populateMapWithPhotoAnnotations
{
    
}


#pragma mark - MKMapViewDelegate Protocol
#pragma mark -

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
-(MKAnnotationView *)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation
{
    //check if "annotation" is CQPhotoAnnotation
    //CQPhotoAnnotation - cutsom MKAnnotation subclass
    if ([annotation isKindOfClass:[CQPhotoAnnotation class]]) {
        
        //Use our pin image for annotation
        //annotation has a disclosure button callout accessory
        
        //Returns a reusable annotation view located by its identifier.
        //The MKAnnotationView class is responsible for presenting annotations
        //visually in a map view. Annotation views are loosely coupled to a
        //corresponding annotation object, which is an object that corresponds
        //to the MKAnnotation protocol. When an annotation’s coordinate point
        //is in the visible region, the map view asks its delegate to provide a
        //corresponding annotation view. Annotation views may be recycled later
        //and put into a reuse queue that is maintained by the map view.
        __autoreleasing MKAnnotationView* annotationView;
        annotationView = [mapView
                          dequeueReusableAnnotationViewWithIdentifier:
                          @"PhotoAnnotation"];
        
        //create annotationView
        //W will add pin Image to the view
        if (annotationView ==nil) {
            annotationView = [[MKAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:@"PhotoAnnotation"];
        }
        
        //setAnnotationView image
        UIImage* bluePinImage = nil;
        bluePinImage = [UIImage imageNamed:@"BluePin"];
        if (bluePinImage) {
            [annotationView setImage:bluePinImage];
        }
        
        //make annotationview to allow callout
        [annotationView setCanShowCallout:YES];
        
        //add right callout accessory view
        //we add a button
        //type -> UIButtonTypeDetailDisclosure
        UIButton* disclosureButton = nil;
        disclosureButton = [UIButton buttonWithType:
                            UIButtonTypeDetailDisclosure];
        //add it as right callout accessory view
        [annotationView setRightCalloutAccessoryView:disclosureButton];
        //add it as left - trial
        [annotationView setRightCalloutAccessoryView:disclosureButton];
        
        //return the view
        return annotationView;
    }
    //if annotation =! [CQPhotoAnnotation class]
    return nil;
}







@end
