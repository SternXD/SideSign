//
//  SIDEAppleAPI.h
//  AltSign
//
//  Created by Riley Testut on 5/22/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SIDECapabilities.h"
#import "SIDEDevice.h"

@class SIDEAppleAPISession;

@class SIDEAccount;
@class SIDEAnisetteData;
@class SIDETeam;
@class SIDEDevice;
@class SIDECertificate;
@class SIDEAppID;
@class SIDEAppGroup;
@class SIDEProvisioningProfile;

NS_ASSUME_NONNULL_BEGIN

@interface SIDEAppleAPI : NSObject

@property (class, nonatomic, readonly) SIDEAppleAPI *sharedAPI;

/* Teams */
- (void)fetchTeamsForAccount:(SIDEAccount *)account session:(SIDEAppleAPISession *)session
           completionHandler:(void (^)(NSArray<SIDETeam *> *_Nullable teams, NSError *_Nullable error))completionHandler;

/* Devices */
- (void)fetchDevicesForTeam:(SIDETeam *)team types:(SIDEDeviceType)types session:(SIDEAppleAPISession *)session
          completionHandler:(void (^)(NSArray<SIDEDevice *> *_Nullable devices, NSError *_Nullable error))completionHandler;

- (void)registerDeviceWithName:(NSString *)name identifier:(NSString *)identifier type:(SIDEDeviceType)type team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
             completionHandler:(void (^)(SIDEDevice *_Nullable device, NSError *_Nullable error))completionHandler
NS_SWIFT_NAME(registerDevice(name:identifier:type:team:session:completionHandler:));

/* Certificates */
- (void)fetchCertificatesForTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session
               completionHandler:(void (^)(NSArray<SIDECertificate *> *_Nullable certificates, NSError *_Nullable error))completionHandler;

- (void)addCertificateWithMachineName:(NSString *)name toTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session
                    completionHandler:(void (^)(SIDECertificate *_Nullable certificate, NSError *_Nullable error))completionHandler
NS_SWIFT_NAME(addCertificate(machineName:to:session:completionHandler:));

- (void)revokeCertificate:(SIDECertificate *)certificate forTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session
        completionHandler:(void (^)(BOOL success, NSError *_Nullable error))completionHandler
NS_SWIFT_NAME(revoke(_:for:session:completionHandler:));

/* App IDs */
- (void)fetchAppIDsForTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session
         completionHandler:(void (^)(NSArray<SIDEAppID *> *_Nullable appIDs, NSError *_Nullable error))completionHandler;

- (void)addAppIDWithName:(NSString *)name bundleIdentifier:(NSString *)bundleIdentifier team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
       completionHandler:(void (^)(SIDEAppID *_Nullable appID, NSError *_Nullable error))completionHandler;

- (void)updateAppID:(SIDEAppID *)appID team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
  completionHandler:(void (^)(SIDEAppID * _Nullable appID, NSError * _Nullable error))completionHandler;

- (void)deleteAppID:(SIDEAppID *)appID forTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session
  completionHandler:(void (^)(BOOL success, NSError *_Nullable error))completionHandler;

/* App Groups */
- (void)fetchAppGroupsForTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session
            completionHandler:(void (^)(NSArray<SIDEAppGroup *> *_Nullable groups, NSError *_Nullable error))completionHandler;

- (void)addAppGroupWithName:(NSString *)name groupIdentifier:(NSString *)groupIdentifier team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
       completionHandler:(void (^)(SIDEAppGroup *_Nullable group, NSError *_Nullable error))completionHandler;

- (void)assignAppID:(SIDEAppID *)appID toGroups:(NSArray<SIDEAppGroup *> *)groups team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
  completionHandler:(void (^)(BOOL success, NSError *_Nullable error))completionHandler;

/* Provisioning Profiles */
- (void)fetchProvisioningProfileForAppID:(SIDEAppID *)appID deviceType:(SIDEDeviceType)deviceType team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
                       completionHandler:(void (^)(SIDEProvisioningProfile *_Nullable provisioningProfile, NSError *_Nullable error))completionHandler;

- (void)deleteProvisioningProfile:(SIDEProvisioningProfile *)provisioningProfile forTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session
  completionHandler:(void (^)(BOOL success, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
