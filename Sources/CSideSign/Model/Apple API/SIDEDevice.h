//
//  SIDEDevice.h
//  AltSign
//
//  Created by Riley Testut on 5/10/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

// NS_SWIFT_NAME can only prefix types with types from same module.
// Re-declare NSOperatingSystemVersion as _NSOperatingSystemVersion,
// which will still map to OperatingSystemVersion in Swift.
typedef NSOperatingSystemVersion _NSOperatingSystemVersion;

typedef NS_OPTIONS(NSInteger, SIDEDeviceType)
{
    SIDEDeviceTypeiPhone NS_SWIFT_NAME(iphone) = 1 << 1,
    SIDEDeviceTypeiPad NS_SWIFT_NAME(ipad) = 1 << 2,
    SIDEDeviceTypeAppleTV NS_SWIFT_NAME(appletv) = 1 << 3,
    
    SIDEDeviceTypeNone = 0,
    SIDEDeviceTypeAll = (SIDEDeviceTypeiPhone | SIDEDeviceTypeiPad | SIDEDeviceTypeAppleTV),
};

#ifdef __cplusplus
extern "C" {
#endif

NS_SWIFT_NAME(_NSOperatingSystemVersion.unknown)
extern const NSOperatingSystemVersion NSOperatingSystemVersionUnknown;

NS_SWIFT_NAME(_NSOperatingSystemVersion.init(string:))
extern NSOperatingSystemVersion NSOperatingSystemVersionFromString(NSString *_Nonnull osVersionString);

NS_SWIFT_NAME(getter:_NSOperatingSystemVersion.stringValue(self:))
extern NSString *_Nonnull NSStringFromOperatingSystemVersion(NSOperatingSystemVersion osVersion);

NS_SWIFT_NAME(getter:SIDEDeviceType.osName(self:))
extern NSString *_Nullable SIDEOperatingSystemNameForDeviceType(SIDEDeviceType deviceType);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SIDEDevice : NSObject <NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic) SIDEDeviceType type;
@property (nonatomic) NSOperatingSystemVersion osVersion;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name identifier:(NSString *)identifier type:(SIDEDeviceType)type NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
