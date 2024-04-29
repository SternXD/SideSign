//
//  SIDEAppID.h
//  SideSign
//
//  Created by Riley Testut on 5/21/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SIDECapabilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface SIDEAppID : NSObject <NSCopying>

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *bundleIdentifier;
@property (copy, nonatomic, nullable) NSDate *expirationDate;

@property (copy, nonatomic) NSDictionary<SIDEFeature, id> *features;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name identifier:(NSString *)identifier bundleIdentifier:(NSString *)bundleIdentifier expirationDate:(nullable NSDate *)expirationDate features:(NSDictionary<SIDEFeature, id> *)features NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
