//
//  CQAppDelegate.m
//  AllThingsNSURL
//
//  Created by mar Jinn on 12/11/13.
//  Copyright (c) 2013 mar Jinn. All rights reserved.
//

#import "CQAppDelegate.h"

@interface CQAppDelegate ()
{
    __strong UIView* baseView;
    
}

@end



@implementation CQAppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self myOverlay];

    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self //display for 3 secs
                                   selector:@selector(continueLoadingWhatever:)
                                   userInfo:nil
                                    repeats:NO];
    
    return YES;
}


- (void)continueLoadingWhatever:(id)sender {
    //do whatever comes after here
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)myOverlay
{
    baseView = [[UIView alloc]init];
    //baseView Frame
    CGRect baseRectFrame;
    baseRectFrame = [[[UIApplication sharedApplication]keyWindow]frame];
    //set frame
    [baseView setFrame:baseRectFrame];
    [baseView setBackgroundColor:[UIColor grayColor]];
    [baseView setAlpha:0.85];
    //add BaseView to keywindow
    [[self window] addSubview:baseView];
    [[self window] bringSubviewToFront:baseView];
    
    
    //first rounded View
    UIView* firstBorder;
    firstBorder = [[UIView alloc]init];
    //frame
    CGRect firstBorderFrame;
    firstBorderFrame.origin.x = 10.0f;
    firstBorderFrame.origin.y = 20.0f;
    firstBorderFrame.size.width = 110.0f;
    firstBorderFrame.size.height = 110.0f;
    [firstBorder setFrame:firstBorderFrame];
    [[firstBorder layer]setBorderColor:[[UIColor whiteColor]CGColor]];
    [[firstBorder layer]setCornerRadius:5.0f];
    [[firstBorder layer]setBorderWidth:2.0f];
    //add baseView
    [baseView addSubview:firstBorder];
}



@end
