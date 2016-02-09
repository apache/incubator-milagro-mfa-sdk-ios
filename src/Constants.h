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

#ifndef MPinSDK_Constants_h
#define MPinSDK_Constants_h

typedef double PixelsPerSecond;

#pragma mark - Navigation Controller Titles -

static NSString *const kSettingsFile = @"Settings";
static NSString *const kBackendsKey = @"BACKENDS";

static NSString *kSetupPin = @"Setup PIN";
static NSString *kEnterPin = @"Enter Your PIN";

/// UI constants
static NSString *const kBackBarButtonItem = @"image.png";
static NSString *const kDevName = @"Device Name";

static NSString *const kRPSURL = @"backend";
static NSString *const kRPSPrefix = @"rps_prefix";
static NSString *const kSERVICE_TYPE = @"SERVICE_TYPE";
static NSString *const kIS_DN = @"dn";
static NSString *const kCONFIG_NAME = @"CONFIG_NAME";
static NSString *const kREAD_ONLY = @"READ_ONLY";
static NSString *const kSelectedUser = @"SELECTED_USER";
static NSString *const kConfigHashValue = @"hashValue";
static NSString *const kDefConfigThreshold = @"DefConfigThreshold";
static NSString *const kSelectedConfiguration = @"SelectedConfiguration";
static NSString *const kUser = @"USER";

#define NOT_SELECTED -1

/// BEGIN JSON CONFIG FROM SERVER
static NSString *const kJSON_URL = @"url";
static NSString *const kJSON_NAME = @"name";
static NSString *const kJSON_TYPE = @"type";
static NSString *const kJSON_PREFIX = @"prefix";

static NSString *const kJSON_TYPE_OTP = @"otp";
static NSString *const kJSON_TYPE_MOBILE = @"mobile";
static NSString *const kJSON_TYPE_ONLINE = @"online";
//// END

///// MESSAGE PARAMETER LIST
static NSString *const kMpinId = @"mpinId";
static NSString *const kActivationKey = @"activationKey";
static NSString *const kSafariID = @"com.apple.mobilesafari";

///// END

static NSString *const kDeviceName = @"setDeviceName";
static NSString *const kDefaultDeviceName = @"Sample IOS App";
static NSString *const kShowPinPadNotification = @"ShowPinPadNotification";

static NSString *const kEmptyStr = @"";

static NSString *constStrNetworkDown = @"NetworkDown";
static NSString *constStrNetworkUp = @"NetworkUp";

static float kFltNoNetworkMessageAnimationDuration = 0.2f;

enum MENU_OPTIONS
{
    USER_LIST = 0,
    SETTINGS = 1,
    QUICK_START = 2,
    GET_SERVER = 3,
    ABOUT = 4
};

enum SERVICES
{
    LOGIN_ON_MOBILE = 0,
    LOGIN_ONLINE    = 1,
    LOGIN_WITH_OTP  = 2
};

enum HELP_VIEW_MODE
{
    HELP_SERVER    = 1,
    HELP_QUICK_START    = 2,
    HELP_AN    = 3,
    HELP_QUICK_START_FROM_MENU    = 4
};

//// HELP  DATA
static NSString *const kHelpTitle = @"Title";
static NSString *const kHelpImage = @"image";
static NSString *const kHelpSubTitle = @"subtitle";
static NSString *const kHelpDescription = @"description";

static NSString *const kHelpFile = @"Help";

static NSString *const kFirstTimeLaunch = @"first_app_start";
static NSString *const kQuickStartGuide = @"quick_menu_item";
static NSString *const kMpinServerGuide = @"server_settings";
static NSString *const kAddIdentityGuide = @"add_id_guide";

static NSString *const kAppUserGuideForMPINConnect = @"M-Pin Connect";

//// NSERROR Constants
static NSString *const kErrorTitle = @"errorTitle";
static NSString *const kErrorMessage = @"errorMessage";
static NSString *const kConflictStatus = @"conflictStatus";
//// END
#endif