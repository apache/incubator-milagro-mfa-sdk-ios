/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Foundation/Foundation.h>
#import "IUser.h"
#import "MpinStatus.h"
#import "OTP.h"
#import "SessionDetails.h"
#import "ServiceDetails.h"

#ifndef CLEAR_USERS_NOTIFICATION
#define CLEAR_USERS_NOTIFICATION @"ClearAllUsers"
#endif

@interface MPinMFA : NSObject

+ (void) initSDK;
+ (void) initSDKWithHeaders:(NSDictionary *)dictHeaders;
+ (void) Destroy;
+ (void) AddCustomHeaders:(NSDictionary *)dictHeaders;
+ (void) ClearCustomHeaders;

+ (void) AddTrustedDomain:(NSString *) domain;
+ (void) ClearTrustedDomains;

+ (MpinStatus*) TestBackend:(const NSString*)url;
+ (MpinStatus*) SetBackend:(const NSString*)url;
+ (MpinStatus*) TestBackend:(const NSString*)url rpsPrefix:(NSString*)rpsPrefix;
+ (MpinStatus*) SetBackend:(const NSString*)url rpsPrefix:(NSString*)rpsPrefix;

+ (id<IUser>) MakeNewUser:(const NSString*)identity;
+ (id<IUser>) MakeNewUser:(const NSString*)identity
              deviceName:(const NSString*)devName;
+ (Boolean) IsUserExisting:(NSString *) identity customerId:(NSString *) customerId appId:(NSString *) appId;
+ (void) DeleteUser:(const id<IUser>)user;
+ (void) ClearUsers;

+ (Boolean) Logout:(const id<IUser>)user;
+ (Boolean) CanLogout:(const id<IUser>)user;

+ (id<IUser>) getIUserById:(NSString *) userId;
+ (NSString *) GetClientParam:(const NSString *) key;
/// TEMPORARY FIX
+ (NSString*) getRPSUrl;

+ (MpinStatus*) GetServiceDetails:(NSString *) url serviceDetails:(ServiceDetails **)sd;
+ (void) SetClientId:(NSString *) clientId;
+ (SessionDetails*) GetSessionDetails:(NSString *) accessCode;
+ (MpinStatus*) AbortSession:(NSString *) accessCode;

+ (MpinStatus*) GetAccessCode:(NSString *) authzUrl accessCode:(NSString **)ac;

+ (MpinStatus*) StartRegistration:(const id<IUser>)user activateCode:(NSString *) activateCode pmi:(NSString *) pmi;
+ (MpinStatus*) RestartRegistration:(const id<IUser>)user;
+ (MpinStatus*) ConfirmRegistration:(const id<IUser>)user;
+ (MpinStatus*) FinishRegistration:(const id<IUser>)user pin:(NSString *) pin;
+ (MpinStatus*) StartAuthentication:(const id<IUser>)user accessCode:(NSString *) accessCode;
+ (MpinStatus*) FinishAuthentication:(id<IUser>)user pin:(NSString *) pin accessCode:(NSString *)ac;
+ (MpinStatus*) FinishAuthentication:(const id<IUser>)user pin:(NSString *) pin accessCode:(NSString *)ac authzCode:(NSString **)authzCode;
+ (MpinStatus*) StartAuthenticationOTP:(const id<IUser>)user;
+ (MpinStatus*) FinishAuthenticationOTP:(const id<IUser>)user pin:(NSString *) pin otp:(OTP**)otp;

+ (NSMutableArray*) listUsers;

@end
