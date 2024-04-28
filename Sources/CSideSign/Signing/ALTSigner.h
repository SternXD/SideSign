//
//  SIDESigner.h
//  AltSign
//
//  Created by Riley Testut on 5/22/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SIDEAppID;
@class SIDETeam;
@class SIDECertificate;
@class SIDEProvisioningProfile;

NS_ASSUME_NONNULL_BEGIN

@interface SIDESigner : NSObject

@property (nonatomic) SIDETeam *team;
@property (nonatomic) SIDECertificate *certificate;

- (instancetype)initWithTeam:(SIDETeam *)team certificate:(SIDECertificate *)certificate;

- (NSProgress *)signAppAtURL:(NSURL *)appURL provisioningProfiles:(NSArray<SIDEProvisioningProfile *> *)profiles completionHandler:(void (^)(BOOL success, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
