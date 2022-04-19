//
//  AppDelegate.m
//  Life
//
//  Created by Thomas Okken on 4/3/22.
//

#import "AppDelegate.h"
#import "LifeView.h"

@implementation AppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    [LifeView enterBackground];
}


@end
