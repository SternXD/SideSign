//
//  SIDEDevice.m
//  SideSign
//
//  Created by Riley Testut on 5/10/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import "SIDEDevice.h"

#ifdef __cplusplus
extern "C" {
#endif

NSOperatingSystemVersion const NSOperatingSystemVersionUnknown = (NSOperatingSystemVersion){0, 0, 0};

NSOperatingSystemVersion NSOperatingSystemVersionFromString(NSString *osVersionString)
{
    NSArray *versionComponents = [osVersionString componentsSeparatedByString:@"."];
    
    NSInteger majorVersion = [versionComponents.firstObject integerValue];
    NSInteger minorVersion = (versionComponents.count > 1) ? [versionComponents[1] integerValue] : 0;
    NSInteger patchVersion = (versionComponents.count > 2) ? [versionComponents[2] integerValue] : 0;
    
    NSOperatingSystemVersion osVersion;
    osVersion.majorVersion = majorVersion;
    osVersion.minorVersion = minorVersion;
    osVersion.patchVersion = patchVersion;
    return osVersion;
}
    
NSString *_Nonnull NSStringFromOperatingSystemVersion(NSOperatingSystemVersion osVersion)
{
    NSString *stringValue = [NSString stringWithFormat:@"%@.%@", @(osVersion.majorVersion), @(osVersion.minorVersion)];
    if (osVersion.patchVersion != 0)
    {
        stringValue = [NSString stringWithFormat:@"%@.%@", stringValue, @(osVersion.patchVersion)];
    }
    
    return stringValue;
}
    
NSString *_Nullable SIDEOperatingSystemNameForDeviceType(SIDEDeviceType deviceType)
{
    switch (deviceType)
    {
        case SIDEDeviceTypeiPhone:
        case SIDEDeviceTypeiPad:
            return @"iOS";
            
        case SIDEDeviceTypeAppleTV:
            return @"tvOS";
            
        case SIDEDeviceTypeNone:
        case SIDEDeviceTypeAll:
        default:
            return nil;
    }
}

#ifdef __cplusplus
}
#endif

@implementation SIDEDevice

- (instancetype)initWithName:(NSString *)name identifier:(NSString *)identifier type:(SIDEDeviceType)type
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _identifier = [identifier copy];
        _type = type;
    }
    
    return self;
}

- (nullable instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary
{
    NSString *name = responseDictionary[@"name"];
    NSString *identifier = responseDictionary[@"deviceNumber"];
    
    if (name == nil || identifier == nil)
    {
        return nil;
    }
    
    SIDEDeviceType deviceType = SIDEDeviceTypeNone;
    
    NSString *deviceClass = responseDictionary[@"deviceClass"] ?: @"iphone";
    if ([deviceClass isEqualToString:@"iphone"])
    {
        deviceType = SIDEDeviceTypeiPhone;
    }
    else if ([deviceClass isEqualToString:@"ipad"])
    {
        deviceType = SIDEDeviceTypeiPad;
    }
    else if ([deviceClass isEqualToString:@"tvOS"])
    {
        deviceType = SIDEDeviceTypeAppleTV;
    }
    
    self = [self initWithName:name identifier:identifier type:deviceType];
    return self;
}

#pragma mark - NSObject -

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, Name: %@, UDID: %@>", NSStringFromClass([self class]), self, self.name, self.identifier];
}

- (BOOL)isEqual:(id)object
{
    SIDEDevice *device = (SIDEDevice *)object;
    if (![device isKindOfClass:[SIDEDevice class]])
    {
        return NO;
    }
    
    BOOL isEqual = [self.identifier isEqualToString:device.identifier];
    return isEqual;
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

#pragma mark - <NSCopying> -

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    SIDEDevice *device = [[SIDEDevice alloc] initWithName:self.name identifier:self.identifier type:self.type];
    device.osVersion = self.osVersion;
    return device;
}

@end
