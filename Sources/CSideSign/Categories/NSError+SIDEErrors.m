//
//  NSError+SIDEError.m
//  AltSign
//
//  Created by Riley Testut on 5/10/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import "NSError+SIDEErrors.h"

NSErrorDomain const AltSignErrorDomain = @"com.rileytestut.AltSign";
NSErrorDomain const SIDEAppleAPIErrorDomain = @"com.rileytestut.SIDEAppleAPI";

@implementation NSError (SIDEError)

+ (void)load
{
    [NSError setUserInfoValueProviderForDomain:AltSignErrorDomain provider:^id _Nullable(NSError * _Nonnull error, NSErrorUserInfoKey  _Nonnull userInfoKey) {
        if ([userInfoKey isEqualToString:NSLocalizedFailureReasonErrorKey])
        {
            return [error alt_localizedFailureReason];
        }
        
        return nil;
    }];
    
    [NSError setUserInfoValueProviderForDomain:SIDEAppleAPIErrorDomain provider:^id _Nullable(NSError * _Nonnull error, NSErrorUserInfoKey  _Nonnull userInfoKey) {
        if ([userInfoKey isEqualToString:NSLocalizedDescriptionKey])
        {
            return [error alt_appleapi_localizedDescription];
        }
        else if ([userInfoKey isEqualToString:NSLocalizedRecoverySuggestionErrorKey])
        {
            return [error alt_appleapi_localizedRecoverySuggestion];
        }
        
        return nil;
    }];
}

- (nullable NSString *)alt_localizedFailureReason
{
    switch ((SIDEError)self.code)
    {
        case SIDEErrorUnknown:
            return NSLocalizedString(@"An unknown error occured.", @"");
            
        case SIDEErrorInvalidApp:
            return NSLocalizedString(@"The app is invalid.", @"");
            
        case SIDEErrorMissingAppBundle:
            return NSLocalizedString(@"The provided .ipa does not contain an app bundle.", @"");
            
        case SIDEErrorMissingInfoPlist:
            return NSLocalizedString(@"The provided app is missing its Info.plist.", @"");
            
        case SIDEErrorMissingProvisioningProfile:
            return NSLocalizedString(@"Could not find matching provisioning profile.", @"");
    }
    
    return nil;
}

- (nullable NSString *)alt_appleapi_localizedDescription
{
    switch ((SIDEAppleAPIError)self.code)
    {
        case SIDEAppleAPIErrorUnknown:
            return NSLocalizedString(@"An unknown error occured.", @"");
            
        case SIDEAppleAPIErrorInvalidParameters:
            return NSLocalizedString(@"The provided parameters are invalid.", @"");
            
        case SIDEAppleAPIErrorIncorrectCredentials:
            return NSLocalizedString(@"Incorrect Apple ID or password.", @"");
            
        case SIDEAppleAPIErrorNoTeams:
            return NSLocalizedString(@"You are not a member of any development teams.", @"");
            
        case SIDEAppleAPIErrorAppSpecificPasswordRequired:
            return NSLocalizedString(@"An app-specific password is required. You can create one at appleid.apple.com.", @"");
            
        case SIDEAppleAPIErrorInvalidDeviceID:
            return NSLocalizedString(@"This device's UDID is invalid.", @"");
            
        case SIDEAppleAPIErrorDeviceAlreadyRegistered:
            return NSLocalizedString(@"This device is already registered with this team.", @"");
            
        case SIDEAppleAPIErrorInvalidCertificateRequest:
            return NSLocalizedString(@"The certificate request is invalid.", @"");
            
        case SIDEAppleAPIErrorCertificateDoesNotExist:
            return NSLocalizedString(@"There is no certificate with the requested serial number for this team.", @"");
            
        case SIDEAppleAPIErrorInvalidAppIDName:
            return NSLocalizedString(@"The name for this app is invalid.", @"");
            
        case SIDEAppleAPIErrorInvalidBundleIdentifier:
            return NSLocalizedString(@"The bundle identifier for this app is invalid.", @"");
            
        case SIDEAppleAPIErrorBundleIdentifierUnavailable:
            return NSLocalizedString(@"The bundle identifier for this app has already been registered.", @"");
            
        case SIDEAppleAPIErrorAppIDDoesNotExist:
            return NSLocalizedString(@"There is no App ID with the requested identifier on this team.", @"");
            
        case SIDEAppleAPIErrorMaximumAppIDLimitReached:
            return NSLocalizedString(@"You may only register 10 App IDs every 7 days.", @"");
            
        case SIDEAppleAPIErrorInvalidAppGroup:
            return NSLocalizedString(@"The provided app group is invalid.", @"");
            
        case SIDEAppleAPIErrorAppGroupDoesNotExist:
            return NSLocalizedString(@"App group does not exist", @"");
            
        case SIDEAppleAPIErrorInvalidProvisioningProfileIdentifier:
            return NSLocalizedString(@"The identifier for the requested provisioning profile is invalid.", @"");
            
        case SIDEAppleAPIErrorProvisioningProfileDoesNotExist:
            return NSLocalizedString(@"There is no provisioning profile with the requested identifier on this team.", @"");
            
        case SIDEAppleAPIErrorRequiresTwoFactorAuthentication:
            return NSLocalizedString(@"This account requires signing in with two-factor authentication.", @"");
            
        case SIDEAppleAPIErrorIncorrectVerificationCode:
            return NSLocalizedString(@"Incorrect verification code.", @"");
            
        case SIDEAppleAPIErrorAuthenticationHandshakeFailed:
            return NSLocalizedString(@"Failed to perform authentication handshake with server.", @"");
            
        case SIDEAppleAPIErrorInvalidAnisetteData:
            return NSLocalizedString(@"The provided anisette data is invalid.", @"");
    }
    
    return nil;
}

- (nullable NSString *)alt_appleapi_localizedRecoverySuggestion
{
    switch ((SIDEAppleAPIError)self.code)
    {
        case SIDEAppleAPIErrorInvalidAnisetteData:
#if TARGET_OS_OSX
            return NSLocalizedString(@"Make sure this computer's date & time matches your iOS device and try again.", @"");
#else
            return NSLocalizedString(@"Make sure your computer's date & time matches your iOS device and try again. You may need to re-install AltStore with AltServer if the problem persists.", @"");
#endif
            
        default: break;
    }
    
    return nil;
}

@end
