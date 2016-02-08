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

@interface MPin : NSObject

+ (void)initSDK;
+ (MpinStatus*)TestBackend:(const NSString*)url;
+ (MpinStatus*)SetBackend:(const NSString*)url;
+ (MpinStatus*)TestBackend:(const NSString*)url rpsPrefix:(NSString*)rpsPrefix;
+ (MpinStatus*)SetBackend:(const NSString*)url rpsPrefix:(NSString*)rpsPrefix;

+ (id<IUser>)MakeNewUser:(const NSString*)identity;
+ (id<IUser>)MakeNewUser:(const NSString*)identity
              deviceName:(const NSString*)devName;

+ (MpinStatus*)StartRegistration:(const id<IUser>)user;
+ (MpinStatus*)RestartRegistration:(const id<IUser>)user;
+ (MpinStatus*)StartRegistration:(const id<IUser>)user userData:(NSString *) userData;
+ (MpinStatus*)RestartRegistration:(const id<IUser>)user userData:(NSString *) userData;
+ (MpinStatus*) VerifyUser:(const id<IUser>)user mpinId:(NSString* ) mpinId activationKey:(NSString *) activationKey;
+ (MpinStatus*) ConfirmRegistration:(const id<IUser>)user;
+ (MpinStatus*) ConfirmRegistration:(const id<IUser>)user  pushNotificationIdentifier:(NSString *) pushNotificationIdentifier;
+ (MpinStatus*)FinishRegistration:(const id<IUser>)user pin:(NSString *) pin;

+ (MpinStatus*) StartAuthentication:(const id<IUser>)user;
+ (MpinStatus*) CheckAccessNumber:(NSString *)an;
+ (MpinStatus*)FinishAuthentication:(const id<IUser>)user pin:(NSString *) pin;
+ (MpinStatus*)FinishAuthentication:(const id<IUser>)user pin:(NSString *) pin authResultData:(NSString **)authResultData;
+ (MpinStatus*)FinishAuthenticationOTP:(id<IUser>)user pin:(NSString *) pin otp:(OTP**)otp;
+ (MpinStatus*)FinishAuthenticationAN:(id<IUser>)user pin:(NSString *) pin accessNumber:(NSString *)an;

+ (Boolean)Logout:(const id<IUser>)user;
+ (Boolean)CanLogout:(const id<IUser>)user;

+ (NSMutableArray*)listUsers;
+ ( id<IUser> ) getIUserById:(NSString *) userId;
+ (void) DeleteUser:(const id<IUser>)user;

+ (NSString *) GetClientParam:(const NSString *) key;

/// TEMPORARY FIX
+ (NSString*)getRPSUrl;

@end
