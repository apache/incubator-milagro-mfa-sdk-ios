//
//  Signature.m
//  MPinSDK
//
//  Created by Tihomir Ganev on 11/7/17.
//  Copyright © 2017 Certivox. All rights reserved.
//

#import "BridgeSignature.h"

@implementation BridgeSignature

-(id) initWith: (NSData *) strHash
        mpinId: (NSData *) strMpinId
          strU: (NSData *) strU
          strV: (NSData *) strV
  strPublicKey: (NSData *) strPublicKey
{
    self = [super init];
    if (self) {
        _strHash        = strHash;
        _strMpinId      = strMpinId;
        _strU           = strU;
        _strV           = strV;
        _strPublicKey   = strPublicKey;
    }
    return self;
}

@end
