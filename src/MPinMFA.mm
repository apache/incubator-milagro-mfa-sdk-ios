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

#import "MPinMFA.h"
#import "mfa_sdk.h"
#import "Context.h"
#import <vector>
#import "User.h"

static MfaSDK mpin;
static BOOL isInitialized = false;

/// TEMPORARY FIX
static NSString * rpsURL;
static NSLock * lock = [[NSLock alloc] init];

typedef MPinSDK::UserPtr UserPtr;
typedef MPinSDK::Status Status;
typedef sdk_non_tee::Context Context;

@implementation MPinMFA

/// TEMPORARY FIX
+ (NSString*) getRPSUrl {
    return rpsURL;
}

+ (void) initSDK {
    if (isInitialized) return;
    [lock lock];
    mpin.Init(StringMap(), sdk_non_tee::Context::Instance());
    isInitialized = true;
    [lock unlock];
}

+ (void) initSDKWithHeaders:(NSDictionary *)dictHeaders{
    if (isInitialized) return;
    [lock lock];
    mpin.Init(StringMap(), sdk_non_tee::Context::Instance());
    isInitialized = true;
    [lock unlock];
    [MPinMFA AddCustomHeaders:dictHeaders];
}

+ (void) Destroy {
    [lock lock];
    mpin.Destroy();
    isInitialized = false;
    [lock unlock];
}

+ (void) ClearUsers {
    [lock lock];
    mpin.ClearUsers();
    [lock unlock];
}

+ (void) AddCustomHeaders:(NSDictionary *)dictHeaders {
    if(dictHeaders == nil) return;
    StringMap sm_CustomHeaders;
    for( id headerName in dictHeaders)
    {
        sm_CustomHeaders.Put( [headerName UTF8String], [dictHeaders[headerName] UTF8String] );
    }
    [lock lock];
    mpin.AddCustomHeaders(sm_CustomHeaders);
    [lock unlock];
}

+ (void) ClearCustomHeaders {
    [lock lock];
    mpin.ClearCustomHeaders();
    [lock unlock];
}

+ (void) AddTrustedDomain:(NSString *) domain {
    [lock lock];
    mpin.AddTrustedDomain( (domain == nil)?(""):([domain UTF8String]));
    [lock unlock];
}

+ (void) ClearTrustedDomains {
    [lock lock];
    mpin.ClearTrustedDomains();
    [lock unlock];
}

