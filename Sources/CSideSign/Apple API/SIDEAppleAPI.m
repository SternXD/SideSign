//
//  SIDEAppleAPI.m
//  AltSign
//
//  Created by Riley Testut on 5/22/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import "SIDEAppleAPI_Private.h"
#import "SIDEAppleAPISession.h"

#import "SIDEAnisetteData.h"

#import "SIDEModel+Internal.h"

#import <AltSign/NSError+SIDEErrors.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const SIDEAuthenticationProtocolVersion = @"A1234";
NSString *const SIDEProtocolVersion = @"QH65B2";
NSString *const SIDEAppIDKey = @"ba2ec180e6ca6e6c6a542255453b24d6e6e5b2be0cc48bc1b0d8ad64cfe0228f";
NSString *const SIDEClientID = @"XABBG36SBA";

NS_ASSUME_NONNULL_END

@implementation SIDEAppleAPI

+ (instancetype)sharedAPI
{
    static SIDEAppleAPI *_appleAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _appleAPI = [[self alloc] init];
    });
    
    return _appleAPI;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        _dateFormatter = [[NSISO8601DateFormatter alloc] init];
        
        _baseURL = [[NSURL URLWithString:[NSString stringWithFormat:@"https://developerservices2.apple.com/services/%@/", SIDEProtocolVersion]] copy];
        _servicesBaseURL = [[NSURL URLWithString:@"https://developerservices2.apple.com/services/v1/"] copy];
    }
    
    return self;
}

#pragma mark - Teams -

- (void)fetchTeamsForAccount:(SIDEAccount *)account session:(SIDEAppleAPISession *)session completionHandler:(void (^)(NSArray<SIDETeam *> *teams, NSError *error))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"listTeams.action" relativeToURL:self.baseURL];
    
    [self sendRequestWithURL:URL additionalParameters:nil session:session team:nil completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        NSArray *teams = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSArray *array = responseDictionary[@"teams"];
            if (array == nil)
            {
                return nil;
            }
            
            NSMutableArray *teams = [NSMutableArray array];
            for (NSDictionary *dictionary in array)
            {
                SIDETeam *team = [[SIDETeam alloc] initWithAccount:account responseDictionary:dictionary];
                if (team == nil)
                {
                    return nil;
                }
                
                [teams addObject:team];
            }
            return teams;
        } resultCodeHandler:nil error:&error];
        
        if (teams != nil && teams.count == 0)
        {
            completionHandler(nil, [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorNoTeams userInfo:nil]);
        }
        else
        {
            completionHandler(teams, error);
        }        
    }];
}

#pragma mark - Devices -

- (void)fetchDevicesForTeam:(SIDETeam *)team types:(SIDEDeviceType)types session:(SIDEAppleAPISession *)session
          completionHandler:(void (^)(NSArray<SIDEDevice *> *_Nullable devices, NSError *_Nullable error))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/listDevices.action" relativeToURL:self.baseURL];
    
    [self sendRequestWithURL:URL additionalParameters:nil session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        NSArray *devices = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSArray *array = responseDictionary[@"devices"];
            if (array == nil)
            {
                return nil;
            }
            
            NSMutableArray *devices = [NSMutableArray array];
            for (NSDictionary *dictionary in array)
            {
                SIDEDevice *device = [[SIDEDevice alloc] initWithResponseDictionary:dictionary];
                if (device == nil)
                {
                    return nil;
                }
                
                if ((types & device.type) != device.type)
                {
                     // Device type doesn't match the ones we requested, so ignore it.
                    continue;
                }
                
                [devices addObject:device];
            }
            return devices;
        } resultCodeHandler:nil error:&error];
        
        completionHandler(devices, error);
    }];
}

