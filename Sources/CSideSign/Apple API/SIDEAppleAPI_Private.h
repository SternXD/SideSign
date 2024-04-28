//
//  SIDEAppleAPI+Private.h
//  SideSign
//
//  Created by Riley Testut on 11/16/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <SideSign/SIDEAppleAPI.h>

NS_ASSUME_NONNULL_BEGIN

@interface SIDEAppleAPI ()

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) NSISO8601DateFormatter *dateFormatter;

@property (nonatomic, copy, readonly) NSURL *baseURL;
@property (nonatomic, copy, readonly) NSURL *servicesBaseURL;

- (void)sendRequestWithURL:(NSURL *)requestURL
      additionalParameters:(nullable NSDictionary *)additionalParameters
                   session:(SIDEAppleAPISession *)session
                      team:(nullable SIDETeam *)team
         completionHandler:(void (^)(NSDictionary *_Nullable responseDictionary, NSError *_Nullable error))completionHandler;

- (nullable id)processResponse:(NSDictionary *)responseDictionary
                  parseHandler:(id _Nullable (^_Nullable)(void))parseHandler
             resultCodeHandler:(NSError *_Nullable (^_Nullable)(NSInteger resultCode))resultCodeHandler
                         error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
