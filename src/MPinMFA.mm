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

typedef MPinSDK::UserPtr        UserPtr;
typedef MPinSDK::Status         Status;
typedef sdk_non_tee::Context    Context;
typedef MPinSDK::Signature      Signature;

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

+ (bool) isRegistrationTokenSet:(const id<IUser>)user
{
    return mpin.IsRegistrationTokenSet([((User *) user) getUserPtr]);
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

+ (Boolean) IsUserExisting:(NSString *) identity customerId:(NSString *) customerId appId:(NSString *) appId {
    [lock lock];
    Boolean b = mpin.IsUserExisting([identity UTF8String], [customerId UTF8String], [appId UTF8String]);
    [lock unlock];
    return b;
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

+ (MpinStatus*) GetAccessCode:(NSString *) authzUrl accessCode:(NSString **)ac {
    MPinSDK::String c_ac;
    [lock lock];
    Status s = mpin.GetAccessCode([authzUrl UTF8String], c_ac);
    [lock unlock];
    *ac = [NSString stringWithUTF8String:c_ac.c_str()];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) StartRegistration:(const id<IUser>)user accessCode:(NSString *) accessCode pmi:(NSString *) pmi {
    [lock lock];
    Status s = mpin.StartRegistration([((User *) user) getUserPtr], [accessCode UTF8String], [pmi UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) SetRegistrationToken:(const id<IUser>)user token:(NSString *) token
{
    [lock lock];
    Status s = mpin.SetRegistrationToken([((User *) user) getUserPtr], [token UTF8String]);
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


+ (MpinStatus*) FinishRegistration:(const id<IUser>)user pin0:(NSString *) pin0 pin1:(NSString *) pin1 {
    [lock lock];
    MPinSDK::MultiFactor c_multiFactor = MPinSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.FinishRegistration([((User *) user) getUserPtr], c_multiFactor);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) StartAuthentication:(const id<IUser>)user accessCode:(NSString *) accessCode {
    [lock lock];
    Status s = mpin.StartAuthentication([((User *) user) getUserPtr], [accessCode UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus *) FinishAuthentication:(id<IUser>) user pin0:(NSString *) pin0  pin1:(NSString *) pin1  accessCode:(NSString *) ac {
    [lock lock];
    MPinSDK::MultiFactor c_multiFactor = MPinSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.FinishAuthentication([((User *) user) getUserPtr], c_multiFactor, [ac UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*)FinishAuthentication:(const id<IUser>)user pin:(NSString *) pin0 pin1:(NSString *) pin1 accessCode:(NSString *)ac authzCode:(NSString **)authzCode {
    MPinSDK::String c_authzCode;
    [lock lock];
    MPinSDK::MultiFactor c_multiFactor = MPinSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.FinishAuthentication([((User *) user) getUserPtr], c_multiFactor, [ac UTF8String] , c_authzCode);
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


+ ( BOOL ) VerifyDocument:(NSString *) strDoc hash:(NSData *) hash
{
    const char *byteArray = (char  * )[hash bytes];
    String cStrHash ( byteArray, hash.length );
    BOOL bResult = mpin.VerifyDocumentHash([strDoc UTF8String], cStrHash);
    return bResult;
}

+ (MpinStatus*) Sign: (id<IUser>)user
        documentHash:(NSData *)hash
                pin0: (NSString *) pin0
                pin1: (NSString *) pin1
           epochTime: (double) epochTime
          authZToken: (NSString *) authZToken
              result: (BridgeSignature **)result
{
    
    MPinSDK::MultiFactor c_multiFactor = MPinSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    MPinSDK::Signature   signResult;
    
    String cStrHash ( ((char  * )[hash bytes]), hash.length );
    
    Status status = mpin.Sign([((User *) user) getUserPtr], cStrHash, c_multiFactor, epochTime, [authZToken UTF8String], signResult);

    NSMutableData *cHash = [[NSMutableData alloc] init];
    NSMutableData *cU = [[NSMutableData alloc] init];
    NSMutableData *cV = [[NSMutableData alloc] init];
    NSMutableData *cPublicKey = [[NSMutableData alloc] init];
    NSMutableData *cMPinID = [[NSMutableData alloc] init];
    
    [cHash appendBytes:signResult.hash.data() length:signResult.hash.length()];
    [cU appendBytes:signResult.u.data() length:signResult.u.length()];
    [cV appendBytes:signResult.v.data() length:signResult.v.length()];
    [cPublicKey appendBytes:signResult.publicKey.data() length:signResult.publicKey.length()];
    [cMPinID appendBytes:signResult.mpinId.data() length:signResult.mpinId.length()];
    
    NSString *strHash = [NSString stringWithCString:signResult.hash.c_str()
                                           encoding:[NSString defaultCStringEncoding]];
    NSLog(strHash);
    
    NSString *strU = [NSString stringWithCString:signResult.u.c_str()
                                           encoding:[NSString defaultCStringEncoding]];
    NSLog(strU);
    
    NSString *strV = [NSString stringWithCString:signResult.v.c_str()
                                        encoding:[NSString defaultCStringEncoding]];
    NSLog(strV);
    
    NSString *strPublicKey = [NSString stringWithCString:signResult.publicKey.c_str()
                                                encoding:[NSString defaultCStringEncoding]];
    NSLog(strPublicKey);
    
    *result = [[BridgeSignature alloc] initWith:cHash
                                         mpinId:cMPinID
                                           strU:cU
                                           strV:cV
                                   strPublicKey:cPublicKey
               ];

    return [[MpinStatus alloc] initWith:(MPinStatus)status.GetStatusCode() errorMessage:[NSString stringWithUTF8String:status.GetErrorMessage().c_str()]];
}

#pragma mark - DVS Second PIN -

+ (MpinStatus*) StartRegistrationDVS:(const id<IUser>)user
                               token:(NSString *) token
{
    [lock lock];
    Status s = mpin.StartRegistrationDVS([((User *) user) getUserPtr], [token UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) FinishRegistrationDVS:(const id<IUser>)user
                               pinDVS:(NSString *) pinDVS
                                  nfc:(NSString *) nfc
{
    
    [lock lock];
    MPinSDK::MultiFactor c_multiFactor = MPinSDK::MultiFactor([pinDVS UTF8String]);
    if ( nfc != nil )
    {
        c_multiFactor.push_back([nfc UTF8String]);
    }
    Status s = mpin.FinishRegistrationDVS([((User *) user) getUserPtr], c_multiFactor);
    [lock unlock];
    
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];

}

+ (MpinStatus*) StartAuthenticationOTP:(const id<IUser>)user {
    [lock lock];
    Status s = mpin.StartAuthenticationOTP([((User *) user) getUserPtr]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) FinishAuthenticationOTP:(const id<IUser>)user pin:(NSString *) pin otp:(OTP**)otp {
    MPinSDK::OTP c_otp;
    [lock lock];
    Status s = mpin.FinishAuthenticationOTP([((User *) user) getUserPtr], [pin UTF8String], c_otp);
    [lock unlock];
    *otp = [[OTP alloc] initWith:[[MpinStatus alloc] initWith:(MPinStatus)c_otp.status.GetStatusCode() errorMessage:[NSString stringWithUTF8String:c_otp.status.GetErrorMessage().c_str()]]
                             otp:[NSString stringWithUTF8String:c_otp.otp.c_str()]
                      expireTime:c_otp.expireTime
                      ttlSeconds:c_otp.ttlSeconds
                         nowTime:c_otp.nowTime];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

#pragma mark - RegCode -

+ (MpinStatus*) StartRegistration:(const id<IUser>)user accessCode:(NSString *) accessCode regCode:(NSString *) regCode pmi:(NSString *) pmi{
    [lock lock];
    Status s = mpin.StartRegistration([((User *) user) getUserPtr], [accessCode UTF8String], [pmi UTF8String], [regCode UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) StartAuthenticationRegCode:(const id<IUser>)user{
    [lock lock];
    Status s = mpin.StartAuthenticationRegCode([((User *) user) getUserPtr]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*)FinishAuthenticationRegCode:(const id<IUser>)user pin:(NSString *) pin0 pin1:(NSString *) pin1 regCode:(RegCode **)regCode{
    [lock lock];
    MPinSDK::RegCode     c_regCode = MPinSDK::RegCode();
    MPinSDK::MultiFactor c_multiFactor = MPinSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.FinishAuthenticationRegCode([((User *) user) getUserPtr], c_multiFactor, c_regCode);
    *regCode = [[RegCode alloc] initWith:[[MpinStatus alloc] initWith:(MPinStatus)c_regCode.status.GetStatusCode() errorMessage:[NSString stringWithUTF8String:c_regCode.status.GetErrorMessage().c_str()]]
                                        otp:[NSString stringWithUTF8String:c_regCode.otp.c_str()]
                                 expireTime:c_regCode.expireTime
                                 ttlSeconds:c_regCode.ttlSeconds
                                    nowTime:c_regCode.nowTime];
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

@end


