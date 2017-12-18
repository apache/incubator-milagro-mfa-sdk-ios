//
//  Signature.m
//  MPinSDK
//
//  Created by Tihomir Ganev on 11/7/17.
//  Copyright © 2017 Certivox. All rights reserved.
//

#import "Signature.h"

@implementation BridgeSignature

-(id) initWith: (NSString *) strHash
        mpinId: (NSString *) strMpinId
       expTime: (NSString *) expTime
      lSeconds: (NSString *) ttlSeconds
       nowTime: (NSString *) nowTime
{
    self = [super init];
    if (self) {
        _strHash        = strHash;
        _strMpinId      = strMpinId;
        _strU           = expTime;
        _strV           = ttlSeconds;
        _strPublicKey   = nowTime;
    }
    return self;
}

@end