- (void)registerDeviceWithName:(NSString *)name identifier:(NSString *)identifier type:(SIDEDeviceType)type team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
             completionHandler:(void (^)(SIDEDevice *_Nullable device, NSError *_Nullable error))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/addDevice.action" relativeToURL:self.baseURL];
    
    NSMutableDictionary *parameters = [@{
        @"deviceNumber": identifier,
        @"name": name,
    } mutableCopy];
    
    switch (type)
    {
        case SIDEDeviceTypeiPhone:
        case SIDEDeviceTypeiPad:
            parameters[@"DTDK_Platform"] = @"ios";
            break;
            
        case SIDEDeviceTypeAppleTV:
            parameters[@"DTDK_Platform"] = @"tvos";
            parameters[@"subPlatform"] = @"tvOS";
            break;
            
        default: break;
    }
    
    [self sendRequestWithURL:URL additionalParameters:parameters session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        SIDEDevice *device = [self processResponse:responseDictionary parseHandler:^id () {
            NSDictionary *dictionary = responseDictionary[@"device"];
            if (dictionary == nil)
            {
                return nil;
            }
            
            SIDEDevice *device = [[SIDEDevice alloc] initWithResponseDictionary:dictionary];
            return device;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 35:
                    if ([[[responseDictionary objectForKey:@"userString"] lowercaseString] containsString:@"already exists"])
                    {
                        return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorDeviceAlreadyRegistered userInfo:nil];
                    }
                    else
                    {
                        return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidDeviceID userInfo:nil];
                    }
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(device, error);
    }];
}

#pragma mark - Certificates -

- (void)fetchCertificatesForTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(NSArray<SIDECertificate *> * _Nullable, NSError * _Nullable))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"certificates" relativeToURL:self.servicesBaseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [self sendServicesRequest:request additionalParameters:@{@"filter[certificateType]": @"IOS_DEVELOPMENT"} session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        NSArray *certificates = [self processResponse:responseDictionary parseHandler:^id {
            NSArray *array = responseDictionary[@"data"];
            if (array == nil)
            {
                return nil;
            }
            
            NSMutableArray *certificates = [NSMutableArray array];
            for (NSDictionary *dictionary in array)
            {
                SIDECertificate *certificate = [[SIDECertificate alloc] initWithResponseDictionary:dictionary];
                if (certificate == nil)
                {
                    return nil;
                }
                
                [certificates addObject:certificate];
            }
            return certificates;
        } resultCodeHandler:nil error:&error];
        
        completionHandler(certificates, error);
    }];
}

- (void)addCertificateWithMachineName:(NSString *)machineName toTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(SIDECertificate * _Nullable, NSError * _Nullable))completionHandler
{
    SIDECertificateRequest *request = [[SIDECertificateRequest alloc] init];
    if (request == nil)
    {
        NSError *error = [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidCertificateRequest userInfo:nil];
        completionHandler(nil, error);
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:@"ios/submitDevelopmentCSR.action" relativeToURL:self.baseURL];
    NSString *encodedCSR = [[NSString alloc] initWithData:request.data encoding:NSUTF8StringEncoding];
    
    [self sendRequestWithURL:URL additionalParameters:@{@"csrContent": encodedCSR,
                                                        @"machineId": [[NSUUID UUID] UUIDString],
                                                        @"machineName": machineName}
                     session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
                         if (responseDictionary == nil)
                         {
                             completionHandler(nil, requestError);
                             return;
                         }
                         
                         NSError *error = nil;
                         SIDECertificate *certificate = [self processResponse:responseDictionary parseHandler:^id _Nullable{
                             NSDictionary *dictionary = responseDictionary[@"certRequest"];
                             if (dictionary == nil)
                             {
                                 return nil;
                             }
                             
                             SIDECertificate *certificate = [[SIDECertificate alloc] initWithResponseDictionary:dictionary];
                             certificate.privateKey = request.privateKey;
                             return certificate;
                         } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
                             switch (resultCode)
                             {
                                 case 3250:
                                     return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidCertificateRequest userInfo:nil];
                                     
                                 default: return nil;
                             }
                         } error:&error];
                         
                         completionHandler(certificate, error);
                     }];
}

- (void)revokeCertificate:(SIDECertificate *)certificate forTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(BOOL, NSError * _Nullable))completionHandler
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"certificates/%@", certificate.identifier] relativeToURL:self.servicesBaseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"DELETE";
    
    [self sendServicesRequest:request additionalParameters:nil session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(NO, requestError);
            return;
        }
        
        NSError *error = nil;
        id result = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            return responseDictionary;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 7252: return nil;
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorCertificateDoesNotExist userInfo:nil];
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(result != nil, error);
    }];
}

#pragma mark - App IDs -

