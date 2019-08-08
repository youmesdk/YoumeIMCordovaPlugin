/********* YoumeIMCordovaPlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "YIMClient.h"

@interface YoumeIMCordovaPlugin : CDVPlugin {
  // Member variables go here.
}

- (void)init:(CDVInvokedUrlCommand*)command;
@end

@implementation YoumeIMCordovaPlugin

- (void)init:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* appKey = [command.arguments objectAtIndex:0];
    NSString* secretKey = [command.arguments objectAtIndex:1];
    NSNumber* regionId = [command.arguments objectAtIndex:2];
    
    YIMErrorcodeOC code = [[YIMClient GetInstance] InitWithAppKey:appKey appSecurityKey:secretKey serverZone:(YouMeIMServerZoneOC) [regionId integerValue] ];
    
    
    if (code == YouMeIMCode_Success) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
