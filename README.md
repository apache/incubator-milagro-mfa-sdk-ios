# Milagro Mobile SDK for iOS

## Building the Milagro Mobile SDK for iOS

### Prerequisites

1. Download and install Xcode 7.1 or higher
2. Download or Clone the project and its submodule

### Building the Milagro Mobile SDK

1. Navigate to `<milagro-sdk-ios>`
2. Open `MPinSDK/MPinSDK.xcodeproj`
3. Select *Product->Build* from the Xcode menu.

For further details, see [Milagro Mobile SDK for iOS Documentation](http://docs.milagro.io/en/mfa/mobile-sdk-ios/milagro-mfa-mobile-sdk-developer-guide.html)

## iOS SDK API for Milagro  (`MPin` class)

The iOS SDK API is used by iOS application developers for integrating with the Milagro Mobile SDK.
The API resembles the SDK Core layer, but it exposes to the Application layer, only those methods that the application needs.
Most of the methods return the `MpinStatus` object which is defined as follows:

```objective-c
typedef NS_ENUM(NSInteger, MPinStatus) {
    OK = 0,
    PIN_INPUT_CANCELED,      // Local error, returned when user cancels entering a pin
    CRYPTO_ERROR,            // Local error in crypto functions
    STORAGE_ERROR,           // Local storage related error
    NETWORK_ERROR,           // Local error - cannot connect to remote server (no internet, or invalid server/port)
    RESPONSE_PARSE_ERROR,    // Local error - cannot parse json response from remote server (invalid json or unexpected json structure)
    FLOW_ERROR,              // Local error - improper MPinSDK class usage
    IDENTITY_NOT_AUTHORIZED, // Remote error - the remote server refuses user registration
    IDENTITY_NOT_VERIFIED,   // Remote error - the remote server refuses user registration because identity is not verified
    REQUEST_EXPIRED,         // Remote error - the register/authentication request expired
    REVOKED,                 // Remote error - cannot get time permit (probably the user is temporary suspended)
    INCORRECT_PIN,           // Remote error - user entered wrong pin
    INCORRECT_ACCESS_NUMBER, // Remote/local error - wrong access number (checksum failed or RPS returned 412)
    HTTP_SERVER_ERROR,       // Remote error, which is not one of the above - the remote server returned internal server error status (5xx)
    HTTP_REQUEST_ERROR,      // Remote error, which is not one of the above - invalid data sent to server, the remote server returned 4xx error status
    BAD_USER_AGENT,          // Remote error - user agent not supported
    CLIENT_SECRET_EXPIRED    // Remote error - re-registration required because server master secret expired
};

@interface MpinStatus : NSObject

@property (nonatomic, readwrite) MPinStatus status;
@property (nonatomic, strong) NSString* errorMessage;
@property (NS_NONATOMIC_IOSONLY, getter=getStatusCodeAsString, readonly, copy) NSString* statusCodeAsString;

@end
```

##### `(void) initSDK;`
This method constructs/initializes the SDK object.

##### `(void) initSDKWithHeaders: (NSDictionary*) dictHeaders;`
This method constructs/initializes the SDK object.
The `dictHeaders` parameter allows the caller to pass additional dictionary of custom headers, which will be added to any HTTP request that the SDK executes.

**Note that after this initialization the SDK will not be ready for usage until `SetBackend` is called with a valid _Server URL_.**

##### `(void) Destroy;`
This method clears the SDK object so it can be re-initialized again, possibly with different parameters.

##### `(void) AddCustomHeaders: (NSDictionary*) dictHeaders;`
This method allows the SDK user to set a map of custom headers, which will be added to any HTTP request that the SDK executes.
The `dictHeaders` parameter is a dictionary of header names mapped to their respective value.
Subsequent calls of this method will add headers on top of the already added ones.

##### `(void) ClearCustomHeaders;`
This method will clear all the currently set custom headers.

##### `(void) AddTrustedDomain: (NSString *) domain;`
For better security, the SDK user might want to limit the SDK to make outgoing requests only to URLs that belong to one or more trusted domains.
This method can be used to add such trusted domains, one by one.
When trusted domains are added, the SDK will verify that any outgoing request is done over the `https` protocol and the host belongs to one of the trusted domains.
If for some reason a request is about to be done to a non-trusted domain, the SDK will return Status `UNTRUSTED_DOMAIN_ERROR`.

##### `(void) ClearTrustedDomains;`
This method will clear all the currently set trusted domains.

##### `(MpinStatus*) TestBackend: (const NSString*) url;`
##### `(MpinStatus*) TestBackend: (const NSString*) url rpsPrefix: (const NSString*) rpsPrefix;`
This method will test whether `url` is a valid back-end URL by trying to retrieve Client Settings from it.
Optionally, a custom RPS prefix might be specified if it was customized at the back-end and is different than the default `"rps"`.
If the back-end URL is a valid one, the method will return status `OK`.

##### `(MpinStatus*) SetBackend: (const NSString*) url;`
##### `(MpinStatus*) SetBackend: (const NSString*) url rpsPrefix: (const NSString*) rpsPrefix;`
This method will change the currently configured back-end in the SDK.
`url` is the new back-end URL that should be used.
Optionally, a custom RPS prefix might be specified if it was customized at the back-end and is different than the default `"rps"`.
If successful, the method will return status `OK`.

##### `(id<IUser>) MakeNewUser: (const NSString*) identity;`
##### `(id<IUser>) MakeNewUser: (const NSString*) identity deviceName: (const NSString*) devName;`
This method creates a new user object. The user object represents an end-user of the Milagro authentication.
The user has its own unique identity, which is passed as the `identity` parameter to this method.
Additionally, an optional `deviceName` might be specified. The _Device Name_ is passed to the RPA, which might store it and use it later to determine which _M-Pin ID_ is associated with this device.
The returned value is a newly created user instance. The User class itself looks like this:
```objective-c
typedef NS_ENUM(NSInteger, UserState)
{
    INVALID = 0,
    STARTED_REGISTRATION,
    ACTIVATED,
    REGISTERED,
    BLOCKED
};

@protocol IUser <NSObject>

- (NSString*) getIdentity;
- (UserState) getState;
- (NSString*) getBackend;
- (NSString*) getCustomerId;
- (NSString*) getAppId;
- (NSString*) getMPinId;
- (Expiration*) getRegistrationExpiration;
- (int) getPinLength;
- (BOOL) canSign;

@end
```

The newly created user is in the `INVALID` user state.

##### `(Boolean) IsUserExisting: (NSString *) identity;`
This method will return `TRUE` if there is a user with the given identity, associated with the currently set backend.
If no such user is found, the method will return `FALSE`.

##### `(void) DeleteUser: (const id<IUser>) user;`
This method deletes a user from the users list that the SDK maintains.
All the user data including its _M-Pin ID_, its state and _M-Pin Token_ will be deleted.
A new user with the same identity can be created later with the `MakeNewUser` method.

##### `(NSMutableArray*) listUsers;`
This method populates the provided list with all the users that are associated with the currently set backend.
Different users might be in different states, reflecting their registration status.
The method will return status `OK` on success and `FLOW_ERROR` if no backend is set through the `Init()` or `SetBackend()` methods.

##### `(NSMutableArray*) listUsers: (NSString*) backendURL`
This method returns a list with all the users that are associated with the provided `backendURL`.
Different users might be in different states, reflecting their registration status.

##### `(NSMutableArray*) listBackends`
This method will return a list with all the backends known to the SDK.

##### `(MpinStatus*) StartRegistration: (const id<IUser>) user;`
##### `(MpinStatus*) StartRegistration: (const id<IUser>) user userData: (NSString*) userData;`
##### `(MpinStatus*) StartRegistration: (const id<IUser>) user activateCode: (NSString*) activateCode;`
##### `(MpinStatus*) StartRegistration: (const id<IUser>) user activateCode: (NSString*) activateCode userData: (NSString*) userData;`
This method initializes the registration for a user that has already been created. The SDK starts the Milagro Setup flow, sending the necessary requests to the back-end service.
The State of the user instance will change to `STARTED_REGISTRATION`. The status will indicate whether the operation was successful or not.
During this call, an _M-Pin ID_ for the end-user will be issued by the RPS and stored within the user object.
The RPA could also start a user identity verification procedure, by sending a verification e-mail.

The optional `activateCode` parameter might be provided if the registration process requires such.
In cases when the user verification is done through a _One-Time-Code_ (OTC) or through an SMS that carries such code, this OTC should be passed as the `activateCode` parameter.
In those cases, the identity verification should be completed instantly and the User State will be set to `ACTIVATED`.
 
Optionally, the application might pass additional `userData` which might help the RPA to verify the user identity.
The RPA might decide to verify the identity without starting a verification process. In this case, the status of the call will still be `OK`, but the User State will be set to `ACTIVATED`.

##### `(MpinStatus*) RestartRegistration: (const id<IUser>) user;`
##### `(MpinStatus*) RestartRegistration: (const id<IUser>) user userData: (const NSString*) userData;`
This method re-initializes the registration process for a user, where registration has already started.
The difference between this method and `StartRegistration` is that it will not generate a new _M-Pin ID_, but will use the one that was already generated.
Besides that, the methods follow the same procedures, such as getting the RPA to re-start the user identity verification procedure of sending a verification email to the user.

The application could also pass additional `userData` to help the RPA to verify the user identity.
The RPA might decide to verify the identity without starting a verification process. In this case, the status of the call will still be `OK`, but the User State will be set to `ACTIVATED`.

##### `(MpinStatus*) ConfirmRegistration: (const id<IUser>) user;`
##### `(MpinStatus*) ConfirmRegistration: (const id<IUser>) user pushNotificationIdentifier: (NSString*) pushNotificationIdentifier;`
This method allows the application to check whether the user identity verification process has been finalized or not.
The provided `user` object is expected to be either in the `STARTED_REGISTRATION` state or in the `ACTIVATED` state.
The latter is possible if the RPA activated the user immediately with the call to `StartRegistration` and no verification process was started.
During the call to `ConfirmRegistration` the SDK will make an attempt to retrieve _Client Key_ for the user.
This attempt will succeed if the user has already been verified/activated but will fail otherwise.
The method will return status `OK` if the Client Key has been successfully retrieved and `IDENTITY_NOT_VERIFIED` if the identity has not been verified yet.
If the method has succeeded, the application is expected to get the desired PIN/secret from the end-user and then call `FinishRegistration`, and provide the PIN.

**Note** Using the optional parameter `pushNotificationIdentifier`, the application can provide a platform specific identifier for sending _Push Messages_ to the device. Such push messages might be utilized as an alternative to the _Access Number/Code_, as part of the authentication flow.

##### `(MpinStatus*) FinishRegistration: (const id<IUser>) user pin: (NSString*) pin;`
This method finalizes the user registration process.
It extracts the _M-Pin Token_ from the _Client Key_ for the provided `pin` (secret), and then stores the token in the secure storage.
On successful completion, the user state will be set to `REGISTERED` and the method will return status `OK`.

##### `(MpinStatus*) StartAuthentication: (const id<IUser>) user;`
This method starts the authentication process for a given `user`.
It attempts to retrieve the _Time Permits_ for the user, and if successful, will return status `OK`.
If they cannot be retrieved, the method will return status `REVOKED`.
If this method is successfully completed, the app should read the PIN/secret from the end-user and call one of the `FinishAuthentication` variants to authenticate the user.

##### `(MpinStatus*) CheckAccessNumber: (NSString*) an;`
This method is used only when a user needs to be authenticated to a remote (browser) session, using _Access Number_.
The access numbers might have a check-sum digit in them and this check-sum needs to be verified on the client side, in order to prevent calling the back-end with non-compliant access numbers.
The method will return status `OK` if successful, and `INCORRECT_ACCESS_NUMBER` if not successful.

##### `(MpinStatus*) FinishAuthentication: (const id<IUser>) user pin: (NSString*) pin;`
##### `(MpinStatus*) FinishAuthentication: (const id<IUser>) user pin: (NSString*) pin authResultData: (NSString**) authResultData;`
This method performs end-user authentication where the `user` to be authenticated is passed as a parameter, along with his `pin` (secret).
The method performs the authentication against the _Milagro MFA Server_ using the provided PIN and the stored _M-Pin Token_, and then logs into the RPA.
The RPA responds with the authentication _User Data_ which is returned to the application through the `authResultData` parameter.
If successful, the returned status will be `OK`, and if the authentication fails, the return status would be `INCORRECT_PIN`.
After the 3rd (configurable in the RPS) unsuccessful authentication attempt, the method will return `INCORRECT_PIN` and the User State will be set to `BLOCKED`.

##### `(MpinStatus*) FinishAuthenticationOTP: (id<IUser>) user pin: (NSString*) pin otp: (OTP**) otp;`
This method performs end-user authentication for an OTP. The authentication process is similar to `FinishAuthentication`, but the RPA issues an OTP instead of logging the user into the application.
The returned status is analogical to the `FinishAuthentication` method, but in addition to that, an `OTP` object is returned. The `OTP` class looks like this:
```objective-c
@interface OTP: NSObject
 
@property (nonatomic, retain, readonly) MpinStatus* status;
@property (nonatomic, retain, readonly) NSString* otp;
@property (atomic, readonly) long expireTime;
@property (atomic, readonly) int ttlSeconds;
@property (atomic, readonly) long nowTime;

- (id) initWith: (MpinStatus*) status otp: (NSString*) otp expireTime: (long) expTime ttlSeconds: (int) ttlSeconds nowTime: (long) nowTime;
 
@end
```
* The `otp` string is the issued OTP.
* The `expireTime` is the Milagro MFA system time when the OTP will expire.
* The `ttlSeconds` is the expiration period in seconds.
* The `nowTime` is the current Milagro MFA system time.
* `status` is the status of the OTP generation. The status will be `OK` if the OTP was successfully generated, or `FLOW_ERROR` if not.

**NOTE** that OTP might be generated only by RPA that supports that functionality, such as the MIRACL M-Pin SSO. Other RPA's might not support OTP generation where the `status` inside the returned `otp` instance will be `FLOW_ERROR`.

##### `(MpinStatus*) FinishAuthenticationAN: (id<IUser>) user pin: (NSString*) pin accessNumber: (NSString*) an;`
This method authenticates the end-user using an _Access Number_ (also refered as _Access Code_), provided by a PC/Browser session.
After this authentication, the end-user can log into the PC/Browser which provided the Access Number, while the authentication itself is done on the Mobile Device.
`an` is the Access Number from the browser session. The returned status might be:

* `OK` - Successful authentication.
* `INCORRECT_PIN` - The authentication failed because of incorrect PIN. After the 3rd (configurable in the RPS) unsuccessful authentication attempt, the method will still return `INCORRECT_PIN` but the User State will be set to `BLOCKED`.
* `INCORRECT_ACCESS_NUMBER` - The authentication failed because of incorrect Access Number. 

##### `(Boolean) CanLogout: (const id<IUser>) user;`
This method is used after authentication with an Access Number/Code through `FinishAuthenticationAN`.
After such an authentication, the Mobile Device can log out the end-user from the Browser session, if the RPA supports that functionality.
This method checks whether logout information was provided by the RPA and the remote (Browser) session can be terminated from the Mobile Device.
The method will return `TRUE` if the user can be logged-out from the remote session, and `FALSE` otherwise.

##### `(Boolean) Logout: (const id<IUser>) user;`
This method tries to log out the end-user from a remote (Browser) session after a successful authentication through `FinishAuthenticationAN`.
Before calling this method, it is recommended to ensure that logout data was provided by the RPA and that the logout operation can be actually performed.
The method will return `TRUE` if the logged-out request to the RPA was successful, and `FALSE` otherwise.

##### `(NSString*) GetClientParam: (const NSString*) key;`
This method returns the value for a _Client Setting_ with the given key.
The value is returned as a string always, i.e. when a numeric or a boolean value is expected, the conversion should be handled by the application. 
Client settings that might interest the applications are:
* `accessNumberDigits` - The number of Access Number digits that should be entered by the user, prior to calling `FinishAuthenticationAN`.
* `setDeviceName` - Indicator (`true/false`) whether the application should ask the user to insert a _Device Name_ and pass it to the `MakeNewUser` method.
* `appID` - The _App ID_ used by the backend. The App ID is a unique ID assigned to each customer or application. It is a hex-encoded long numeric value. The App ID can be used only for information purposes and it does not affect the application's behavior in any way.

## iOS SDK API for MIRACL MFA (`MPinMFA`)

This flavor of the SDK should be used to build apps that authenticate users against the _MIRACL MFA Platform_.
It massively resembles the _Apache Milagro_ flavor, while incorporating some functionality is specific to the MIRACL Platform.
Similarly to `MPin`, the `MPinMFA` needs to be initialized.
Most of the methods return a `MpinStatus` object, which is identical to the one used by `MPin`.

The methods that return `MpinStatus`, will always return status `OK` if successful.
Many methods expect the provided `user` object to be in a certain state, and if it is not, the method will return status `FLOW_ERROR`

##### `(void) initSDK;`
Identical and analogical to `MPin`'s [`initSDK`](#void-initsdk)

##### `(void) initSDKWithHeaders: (NSDictionary*) dictHeaders;`

Identical and analogical to `MPin`'s [`initSDKWithHeaders`](#void-initsdkwithheaders-nsdictionary-dictheaders)

##### `(void) AddCustomHeaders: (NSDictionary*) dictHeaders;`
Identical and analogical to `MPin`'s [`AddCustomHeaders`](#void-addcustomheaders-nsdictionary-dictheaders)

##### `(void) ClearCustomHeaders;`
Identical and analogical to `MPin`'s [`ClearCustomHeaders`](#void-clearcustomheaders)

##### `(void) AddTrustedDomain: (NSString*) domain;`
Identical and analogical to `MPin`'s [`AddTrustedDomain`](#void-addtrusteddomain-nsstring--domain)

##### `(void) ClearTrustedDomains;`
Identical and analogical to `MPin`'s [`ClearTrustedDomains`](#void-cleartrusteddomains)

##### `(void) SetClientId: (NSString*) clientId;`
This method will set a specific _Client/Customer ID_ which the SDK should use when sending requests to the backend.
The MIRACL MFA Platform generates _Client IDs_ (sometimes also referred as _Customer IDs_) for the platform customers.
The customers can see those IDs through the _Platform Portal_.
When customers use the SDK to build their own applications to authenticate users using the Platform, the _Client ID_ has to be provided using this method. 

##### `(MpinStatus*) TestBackend: (const NSString*) url;`
##### `(MpinStatus*) TestBackend: (const NSString*) url rpsPrefix: (NSString*) rpsPrefix;`
Identical and analogical to `MPin`'s [`TestBackend`](#mpinstatus-testbackend-const-nsstring-url)

##### `(MpinStatus*) SetBackend: (const NSString*) url;`
##### `(MpinStatus*) SetBackend: (const NSString*) url rpsPrefix: (NSString*) rpsPrefix;`
Identical and analogical to `MPin`'s [`SetBackend`](#mpinstatus-setbackend-const-nsstring-url)

##### `(id<IUser>) MakeNewUser: (const NSString*) identity;`
##### `(id<IUser>) MakeNewUser: (const NSString*) identity deviceName: (const NSString*) devName;`
Identical and analogical to `MPin`'s [`MakeNewUser`](#idiuser-makenewuser-const-nsstring-identity)

##### `(Boolean) IsUserExisting: (NSString*) identity customerId: (NSString*) customerId appId: (NSString*) appId;`
This method will return `TRUE` if there is a user with the given properties.
If no such user is found, the method will return `FALSE`.

In the MIRACL MFA Platform end-users are registered for a given Customer.
Therefor, same identity might be registered for two different customers, and two different User objects will be present for the two different customers, but with the same `identity`.
When checking whether the user exists, one should specify also the `customerId`.
The `appId` parameter is for future use and should be passed as an empty string.

##### `(void) DeleteUser: (const id<IUser>) user;`
Identical and analogical to `MPin`'s [`DeleteUser`](#void-deleteuser-const-idiuser-user)

##### `(NSMutableArray*) listUsers;`
This method will return an array with ALL the users known to the SDK.
After the list is returned to the caller, the users might be filtered out using the `IUser`'s properties `getBackend`, `getCustomerId` and `getAppId`.

##### `(MpinStatus*) GetServiceDetails: (NSString*) url serviceDetails: (ServiceDetails**) sd;`
After scanning a QR Code from the platform login page, the app should extract the URL from it and call this method to retrieve the _Service Details_.
The service details include the _backend URL_ which needs to be set back to the SDK in order connect it to the platform.
This method could be called even before the SDK has been initialized, or alternatively the SDK could be initialized without setting a backend, and `SetBackend` could be used after the backend URL has been retrieved through this method.
The returned `ServiceDetails` look as follows:
```objective-c
@interface ServiceDetails : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* backendUrl;
@property (nonatomic, strong) NSString* rpsPrefix;
@property (nonatomic, strong) NSString* logoUrl;

@end
```
* `name` is the service readable name
* `backendUrl` is the URL of the service backend. This URL has to be set either via the SDK `initSDK` method or using  `SetBackend`
* `rpsPrefix` is RPS prefix setting which is also provided together with `backendUrl` while setting a backend
* `logoUrl` is the URL of the service logo. The logo is a UI element that could be used by the app.

##### `(SessionDetails*) GetSessionDetails: (NSString*) accessCode;`
This method could be optionally used to retrieve details regarding a browser session when the SDK is used to authenticate users to an online service, such as the _MIRACL MFA Platform_.
In this case an `accessCode` is transferred to the mobile device out-of-band e.g. via scanning a graphical code.
The code is then provided to this method to get the session details.
This method will also notify the backend that the `accessCode` was retrieved from the browser session.
The returned `SessionDetails` look as follows:
```objective-c
@interface SessionDetails : NSObject

@property (nonatomic, retain) NSString* prerollId;
@property (nonatomic, retain) NSString* appName;
@property (nonatomic, retain) NSString* appIconUrl;
@property (nonatomic, retain) NSString* customerId;
@property (nonatomic, retain) NSString* customerName;
@property (nonatomic, retain) NSString* customerIconUrl;

@end
}
```
During the online browser session an optional user identity might be provided meaning that this is the user that wants to register/authenticate to the online service.
* The `prerollId` will carry that user ID, or it will be empty if no such ID was provided.
* `appName` is the name of the web application to which the service will authenticate the user.
* `appIconUrl` is the URL from which the icon for web application could be downloaded.
* `customerId` is the ID of the Customer (the one whom the application belongs to) for the current session.
* `customerName` is the name of the Customer (the one whom the application belongs to) for the current session.
* `customerIconUrl` is the Customer icon URL for the  for the current session. Note that this URL might not be set.

##### `(MpinStatus*) AbortSession: (NSString*) accessCode;`
This method should be used to inform the Platform that the current authentication/registration session has been aborted.
A session starts with obtaining the _Access Code_, usually after scanning and decoding a graphical image, such as QR Code.
Then the mobile client might retrieve the session details using `GetSessionDetails`, after which it can either start registering a new end-user or start authentication.
This process might be interrupted by either the end-user disagreeing on the consent page, or by just hitting a Back button on the device, or by even closing the app.
For all those cases, it is recommended to use `AbortSession` to inform the Platform.

##### `(MpinStatus*) GetAccessCode: (NSString*) authzUrl accessCode: (NSString**) accessCode;`
This method should be used when the mobile app needs to login an end-user into the app itself.
In this case there's no browser session involved and the Access Code cannot be obtained by scanning an image from the browser.
Instead, the mobile app should initially get from its backend an _Authorization URL_. This URL could be formed at the app backend using one of the _MFA Platform SDK_ flavors.
When the mobile app has the Authorization URL, it can pass it to this method as `authzUrl`, and get back an `accessCode` that can be further used to register or authenticate end-users.
Note that the Authorization URL contains a parameter that identifies the app.
This parameter is validated by the Platform and it should correspond to the Customer ID, set via `SetClientId`.

##### `(MpinStatus*) StartRegistration: (const id<IUser>) user accessCode: (NSString*) accessCode pmi: (NSString*) pmi;
##### `(MpinStatus*) StartRegistration: (const id<IUser>) user accessCode: (NSString*) accessCode regCode: (NSString*) regCode pmi: (NSString*) pmi;
This method initializes the registration for a User that has already been created.
The SDK starts the Setup flow, sending the necessary requests to the back-end service.
The State of the User instance will change to `STARTED_REGISTRATION`.
The status will indicate whether the operation was successful or not.
During this call, an _M-Pin ID_ for the end-user will be issued by the Platform and stored within the user object.
The Platform will also start a user identity verification procedure, by sending a verification e-mail.

The `accessCode` should be obtained from a browser session, and session details are retrieved before starting the registration.
This way the mobile app can show to the end-user the respective details for the customer, which the identity is going to be associated to.
 
The `pmi` parameter is optional and might be passed as an empty string.
It is a unique token (_Push Message Identifier_) for sending _Push Notifications_ to the mobile app.
When such token is provided, the Platform might use additional verification step by sending a Push Notification to the app.

Additional optional parameter is the `regCode`.
This is a _Registration Code_ that could be used to bypass the identity verification process.
A valid registration code could be generated by an already registered device, after authenticating the user.
This code could then be provided during the registration process on a device, and the Platform will let the user register, skipping the verification process for that identity.

##### `(MpinStatus*) RestartRegistration: (const id<IUser>) user;`
Identical and analogical to `MPin`'s [`RestartRegistration`](#mpinstatus-restartregistration-const-idiuser-user),
without the additional optional parameter that is not used by the MFA Platform.

##### `(MpinStatus*) ConfirmRegistration: (const id<IUser>) user;`
Identical and analogical to `MPin`'s [`ConfirmRegistration`](#mpinstatus-confirmregistration-const-idiuser-user),
without the additional optional parameter that is not used by the MFA Platform.

##### `(MpinStatus*) FinishRegistration: (const id<IUser>) user pin0: (NSString*) pin0 pin1: (NSString*) pin1;`
This method is generally identical and analogical to `MPin`'s [`FinishRegistration`](#mpinstatus-finishregistration-const-idiuser-user-pin-nsstring-pin),
but it allows passing an additional authentication factor as `pin1`. If not needed, `pin1` should be `nil`.

##### `(MpinStatus*) StartAuthentication: (const id<IUser>) user accessCode: (NSString*) accessCode;`
This method starts the authentication process for a given `user`.
It attempts to retrieve the _Time Permits_ for the user, and if successful, will return Status `OK`.
If they cannot be retrieved, the method will return Status `REVOKED`.
If this method is successfully completed, the app should read the PIN/secret from the end-user and call one of the `FinishAuthentication` variants to authenticate the user.

The `accessCode` is retrieved out-of-band from a browser session when the user has to be authenticated to an online service, such as the _MIRACL MFA Platform_.
The SDK will notify the platform that authentication associated with the given `accessCode` has started for the provided user. 

##### `(MpinStatus*) StartAuthenticationOTP: (const id<IUser>) user;`
This method will start the authentication for OTP generation.
It resembles the `StartAuthentication` method, but the difference is that in this case no `accessCode` is required.
OTP generation is not tied to a specific Customer Application session.

##### `(MpinStatus*) StartAuthenticationRegCode: (const id<IUser>) user;`
This method will start the authentication for _Registration Code_ generation.
It resembles the `StartAuthentication` method, but the difference is that in this case no `accessCode` is required.
Registration Code generation is not tied to a specific Customer Application session.

##### `(MpinStatus*) FinishAuthentication: (id<IUser>) user pin0: (NSString*) pin0 pin1: (NSString*) pin1 accessCode: (NSString*) accessCode;`
This method authenticates the end-user for logging into a Web App in a browser session.
The `user` to be authenticated is passed as a parameter, along with his/her secret (`pin0`).
The `accessCode` associates the authentication with the browser session from which it was obtained.

It is generally identical and analogical to `MPin`'s [`FinishAuthenticationAN`](#mpinstatus-finishauthenticationan-idiuser-user-pin-nsstring-pin-accessnumber-nsstring-an),
while the Access Code is used instead of an Access Number.

The method allows passing additional authentication factor to the SDK, as `pin1`.
If not needed, `pin1` should be `nil`.

The returned status might be:
* `OK` - Successful authentication.
* `INCORRECT_PIN` - The authentication failed because of incorrect PIN/secret.
After the 3rd unsuccessful authentication attempt, the method will still return `INCORRECT_PIN` but the User State will be set to `BLOCKED`.

##### `(MpinStatus*) FinishAuthentication: (const id<IUser>) user pin: (NSString*) pin pin1: (NSString*) pin1 accessCode: (NSString*) accessCode authzCode: (NSString**) authzCode;`
This method authenticates an end-user in a way that allows the mobile app to log the user into the app itself after verifying the authentication against its own backend. 
When using this flow, the mobile app would first retrieve the `accessCode` using the `GetAccessCode` method,
and when authentication the user it will receive an _Authorization Code_, `authzCode`.
Using this Authorization Code, the mobile app can make a request to its own backend, so the backend can validate it using one of the _MFA Platform SDK_ flavors,
and create a session token.
This token could be used further as an authentication element in the communication between the app and its backend.

The method allows passing additional authentication factor to the SDK, as `pin1`.
If not needed, `pin1` should be `nil`.

##### `(MpinStatus*) FinishAuthenticationOTP: (const id<IUser>) user pin: (NSString*) pin otp: (OTP**) otp;`
This method performs end-user authentication for OTP generation.
The authentication process is similar to `FinishAuthentication`, but as a result the MFA Platform issues an OTP instead of logging the user into an application.
The returned status is analogical to the `FinishAuthentication` method, but in addition to that, an `OTP` object is returned.
The `OTP` class looks like this:
```objective-c
@interface OTP : NSObject

@property (nonatomic, retain, readonly) MpinStatus* status;
@property (nonatomic, retain , readonly) NSString* otp;
@property (atomic, readonly) long expireTime;
@property (atomic, readonly) int ttlSeconds;
@property (atomic, readonly) long nowTime;

@end
```
* The `otp` string is the issued OTP.
* The `expireTime` is the MIRACL MFA system time when the OTP will expire.
* The `ttlSeconds` is the expiration period in seconds.
* The `nowTime` is the current MIRACL MFA system time.
* `status` is the status of the OTP generation. The status will be `OK` if the OTP was successfully generated, or `FLOW_ERROR` if not.

##### `(MpinStatus*) FinishAuthenticationRegCode: (const id<IUser>) user pin: (NSString*) pin0 pin1: (NSString*) pin1 regCode: (RegCode**) regCode;`
This method performs end-user authentication for _Registration Code_ generation.
The authentication process is similar to `FinishAuthentication`, but as a result the MFA Platform issues a Registration Code instead of logging the user into an application.
The returned status is analogical to the `FinishAuthentication` method, but in addition to that, an `RegCode` object is returned.
The `RegCode` class is basically identical to the `OTP` class, and looks like this:
```objective-c
@interface RegCode : NSObject

@property (nonatomic, retain, readonly) MpinStatus* status;
@property (nonatomic, retain , readonly) NSString* otp;
@property (atomic, readonly) long expireTime;
@property (atomic, readonly) int ttlSeconds;
@property (atomic, readonly) long nowTime;

@end
```
* The `otp` string is the issued Registration Code, which is a one-time code in its nature.
* The `expireTime` is the MIRACL MFA system time when the code will expire.
* The `ttlSeconds` is the expiration period in seconds.
* The `nowTime` is the current MIRACL MFA system time.
* `status` is the status of the Registration Code generation. The status will be `OK` if the Registration Code was successfully generated, or `FLOW_ERROR` if not.

The method allows passing additional authentication factor to the SDK, as `pin1`.
If not needed, `pin1` should be `nil`.

##### `(MpinStatus*) StartRegistrationDVS: (const id<IUser>) user token: (NSString*) token;`
This method starts the user registration for the _DVS (Designated Verifier Signature)_ functionality.

The DVS functionality allows a customer application to verify signatures of documents/transactions, signed by the end-user.

It is a separate process than the registration for authentication, while a user should be authenticated in order to register for DVS.
This separate process allows users to register for DVS only if they want/need to, and also to select a different PIN/secret for signing documents.

The expected `token` is the _Access Token_ issued for the user during the _Open ID Connect Authentication Process_.
This `token` has to be passed from the Relying Party Backend to the Mobile App in a way that is outside the scope of this Mobile SDK.

##### `(MpinStatus*) FinishRegistrationDVS: (const id<IUser>) user pinDVS: (NSString*) pinDVS nfc: (NSString*) nfc;`
This method finalizes the user registration process for the DVS functionality.
Before calling it the application has to get from the end-user the authentication factors that need to be specified while signing (like PIN and possibly others).

The method allows passing additional authentication factor to the SDK, as `nfc`.
If not needed, `nfc` should be `nil`.

##### `(BOOL) VerifyDocument: (NSString*) strDoc hash: (NSData*) hash;`
This method relates to the _DVS (Designated Verifier Signature)_ functionality of the MFA Platform.

It verifies that the `hash` value is correct for the given `strDoc`.
The method returns `TRUE` or `FALSE` respectively, if the hash is correct or not.

The DVS functionality allows a customer application to verify signatures of documents/transactions, signed by the end-user.
The document (`strDoc`) is any free form text that needs to be signed.
Typically, the customer application will generate a `hash` value for the document that needs to be signed, and will send it to the mobile client app.
The client app can then verify the correctness of the hash value using this method.

##### `(MpinStatus*) Sign: (id<IUser>) user documentHash: (NSData*) documentHash pin0: (NSString*) pin0 pin1: (NSString*) pin1 epochTime: (double) epochTime authZToken: (NSString*) authZToken result: (BridgeSignature**) result;`
This method relates to the _DVS (Designated Verifier Signature)_ functionality of the MFA Platform.

It signs a given `documentHash` for the provided `user`.
The `user` should have the ability to sign documents, i.e. it has to have possession of a signing client key and a public/private key-pair.
Those are issued for the user during registration, but users that have registered prior to the DVS feature availability, might lack those keys.
To check whether a user has signing capability, use the `IUser`'s method `canSign`.
The end-user's authentication factor/s should be provided as well, since signing a document (its hash, in fact) is very similar to authenticating.

The method allows passing additional authentication factor to the SDK, as `pin1`.
If not needed, `pin1` should be `nil`.

`epochTime` is the time, in Epoch format, for the document/transaction signature.
Both the `documentHash` and the `epochTime` should be generated and provided by the customer application back-end.

`authZToken` is a token that the SDK needs in order to be able to generate the signature and verify against the platform the correctness of the provided authentication factors.
This token should also be generated by the application back-end, using one of the MFA Backend SDK variants.
Generally, the token has the format:
```
"MAAS-HMAC-SHA256  <token>"
```
as `<token>` is Base64-encoded `<client-id>:<hmac-sha256-signature>`.

`<hmac-sha256-signature>` is an _HMAC-SHA256_ signature of the hex-encoded document hash, using the _Client Secret_ as a _key_. _Client ID_ and _Client Secret_ are issued by the Platform when creating an application.

The generated signature is returned in the `result` parameter.
The `BridgeSignature` class has the following form:
```objective-c
@interface BridgeSignature : NSObject

@property (nonatomic) NSData* strHash;
@property (nonatomic) NSData* strMpinId;
@property (nonatomic) NSData* strU;
@property (nonatomic) NSData* strV;
@property (nonatomic) NSData* strPublicKey;

@end
```
* `strHash` is the document hash. It should be identical to the provided `documentHash`.
* `strMpinId` is the end-user's _M-Pin ID_.
* `strU` and `strV` are the actual values that represent the signature.
* `strPublicKey` is the _Public Key_ associated with the end-user.
All of those parameters should be sent to the customer application back-end, so it can verify the signature.

The returned `MpinStatus` could be one of:
* `OK` - document hash was successfully signed.
* `INCORRECT_PIN` - The method failed due to incorrect authentication factor/s. If this status is returned, the `user` State might be changed to `BLOCKED` in case several consecutive unsuccessful attempts were performed.
* `FLOW_ERROR` - The provided `user` doesn't have the ability to sign documents.
* `CRYPTO_ERROR` - an error has occurred at the crypto layer of the SDK. Call the status's `errorMessage` property for more info.

For more information you can refer to the [SDK Core](https://github.com/miracl/incubator-milagro-mfa-sdk-core)