//
//  SIDECertificateRequest.h
//  SideSign
//
//  Created by Riley Testut on 5/21/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIDECertificateRequest : NSObject

@property (nonatomic, copy, readonly, nonnull) NSData *data;
@property (nonatomic, copy, readonly, nonnull) NSData *privateKey;

- (nullable instancetype)init;

@end
