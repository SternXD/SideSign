//
//  SIDETeam.h
//  SideSign
//
//  Created by Riley Testut on 5/10/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SIDEAccount;

typedef NS_ENUM(int16_t, SIDETeamType)
{
    SIDETeamTypeUnknown = 0,
    SIDETeamTypeFree = 1,
    SIDETeamTypeIndividual = 2,
    SIDETeamTypeOrganization = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface SIDETeam : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic) SIDETeamType type;

@property (nonatomic) SIDEAccount *account;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name identifier:(NSString *)identifier type:(SIDETeamType)type account:(SIDEAccount *)account NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
