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

#import "User.h"

@interface User() {
    UserPtr userPtr;
}

@end

@implementation User

- (id) initWith:(UserPtr) usrPtr {
    self = [super init];
    if (self) {
        userPtr = usrPtr;
    }
    return self;
}

-(NSString *) getIdentity {
    return [NSString stringWithUTF8String:userPtr->GetId().c_str()];
}

-(UserState) getState {
    return (UserState)userPtr->GetState();
}

-(UserPtr) getUserPtr {
    return userPtr;
}

- (NSString*) getBackend {
    return [NSString stringWithUTF8String:userPtr->GetBackend().c_str()];
}
- (NSString*) GetCustomerId {
    return [NSString stringWithUTF8String:userPtr->GetCustomerId().c_str()];
}
- (NSString*) GetAppId {
    return [NSString stringWithUTF8String:userPtr->GetAppId().c_str()];
}
- (NSString*) GetMPinId  {
    return [NSString stringWithUTF8String:userPtr->GetMPinId().c_str()];
}

- (Expiration*) GetRegistrationExpiration {
    return [[Expiration alloc] initWith:userPtr->GetRegistrationExpiration().nowTimeSeconds expireTime:userPtr->GetRegistrationExpiration().expireTimeSeconds];
}

@end