- (void)fetchAppIDsForTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(NSArray<SIDEAppID *> * _Nullable, NSError * _Nullable))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/listAppIds.action" relativeToURL:self.baseURL];
    
    [self sendRequestWithURL:URL additionalParameters:nil session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        NSArray *appIDs = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSArray *array = responseDictionary[@"appIds"];
            if (array == nil)
            {
                return nil;
            }
            
            NSMutableArray *appIDs = [NSMutableArray array];
            for (NSDictionary *dictionary in array)
            {
                SIDEAppID *appID = [[SIDEAppID alloc] initWithResponseDictionary:dictionary];
                if (appID == nil)
                {
                    return nil;
                }
                
                [appIDs addObject:appID];
            }
            return appIDs;
        } resultCodeHandler:nil error:&error];
        
        completionHandler(appIDs, error);
    }];
}

- (void)addAppIDWithName:(NSString *)name bundleIdentifier:(NSString *)bundleIdentifier team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
       completionHandler:(void (^)(SIDEAppID *_Nullable appID, NSError *_Nullable error))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/addAppId.action" relativeToURL:self.baseURL];
    
    NSMutableCharacterSet *allowedCharacters = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowedCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *sanitizedName = [name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:nil];
    sanitizedName = [[sanitizedName componentsSeparatedByCharactersInSet:[allowedCharacters invertedSet]] componentsJoinedByString:@""];
    
    [self sendRequestWithURL:URL additionalParameters:@{@"identifier": bundleIdentifier, @"name": sanitizedName} session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        SIDEAppID *appID = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSDictionary *dictionary = responseDictionary[@"appId"];
            if (dictionary == nil)
            {
                return nil;
            }
            
            SIDEAppID *appID = [[SIDEAppID alloc] initWithResponseDictionary:dictionary];
            return appID;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 35:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidAppIDName userInfo:nil];
                    
                case 9120:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorMaximumAppIDLimitReached userInfo:nil];
                    
                case 9401:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorBundleIdentifierUnavailable userInfo:nil];
                    
                case 9412:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidBundleIdentifier userInfo:nil];
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(appID, error);
    }];
}

- (void)updateAppID:(SIDEAppID *)appID team:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(SIDEAppID * _Nullable, NSError * _Nullable))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/updateAppId.action" relativeToURL:self.baseURL];
    
    NSMutableDictionary *parameters = [@{@"appIdId": appID.identifier} mutableCopy];
    
    for (SIDEFeature feature in appID.features)
    {
        parameters[feature] = appID.features[feature];
    }
    
    [self sendRequestWithURL:URL additionalParameters:parameters
                     session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        SIDEAppID *appID = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSDictionary *dictionary = responseDictionary[@"appId"];
            if (dictionary == nil)
            {
                return nil;
            }
            
            SIDEAppID *appID = [[SIDEAppID alloc] initWithResponseDictionary:dictionary];
            return appID;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 35:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidAppIDName userInfo:nil];
                    
                case 9100:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorAppIDDoesNotExist userInfo:nil];
                    
                case 9412:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidBundleIdentifier userInfo:nil];
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(appID, error);
    }];
}

- (void)deleteAppID:(SIDEAppID *)appID forTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(BOOL, NSError * _Nullable))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/deleteAppId.action" relativeToURL:self.baseURL];
    
    [self sendRequestWithURL:URL additionalParameters:@{@"appIdId": appID.identifier} session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(NO, requestError);
            return;
        }
        
        NSError *error = nil;
        id value = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSNumber *result = responseDictionary[@"resultCode"];
            return [result integerValue] == 0 ? result : nil;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 9100:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorAppIDDoesNotExist userInfo:nil];
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(value != nil, error);
    }];
}

#pragma mark - App Groups -

- (void)fetchAppGroupsForTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(NSArray<SIDEAppGroup *> *_Nullable appIDs, NSError *_Nullable error))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/listApplicationGroups.action" relativeToURL:self.baseURL];
    
    [self sendRequestWithURL:URL additionalParameters:nil session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        NSArray *groups = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSArray *array = responseDictionary[@"applicationGroupList"];
            if (array == nil)
            {
                return nil;
            }
            
            NSMutableArray *groups = [NSMutableArray array];
            for (NSDictionary *dictionary in array)
            {
                SIDEAppGroup *group = [[SIDEAppGroup alloc] initWithResponseDictionary:dictionary];
                if (group == nil)
                {
                    return nil;
                }
                
                [groups addObject:group];
            }
            return groups;
        } resultCodeHandler:nil error:&error];
        
        completionHandler(groups, error);
    }];
}

