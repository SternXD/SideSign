//
//  SIDECapabilities.h
//  SideSign
//
//  Created by Riley Testut on 6/25/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Entitlements
typedef NSString *SIDEEntitlement NS_TYPED_EXTENSIBLE_ENUM;
extern SIDEEntitlement const SIDEEntitlementApplicationIdentifier;
extern SIDEEntitlement const SIDEEntitlementKeychainAccessGroups;
extern SIDEEntitlement const SIDEEntitlementAppGroups;
extern SIDEEntitlement const SIDEEntitlementGetTaskAllow;
extern SIDEEntitlement const SIDEEntitlementTeamIdentifier;
extern SIDEEntitlement const SIDEEntitlementInterAppAudio;

// Features
typedef NSString *SIDEFeature NS_TYPED_EXTENSIBLE_ENUM;
extern SIDEFeature const SIDEFeatureGameCenter;
extern SIDEFeature const SIDEFeatureAppGroups;
extern SIDEFeature const SIDEFeatureInterAppAudio;

_Nullable SIDEEntitlement SIDEEntitlementForFeature(SIDEFeature feature) NS_SWIFT_NAME(SIDEEntitlement.init(feature:));
_Nullable SIDEFeature SIDEFeatureForEntitlement(SIDEEntitlement entitlement) NS_SWIFT_NAME(SIDEFeature.init(entitlement:));

NS_ASSUME_NONNULL_END
