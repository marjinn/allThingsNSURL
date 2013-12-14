//
//  CQPhotoAnnotation.m
//  AllThingsNSURL
//
//  Created by mar Jinn on 12/14/13.
//  Copyright (c) 2013 mar Jinn. All rights reserved.
//

#import "CQPhotoAnnotation.h"

@interface CQPhotoAnnotation()

    // Center latitude and longitude of the annotion view.
    // The implementation of this property must be KVO compliant.
    @property (nonatomic) CLLocationCoordinate2D coordinate;
    
    // Title and subtitle for use by selection UI.
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, copy) NSString *subtitle;
    
    
    @property(nonatomic,strong)UIImage* image;
    @property(nonatomic,strong)UIImage* thumbnail;
    @property(nonatomic,strong)NSURL* imageURL;
    @property(nonatomic,strong)NSURL* thumbnailURL;
    
    
    -(id)initWithImage:(NSURL *)cqImageURL
thumbnailURL:(NSURL *)cqThumbnailURL
title:(NSString *)cqTitle
coordinate:(CLLocationCoordinate2D)cqCoordinate;
    
    -(void)updateSubtitle;


@end
@implementation CQPhotoAnnotation


-(id)initWithImage:(NSURL *)cqImageURL
      thumbnailURL:(NSURL *)cqThumbnailURL
             title:(NSString *)cqTitle
        coordinate:(CLLocationCoordinate2D)cqCoordinate
{
    self = [super init];
    if (self) {
        //statements
        [self setImageURL:cqImageURL];
        [self setThumbnailURL:cqThumbnailURL];
        [self setTitle:cqTitle];
        [self setCoordinate:cqCoordinate];
    }
    return self;
}


-(NSString *)title
{
    return [self title];
}

-(UIImage *)image
{
    //we don't want all images loaded in memory unnecessarily ,so we should
    //wait to load the image untill we actually want to display it
    if (![self image] && [self imageURL]) {
        
        __block NSData* imageData;
        imageData = nil;
        
        //make URL Request
        NSURLRequest* theRequest;
        theRequest = [NSURLRequest requestWithURL:[self imageURL]
                                      cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                  timeoutInterval:60.0];
        
        //send the request
        [NSURLConnection sendAsynchronousRequest:theRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:
    ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        //if error
        if (!connectionError) {
            imageData = data;
        }
        else{
            //log the error
            NSLog(@"ConnectionError-%@",[connectionError description]);
        }
        
        //log the response Object
        if (response) {
            //
            NSLog(@"response Obj-%@",[response description]);
        }
    }
         ];
        
        //set the image
        if (imageData) {
            [self setImage:[UIImage imageWithData:imageData]];
        }
    }
    return [self image];
}

-(UIImage *)thumbnail
{
    //we don't want all images loaded in memory unnecessarily ,so we should
    //wait to load the image untill we actually want to display it
    if (![self image] && [self thumbnailURL]) {
        
        __block NSData* imageData;
        imageData = nil;
        
        //make URL Request
        NSURLRequest* theRequest;
        theRequest = [NSURLRequest requestWithURL:[self thumbnailURL]
                                      cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                  timeoutInterval:60.0];
        
        //send the request //on main thread
        [NSURLConnection sendAsynchronousRequest:theRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:
         ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             //if error
             if (!connectionError) {
                 imageData = data;
             }
             else{
                 //log the error
                 NSLog(@"ConnectionError-%@",[connectionError description]);
             }
             
             //log the response Object
             if (response) {
                 //
                 NSLog(@"response Obj-%@",[response description]);
             }
         }
         ];
        
        if (imageData) {
            [self setThumbnail:[UIImage imageWithData:imageData]];
        }
        
    }
    return [self thumbnail];
}


#pragma mark - Reverse geocode subtitle
#pragma mark -

//Returns string of "City,State" format if available
-(NSString *)placemarkToString:(CLPlacemark *)placemark
{
    //placemark string that hold reverse geocoding Info
    __autoreleasing NSMutableString* placemarkString;
    placemarkString = [[NSMutableString alloc]init];//autorelease
    
    //if locality Available
    if ([placemark locality]) {
        [placemarkString appendString:[placemark locality]];
    }
    
    //if administrativeArea
    if ([placemark administrativeArea]) {
        if ([placemarkString length] > 0) {
            [placemarkString appendString:@" , "];
            [placemarkString appendString:[placemark administrativeArea]];
        }
    }
    
    //if name
    if ([placemarkString length] == 0 && [placemark name]) {
        [placemarkString appendString:[placemark name]];
    }
    
    return placemarkString;
}



/**
 *@function    updateSubtitle
 * Description
 * updated "subtitle" variable
 *I
 * @param           none
 * @return          none
 * 
 * @discussion
 *
 */

/* *SAMPLE DOCUMETATION TAGS */
//HeaderDoc
/*
https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/tags/tags.html
 */

// Listing 2-7  Example of documentation with @abstract and @discussion tags
 /*!
 @class IOCommandGate
  A class that defines a single-threaded work-loop client request mechanism.
  An IOCommandGate instance is an extremely light weight mechanism 
  that executes an action on the driver's work-loop...
 @abstract Single-threaded work-loop client request mechanism.
 @discussion An IOCommandGate instance is an extremely light weight 
                    mechanism that executes an action on the driver's 
                    work-loop...
 @throws foo_exception
 @throws bar_exception
 @namespace I/O Kit (this is just a string)
 @updated 2013-12-14 06:04 am
 */






-(void)updateSubtitle
{
    if ([self subtitle] != nil) {
        return;
    }
    
    //Reverse Geocoding
    //location to Use
    CLLocation* location;
    location = [[CLLocation alloc]initWithLatitude:[self coordinate].latitude
                                         longitude:[self coordinate].longitude];
    
    //start Geocoding
    //geocoder obj
    CLGeocoder* geocoder;
    geocoder = [[CLGeocoder alloc]init];
    
    //geocoding error var
    __block NSError* err;
    err = nil;
    
    //reverse geocoding
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       //
                       if ([placemarks count] > 0) {
                           
                           //object at index 0 - best match
                           CLPlacemark* placemark;
                           placemark = [placemarks objectAtIndex:0];
                           
                           //set Subtitle - placemark obj is passed to
                           //a function (placemarkToString)
                           //that returns the string value
                           [self setSubtitle:[self placemarkToString:placemark]];
                           
                           err = error;
                       }
                       
                   }];
    //logging geocoder error
    if (err) {
        NSLog(@"geocoder Error-%@",[err description]);
    }
    
}

@end