- (void)addAppGroupWithName:(NSString *)name groupIdentifier:(NSString *)groupIdentifier team:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(SIDEAppGroup * _Nullable, NSError * _Nullable))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/addApplicationGroup.action" relativeToURL:self.baseURL];
    
    [self sendRequestWithURL:URL additionalParameters:@{@"identifier": groupIdentifier, @"name": name} session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        SIDEAppGroup *group = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSDictionary *dictionary = responseDictionary[@"applicationGroup"];
            if (dictionary == nil)
            {
                return nil;
            }
            
            SIDEAppGroup *group = [[SIDEAppGroup alloc] initWithResponseDictionary:dictionary];
            return group;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 35:
                    // Doesn't distinguish between different validation failures via resultCode unfortunately.
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidAppGroup userInfo:nil];
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(group, error);
    }];
}

- (void)assignAppID:(SIDEAppID *)appID toGroups:(NSArray<SIDEAppGroup *> *)groups team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
  completionHandler:(void (^)(BOOL success, NSError *_Nullable error))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/assignApplicationGroupToAppId.action" relativeToURL:self.baseURL];
    
    NSMutableArray *groupIDs = [NSMutableArray arrayWithCapacity:groups.count];
    for (SIDEAppGroup *group in groups)
    {
        [groupIDs addObject:group.identifier];
    }
    
    [self sendRequestWithURL:URL additionalParameters:@{@"appIdId": appID.identifier, @"applicationGroups": groupIDs}
                     session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(NO, requestError);
            return;
        }
        
        NSError *error = nil;
        id value = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSNumber *result = responseDictionary[@"resultCode"];
            return [result integerValue] == 0 ? result : nil;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 9115:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorAppIDDoesNotExist userInfo:nil];
                    
                case 35:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorAppGroupDoesNotExist userInfo:nil];
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(value != nil, error);
    }];
}

#pragma mark - Provisioning Profiles -

- (void)fetchProvisioningProfileForAppID:(SIDEAppID *)appID deviceType:(SIDEDeviceType)deviceType team:(SIDETeam *)team session:(SIDEAppleAPISession *)session
                       completionHandler:(void (^)(SIDEProvisioningProfile *_Nullable provisioningProfile, NSError *_Nullable error))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/downloadTeamProvisioningProfile.action" relativeToURL:self.baseURL];
    
    NSMutableDictionary *parameters = [@{
        @"appIdId": appID.identifier,
    } mutableCopy];
    
    switch (deviceType)
    {
        case SIDEDeviceTypeiPhone:
        case SIDEDeviceTypeiPad:
            parameters[@"DTDK_Platform"] = @"ios";
            break;
            
        case SIDEDeviceTypeAppleTV:
            parameters[@"DTDK_Platform"] = @"tvos";
            parameters[@"subPlatform"] = @"tvOS";
            break;
            
        default: break;
    }
    
    [self sendRequestWithURL:URL additionalParameters:parameters session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(nil, requestError);
            return;
        }
        
        NSError *error = nil;
        SIDEProvisioningProfile *provisioningProfile = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSDictionary *dictionary = responseDictionary[@"provisioningProfile"];
            if (dictionary == nil)
            {
                return nil;
            }
            
            SIDEProvisioningProfile *provisioningProfile = [[SIDEProvisioningProfile alloc] initWithResponseDictionary:dictionary];
            return provisioningProfile;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 8201:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorAppIDDoesNotExist userInfo:nil];
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(provisioningProfile, error);
    }];
}