+ (MpinStatus*) TestBackend:(const NSString * ) url {
    [lock lock];
    Status s = mpin.TestBackend((url == nil)?(""):([url UTF8String]));
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) SetBackend:(const NSString * ) url {
    [lock lock];
    Status s = mpin.SetBackend((url == nil)?(""):([url UTF8String]));
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) TestBackend:(const NSString * ) url rpsPrefix:(NSString *) rpsPrefix {
    if (rpsPrefix == nil || rpsPrefix.length == 0) {
        return [MPinMFA TestBackend:url];
    }
    [lock lock];
    Status s = mpin.TestBackend([url UTF8String], [rpsPrefix UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) SetBackend:(const NSString * ) url rpsPrefix:(NSString *) rpsPrefix {
    if (rpsPrefix == nil || rpsPrefix.length == 0) {
        return [MPinMFA SetBackend:url];
    }
    [lock lock];
    Status s = mpin.SetBackend([url UTF8String],[rpsPrefix UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (Boolean) Logout:(const id<IUser>) user {
    [lock lock];
    Boolean b = mpin.Logout([((User *) user) getUserPtr]);
    [lock unlock];
    return b;
}

+ (Boolean) CanLogout:(const id<IUser>) user {
    [lock lock];
    Boolean b = mpin.CanLogout([((User *) user) getUserPtr]);
    [lock unlock];
    return b;
}

+ (NSString*) GetClientParam:(const NSString *) key {
    [lock lock];
    String value = mpin.GetClientParam([key UTF8String]);
    [lock unlock];
    return [NSString stringWithUTF8String:value.c_str()];
}

+ (id<IUser>) MakeNewUser:(const NSString *) identity {
    [lock lock];
    UserPtr userPtr = mpin.MakeNewUser([identity UTF8String]);
    [lock unlock];
    return [[User alloc] initWith:userPtr];
}

+ (id<IUser>) MakeNewUser: (const NSString *) identity deviceName:(const NSString *) devName {
    [lock lock];
    UserPtr userPtr = mpin.MakeNewUser([identity UTF8String], [devName UTF8String]);
    [lock unlock];
    return [[User alloc] initWith:userPtr];
}

+ (void) DeleteUser:(const id<IUser>) user {
    [lock lock];
    mpin.DeleteUser([((User *) user) getUserPtr]);
    [lock unlock];
}

+ (id<IUser>) getIUserById:(NSString *) userId {
    if( userId == nil ) return nil;
    if ([@"" isEqualToString:userId]) return nil;
    
    NSArray * users = [MPinMFA listUsers];
    
    for (User * user in users)
        if ( [userId isEqualToString:[user getIdentity]] )
            return user;
    
    return nil;
}

+ (void) SetClientId:(NSString *) clientId {
    [lock lock];
    mpin.SetCID([clientId UTF8String]);
    [lock unlock];
}

+ (MpinStatus*) GetServiceDetails:(NSString *) url serviceDetails:(ServiceDetails **)sd {
    MfaSDK::ServiceDetails c_sd;
    [lock lock];
    Status s = mpin.GetServiceDetails([url UTF8String], c_sd);
    [lock unlock];
    *sd = [[ServiceDetails alloc] initWith:[NSString stringWithUTF8String:c_sd.name.c_str()]
                                backendUrl:[NSString stringWithUTF8String:c_sd.backendUrl.c_str()]
                                 rpsPrefix:[NSString stringWithUTF8String:c_sd.rpsPrefix.c_str()]
                                   logoUrl:[NSString stringWithUTF8String:c_sd.logoUrl.c_str()]];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (SessionDetails*) GetSessionDetails:(NSString *) accessCode {
    [lock lock];
    MfaSDK::SessionDetails sd;
    Status s = mpin.GetSessionDetails([accessCode UTF8String] , sd);
    [lock unlock];
    
    if (s.GetStatusCode() != Status::Code::OK)
        return nil;
    
    return  [[SessionDetails alloc] initWith:[NSString stringWithUTF8String:sd.prerollId.c_str()]
                                     appName:[NSString stringWithUTF8String:sd.appName.c_str()]
                                  appIconUrl:[NSString stringWithUTF8String:sd.appIconUrl.c_str()]
                                  customerId:[NSString stringWithUTF8String:sd.customerId.c_str()]
                                customerName:[NSString stringWithUTF8String:sd.customerName.c_str()]
                             customerIconUrl:[NSString stringWithUTF8String:sd.customerIconUrl.c_str()]
             ];
}

+ (MpinStatus*) AbortSession:(NSString *) accessCode {
    [lock lock];
    Status s = mpin.AbortSession( [accessCode UTF8String] );
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) StartRegistration:(const id<IUser>)user activateCode:(NSString *) activateCode pmi:(NSString *) pmi {
    [lock lock];
    Status s = mpin.StartRegistration([((User *) user) getUserPtr], [activateCode UTF8String], [pmi UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) RestartRegistration:(const id<IUser>)user {
    [lock lock];
    Status s = mpin.RestartRegistration([((User *) user) getUserPtr]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) ConfirmRegistration:(const id<IUser>)user {
    [lock lock];
    Status s = mpin.ConfirmRegistration([((User *) user) getUserPtr]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) FinishRegistration:(const id<IUser>)user pin:(NSString *) pin {
    [lock lock];
    Status s = mpin.FinishRegistration([((User *) user) getUserPtr], [pin UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) StartAuthentication:(const id<IUser>)user accessCode:(NSString *) accessCode {
    [lock lock];
    Status s = mpin.StartAuthentication([((User *) user) getUserPtr], [accessCode UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus *) FinishAuthentication:(id<IUser>) user pin:(NSString *) pin  accessCode:(NSString *) ac {
    [lock lock];
    Status s = mpin.FinishAuthentication([((User *) user) getUserPtr], [pin UTF8String], [ac UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*)FinishAuthentication:(const id<IUser>)user pin:(NSString *) pin accessCode:(NSString *)ac authzCode:(NSString **)authzCode {
    MPinSDK::String c_authzCode;
    [lock lock];
    Status s = mpin.FinishAuthentication([((User *) user) getUserPtr], [pin UTF8String], [ac UTF8String] , c_authzCode);
    [lock unlock];
    *authzCode = [NSString stringWithUTF8String:c_authzCode.c_str()];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (NSMutableArray*) listUsers {
    NSMutableArray * users = [NSMutableArray array];
    std::vector<UserPtr> vUsers;
    mpin.ListUsers(vUsers);
    for (int i = 0; i<vUsers.size(); i++) {
        [users addObject:[[User alloc] initWith:vUsers[i]]];
    }
    return users;
}

@end
