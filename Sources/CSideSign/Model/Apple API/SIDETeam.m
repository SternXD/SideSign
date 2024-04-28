//
//  SIDETeam.m
//  AltSign
//
//  Created by Riley Testut on 5/10/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import "SIDETeam.h"

@implementation SIDETeam

- (instancetype)initWithName:(NSString *)name identifier:(NSString *)identifier type:(SIDETeamType)type account:(SIDEAccount *)account
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _identifier = [identifier copy];
        _type = type;
        _account = account;
    }
    
    return self;
}

- (nullable instancetype)initWithAccount:(SIDEAccount *)account responseDictionary:(NSDictionary *)responseDictionary
{
    NSString *name = responseDictionary[@"name"];
    NSString *identifier = responseDictionary[@"teamId"];
    NSString *teamType = responseDictionary[@"type"];
    
    if (name == nil || identifier == nil || teamType == nil)
    {
        return nil;
    }
    
    SIDETeamType type = SIDETeamTypeUnknown;
    
    if ([teamType isEqualToString:@"Company/Organization"])
    {
        type = SIDETeamTypeOrganization;
    }
    else if ([teamType isEqualToString:@"Individual"])
    {
        NSArray *memberships = responseDictionary[@"memberships"];
        
        NSDictionary *membership = memberships.firstObject;
        NSString *name = membership[@"name"];
        
        if (memberships.count == 1 && [name.lowercaseString containsString:@"free"])
        {
            type = SIDETeamTypeFree;
        }
        else
        {
            type = SIDETeamTypeIndividual;
        }
    }
    else
    {
        type = SIDETeamTypeUnknown;
    }
    
    self = [self initWithName:name identifier:identifier type:type account:account];
    return self;
}

#pragma mark - NSObject -

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, Name: %@>", NSStringFromClass([self class]), self, self.name];
}

- (BOOL)isEqual:(id)object
{
    SIDETeam *team = (SIDETeam *)object;
    if (![team isKindOfClass:[SIDETeam class]])
    {
        return NO;
    }
    
    BOOL isEqual = [self.identifier isEqualToString:team.identifier];
    return isEqual;
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

@end