- (void)deleteProvisioningProfile:(SIDEProvisioningProfile *)provisioningProfile forTeam:(SIDETeam *)team session:(SIDEAppleAPISession *)session completionHandler:(void (^)(BOOL, NSError * _Nullable))completionHandler
{
    NSURL *URL = [NSURL URLWithString:@"ios/deleteProvisioningProfile.action" relativeToURL:self.baseURL];
    
    [self sendRequestWithURL:URL additionalParameters:@{@"provisioningProfileId": provisioningProfile.identifier,
                                                        @"teamId": team.identifier}
                     session:session team:team completionHandler:^(NSDictionary *responseDictionary, NSError *requestError) {
        if (responseDictionary == nil)
        {
            completionHandler(NO, requestError);
            return;
        }
        
        NSError *error = nil;
        id value = [self processResponse:responseDictionary parseHandler:^id _Nullable{
            NSNumber *result = responseDictionary[@"resultCode"];
            return [result integerValue] == 0 ? result : nil;
        } resultCodeHandler:^NSError * _Nullable(NSInteger resultCode) {
            switch (resultCode)
            {
                case 35:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidProvisioningProfileIdentifier userInfo:nil];
                    
                case 8101:
                    return [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorProvisioningProfileDoesNotExist userInfo:nil];
                    
                default: return nil;
            }
        } error:&error];
        
        completionHandler(value != nil, error);
    }];
}

#pragma mark - Requests -

- (void)sendRequestWithURL:(NSURL *)requestURL additionalParameters:(nullable NSDictionary *)additionalParameters session:(SIDEAppleAPISession *)session team:(nullable SIDETeam *)team completionHandler:(void (^)(NSDictionary *responseDictionary, NSError *error))completionHandler
{
    NSMutableDictionary<NSString *, NSString *> *parameters = [@{
                                                                 @"clientId": SIDEClientID,
                                                                 @"protocolVersion": SIDEProtocolVersion,
                                                                 @"requestId": [[[NSUUID UUID] UUIDString] uppercaseString],
                                                                 } mutableCopy];
    
    if (team != nil)
    {
        parameters[@"teamId"] = team.identifier;
    }
    
    [additionalParameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        parameters[key] = value;
    }];
    
    NSError *serializationError = nil;
    NSData *bodyData = [NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&serializationError];
    if (bodyData == nil)
    {
        NSError *error = [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidParameters userInfo:@{NSUnderlyingErrorKey: serializationError}];
        completionHandler(nil, error);
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?clientId=%@", requestURL.absoluteString, SIDEClientID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    
    NSDictionary<NSString *, NSString *> *httpHeaders = @{
        @"Content-Type": @"text/x-xml-plist",
        @"User-Agent": @"Xcode",
        @"Accept": @"text/x-xml-plist",
        @"Accept-Language": @"en-us",
        @"X-Apple-App-Info": @"com.apple.gs.xcode.auth",
        @"X-Xcode-Version": @"11.2 (11B41)",
        @"X-Apple-I-Identity-Id": session.dsid,
        @"X-Apple-GS-Token": session.authToken,
        @"X-Apple-I-MD-M": session.anisetteData.machineID,
        @"X-Apple-I-MD": session.anisetteData.oneTimePassword,
        @"X-Apple-I-MD-LU": session.anisetteData.localUserID,
        @"X-Apple-I-MD-RINFO": [@(session.anisetteData.routingInfo) description],
        @"X-Mme-Device-Id": session.anisetteData.deviceUniqueIdentifier,
        @"X-MMe-Client-Info": session.anisetteData.deviceDescription,
        @"X-Apple-I-Client-Time": [self.dateFormatter stringFromDate:session.anisetteData.date],
        @"X-Apple-Locale": session.anisetteData.locale.localeIdentifier,
        @"X-Apple-I-Locale": session.anisetteData.locale.localeIdentifier,
        @"X-Apple-I-TimeZone": session.anisetteData.timeZone.abbreviation
    };
    
    [httpHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil)
        {
            completionHandler(nil, error);
            return;
        }
        
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:&parseError];
        
        if (responseDictionary == nil)
        {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSUnderlyingErrorKey: parseError}];
            completionHandler(nil, error);
            return;
        }
        
        completionHandler(responseDictionary, nil);
    }];
    
    [dataTask resume];
}

