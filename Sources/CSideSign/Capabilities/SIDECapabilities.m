//
//  SIDECapabilities.m
//  SideSign
//
//  Created by Riley Testut on 6/25/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import "SIDECapabilities.h"

// Entitlements
SIDEEntitlement const SIDEEntitlementApplicationIdentifier = @"application-identifier";
SIDEEntitlement const SIDEEntitlementKeychainAccessGroups = @"keychain-access-groups";
SIDEEntitlement const SIDEEntitlementAppGroups = @"com.apple.security.application-groups";
SIDEEntitlement const SIDEEntitlementGetTaskAllow = @"get-task-allow";
SIDEEntitlement const SIDEEntitlementTeamIdentifier = @"com.apple.developer.team-identifier";
SIDEEntitlement const SIDEEntitlementInterAppAudio = @"inter-app-audio";

// Features
SIDEFeature const SIDEFeatureGameCenter = @"gameCenter";
SIDEFeature const SIDEFeatureAppGroups = @"APG3427HIY";
SIDEFeature const SIDEFeatureInterAppAudio = @"IAD53UNK2F";

_Nullable SIDEEntitlement SIDEEntitlementForFeature(SIDEFeature feature)
{
    if ([feature isEqualToString:SIDEFeatureAppGroups])
    {
        return SIDEEntitlementAppGroups;
    }
    else if ([feature isEqualToString:SIDEFeatureInterAppAudio])
    {
        return SIDEEntitlementInterAppAudio;
    }
    
    return nil;
}

_Nullable SIDEFeature SIDEFeatureForEntitlement(SIDEEntitlement entitlement)
{
    if ([entitlement isEqualToString:SIDEEntitlementAppGroups])
    {
        return SIDEFeatureAppGroups;
    }
    else if ([entitlement isEqualToString:SIDEEntitlementInterAppAudio])
    {
        return SIDEFeatureInterAppAudio;
    }
    
    return nil;
}
