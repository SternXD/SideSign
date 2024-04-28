//
//  SIDEApplication.h
//  AltSign
//
//  Created by Riley Testut on 6/24/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "SIDECapabilities.h"
#import "SIDEDevice.h"

@class SIDEProvisioningProfile;

NS_ASSUME_NONNULL_BEGIN

@interface SIDEApplication : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *bundleIdentifier;
@property (nonatomic, copy, readonly) NSString *version;

#if TARGET_OS_IPHONE
@property (nonatomic, readonly, nullable) UIImage *icon;
#endif

@property (nonatomic, readonly, nullable) SIDEProvisioningProfile *provisioningProfile;
@property (nonatomic, readonly) NSSet<SIDEApplication *> *appExtensions;

@property (nonatomic, readonly) NSOperatingSystemVersion minimumiOSVersion;
@property (nonatomic, readonly) SIDEDeviceType supportedDeviceTypes;

@property (nonatomic, copy, readonly) NSDictionary<SIDEEntitlement, id> *entitlements;
@property (nonatomic, copy, readonly) NSString *entitlementsString;

@property (nonatomic, copy, readonly) NSURL *fileURL;
@property (nonatomic, readonly) NSBundle *bundle;

@property (nonatomic, assign) BOOL hasPrivateEntitlements;

- (nullable instancetype)initWithFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
