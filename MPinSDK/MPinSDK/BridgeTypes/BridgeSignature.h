//
//  Signature.h
//  MPinSDK
//
//  Created by Tihomir Ganev on 11/7/17.
//  Copyright © 2017 Certivox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BridgeSignature : NSObject

-(id) initWith: (NSData *) strHash
        mpinId: (NSData *) strMpinId
          strU: (NSData *) strU
          strV: (NSData *) strV
  strPublicKey: (NSData *) strPublicKey;

@property (nonatomic) NSData    *strHash;
@property (nonatomic) NSData    *strMpinId;
@property (nonatomic) NSData    *strU;
@property (nonatomic) NSData    *strV;
@property (nonatomic) NSData    *strPublicKey;

@end
