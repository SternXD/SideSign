//
//  SIDEModel+Internal.h
//  SideSign
//
//  Created by Riley Testut on 5/28/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <SideSign/SIDEAccount.h>
#import <SideSign/SIDETeam.h>
#import <SideSign/SIDEDevice.h>
#import <SideSign/SIDECertificate.h>
#import <SideSign/SIDECertificateRequest.h>
#import <SideSign/SIDEAppID.h>
#import <SideSign/SIDEAppGroup.h>
#import <SideSign/SIDEProvisioningProfile.h>

NS_ASSUME_NONNULL_BEGIN

@interface SIDEAccount ()
- (nullable instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary;
@end

@interface SIDETeam ()
- (nullable instancetype)initWithAccount:(SIDEAccount *)account responseDictionary:(NSDictionary *)responseDictionary;
@end

@interface SIDEDevice ()
- (nullable instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary;
@end

@interface SIDECertificate ()
- (instancetype)initWithName:(NSString *)name serialNumber:(NSString *)serialNumber data:(nullable NSData *)data NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary;
@end

@interface SIDEAppID ()
- (nullable instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary;
@end

@interface SIDEAppGroup ()
- (nullable instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary;
@end

@interface SIDEProvisioningProfile ()
- (nullable instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary;
@end

NS_ASSUME_NONNULL_END
