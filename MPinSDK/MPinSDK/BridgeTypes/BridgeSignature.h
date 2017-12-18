//
//  Signature.h
//  MPinSDK
//
//  Created by Tihomir Ganev on 11/7/17.
//  Copyright © 2017 Certivox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Signature : NSObject

@property (nonatomic, strong) NSString *strHash;
@property (nonatomic, strong) NSString *strMpinId;
@property (nonatomic, strong) NSString *strU;
@property (nonatomic, strong) NSString *strV;
@property (nonatomic, strong) NSString *strPublicKey;

@end