- (void)sendServicesRequest:(NSURLRequest *)originalRequest additionalParameters:(nullable NSDictionary *)additionalParameters session:(SIDEAppleAPISession *)session team:(SIDETeam *)team completionHandler:(void (^)(NSDictionary *responseDictionary, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [originalRequest mutableCopy];
    
    NSMutableArray<NSURLQueryItem *> *queryItems = [@[[NSURLQueryItem queryItemWithName:@"teamId" value:team.identifier]] mutableCopy];
    [additionalParameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value]];
    }];
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.queryItems = queryItems;
    
    NSString *queryString = components.query ?: @"";
    
    NSError *serializationError = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:@{@"urlEncodedQueryParams": queryString} options:0 error:&serializationError];
    if (bodyData == nil)
    {
        NSError *error = [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorInvalidParameters userInfo:@{NSUnderlyingErrorKey: serializationError}];
        completionHandler(nil, error);
        return;
    }
        
    request.HTTPBody = bodyData;
    
    NSString *HTTPMethodOverride = request.HTTPMethod;
    request.HTTPMethod = @"POST";
    
    NSDictionary<NSString *, NSString *> *httpHeaders = @{
        @"Content-Type": @"application/vnd.api+json",
        @"User-Agent": @"Xcode",
        @"Accept": @"application/vnd.api+json",
        @"Accept-Language": @"en-us",
        @"X-Apple-App-Info": @"com.apple.gs.xcode.auth",
        @"X-Xcode-Version": @"11.2 (11B41)",
        @"X-HTTP-Method-Override": HTTPMethodOverride,
        @"X-Apple-I-Identity-Id": session.dsid,
        @"X-Apple-GS-Token": session.authToken,
        @"X-Apple-I-MD-M": session.anisetteData.machineID,
        @"X-Apple-I-MD": session.anisetteData.oneTimePassword,
        @"X-Apple-I-MD-LU": session.anisetteData.localUserID,
        @"X-Apple-I-MD-RINFO": [@(session.anisetteData.routingInfo) description],
        @"X-Mme-Device-Id": session.anisetteData.deviceUniqueIdentifier,
        @"X-MMe-Client-Info": session.anisetteData.deviceDescription,
        @"X-Apple-I-Client-Time": [self.dateFormatter stringFromDate:session.anisetteData.date],
        @"X-Apple-Locale": session.anisetteData.locale.localeIdentifier,
        @"X-Apple-I-TimeZone": session.anisetteData.timeZone.abbreviation
    };
    
    [httpHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil)
        {
            completionHandler(nil, error);
            return;
        }
        
        NSDictionary *responseDictionary = nil;
        
        if (data.length == 0)
        {
            responseDictionary = @{};
        }
        else
        {
            NSError *parseError = nil;
            responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            
            if (responseDictionary == nil)
            {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSUnderlyingErrorKey: parseError}];
                completionHandler(nil, error);
                return;
            }
        }        
        
        completionHandler(responseDictionary, nil);
    }];
    
    [dataTask resume];
}

- (nullable id)processResponse:(NSDictionary *)responseDictionary
                         parseHandler:(id _Nullable (^_Nullable)(void))parseHandler
                    resultCodeHandler:(NSError *_Nullable (^_Nullable)(NSInteger resultCode))resultCodeHandler
                         error:(NSError **)error
{
    if (parseHandler != nil)
    {
        id value = parseHandler();
        if (value != nil)
        {
            return value;
        }
    }
    
    id result = responseDictionary[@"resultCode"];
    if (result == nil)
    {
        *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil];
        return nil;
    }
    
    NSInteger resultCode = [result integerValue]; // Works wether result is NSNumber or NSString.
    if (resultCode == 0)
    {
        return nil;
    }
    else
    {
        NSError *tempError = nil;
        if (resultCodeHandler)
        {
            tempError = resultCodeHandler(resultCode);
        }
        
        if (tempError == nil)
        {
            NSString *errorDescription = [responseDictionary objectForKey:@"userString"] ?: [responseDictionary objectForKey:@"resultString"];
            NSString *localizedDescription = [NSString stringWithFormat:@"%@ (%@)", errorDescription, @(resultCode)];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[NSLocalizedDescriptionKey] = localizedDescription;
            tempError = [NSError errorWithDomain:SIDEAppleAPIErrorDomain code:SIDEAppleAPIErrorUnknown userInfo:userInfo];
        }
        
        *error = tempError;
        
        return nil;
    }
}

@end
