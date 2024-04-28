//
//  SIDEModel+Internal.h
//  AltSign
//
//  Created by Riley Testut on 5/28/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <AltSign/SIDEAccount.h>
#import <AltSign/SIDETeam.h>
#import <AltSign/SIDEDevice.h>
#import <AltSign/SIDECertificate.h>
#import <AltSign/SIDECertificateRequest.h>
#import <AltSign/SIDEAppID.h>
#import <AltSign/SIDEAppGroup.h>
#import <AltSign/SIDEProvisioningProfile.h>

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
