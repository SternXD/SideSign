//
//  NSError+SIDEErrors.h
//  SideSign
//
//  Created by Riley Testut on 5/10/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const SideSignErrorDomain;
typedef NS_ERROR_ENUM(SideSignErrorDomain, SIDEError)
{
    SIDEErrorUnknown,
    SIDEErrorInvalidApp,
    SIDEErrorMissingAppBundle,
    SIDEErrorMissingInfoPlist,
    SIDEErrorMissingProvisioningProfile,
};

extern NSErrorDomain const SIDEAppleAPIErrorDomain;
typedef NS_ERROR_ENUM(SIDEAppleAPIErrorDomain, SIDEAppleAPIError)
{
    SIDEAppleAPIErrorUnknown,
    SIDEAppleAPIErrorInvalidParameters,
    
    SIDEAppleAPIErrorIncorrectCredentials,
    SIDEAppleAPIErrorAppSpecificPasswordRequired,
    
    SIDEAppleAPIErrorNoTeams,
    
    SIDEAppleAPIErrorInvalidDeviceID,
    SIDEAppleAPIErrorDeviceAlreadyRegistered,
    
    SIDEAppleAPIErrorInvalidCertificateRequest,
    SIDEAppleAPIErrorCertificateDoesNotExist,
    
    SIDEAppleAPIErrorInvalidAppIDName,
    SIDEAppleAPIErrorInvalidBundleIdentifier,
    SIDEAppleAPIErrorBundleIdentifierUnavailable,
    SIDEAppleAPIErrorAppIDDoesNotExist,
    SIDEAppleAPIErrorMaximumAppIDLimitReached,
    
    SIDEAppleAPIErrorInvalidAppGroup,
    SIDEAppleAPIErrorAppGroupDoesNotExist,
    
    SIDEAppleAPIErrorInvalidProvisioningProfileIdentifier,
    SIDEAppleAPIErrorProvisioningProfileDoesNotExist,
    
    SIDEAppleAPIErrorRequiresTwoFactorAuthentication,
    SIDEAppleAPIErrorIncorrectVerificationCode,
    SIDEAppleAPIErrorAuthenticationHandshakeFailed,
    
    SIDEAppleAPIErrorInvalidAnisetteData,
};

NS_ASSUME_NONNULL_BEGIN

@interface NSError (SIDEError)

@end

NS_ASSUME_NONNULL_END
