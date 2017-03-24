# Simple Google Analytics for IOS

SimpleGoogleAnalytics is an HTTP networking library send message to Google Analytics in Objective-c.

- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
    - **Intro -** [Instance](#instance), [Start Session](#start-session), [End Session](#end-session), [Send Collect Message](#send-collect-message), [Send Batch Message](#send-batch-message),
                   [ItemGA](#itemga)
    - **Enums -** [GAParameter Enum](#gaparameterenum), [HitTypeEnum](#hittypeenum)
    - **Auxiliary methods -** [setRequiredParameters](#setrequiredparameters), [changeHitType](#changehittype), [getValueEnumGAParameter](#getvalueenumgaparameter)
- [Credits](#credits)
- [License](#license)

## Requirements

- iOS 7.0+
- Xcode 8.2+
- Objective-c

## Communication

- If you **need help or suggest or general question**, use email paulobrambillajunior@gmail.com.
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build SimpleGoogleAnalytics.

To integrate SimpleGoogleAnalytics into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SimpleGoogleAnalytics', '~> 0.0.1'
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage

### Instance

The code below should be pasted into the `AppDelegate.m`.</br>
Initializes the SimpleGoogleAnalytics class by passing the Tracking ID / Web Property ID, Customer ID, and Hit Type.

```objc
#import <UIKit/UIKit.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.sga = [SimpleGoogleAnalytics startSharedWithTid:@"tid" withCid:@"cid" andHitType:SCREEN_VIEW_HIT];
    //Your code.
    return YES;
}
```
### Start Session

Sign in with google analytics.</br>
The code below should be pasted into the `AppDelegate.m`.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
    [self.sga startSession:^(NSData *data, NSURLResponse * _Nullable response, NSError * _Nullable erro) {
        if (erro){
            NSLog(@"Erro: %@", [erro.userInfo objectForKey:[NSNumber numberWithLong:erro.code ]]);
        }
    }];
}
```

### End Session

Ends the session with Google Analytics.</br>
The code below should be pasted into the `AppDelegate.m`.

```objective-c
- (void)applicationWillTerminate:(UIApplication *)application {
    [self.sga endSession:^(NSData *data, NSURLResponse * _Nullable response, NSError * _Nullable erro) {
        if (erro){
            NSLog(@"Erro: %@", [erro.userInfo objectForKey:[NSNumber numberWithLong:erro.code ]]);
        }
    }];
}
```

### Send Collect Message

Send a simple message.</br>
Example:</br>
&nbsp;&nbsp;&nbsp;v=1&tid=UA-123456-1&cid=5555&t=screenview&aip=1

```objective-c
ItemGA *item = [[ItemGA alloc] initWithCodEnumParameterGA:ANONYMIZE_IP_GAPARAMETERS andKey: @"aip" andValue: @"1"];
    
NSArray<ItemGA *> *parameters = [NSArray arrayWithObject:item];

[self sendMessage:parameters withCallBack:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError *	_Nullable erro) {
        //Your code.
}];
```


### Send Batch Message

Send multiple messages at once.</br>
Example:</br>
&nbsp;&nbsp;&nbsp;v=1&tid=UA-123456-1&cid=5555&t=screenview&aip=1</br>
&nbsp;&nbsp;&nbsp;v=1&tid=UA-123456-1&cid=5555&t=screenview&ds=app
          
```objective-c
NSMutableArray<NSArray<ItemGA *> *> *parameters = [NSMutableArray new];

ItemGA *item1 = [[ItemGA alloc] initWithCodEnumParameterGA:ANONYMIZE_IP_GAPARAMETERS andKey: [self getValueEnumGAParameter: ANONYMIZE_IP_GAPARAMETERS] andValue: @"1"];
ItemGA *item2 = [[ItemGA alloc] initWithCodEnumParameterGA:DATA_SOURCE_GAPARAMETERS andKey:[self getValueEnumGAParameter: DATA_SOURCE_GAPARAMETERS] andValue:@"app"];

NSMutableArray<ItemGA *> *line = [NSMutableArray new];
[line addObject:item1];
[line addObject:item2];
    
[parameters addObject:line];
    
[self.sga sendBatchMessage:parameters withCallBack:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable erro) {
    //Your code.
}];
```

### ItemGA

This object represents the parameter and value to be passed in the request. Its startup parameters are an Enum code GAParamenters the value of the key (@"sc") and the value of this key (@"start").
You can use the `getValueEnumGAParameter` method to pick up the key value but for keys that do not need the index control the programmed should inform the String itself.


```objective-c
#import "ItemGA.h" 

ItemGA *item = [[ItemGA alloc] initWithCodEnumParameterGA:SESSION_CONTROL_GAPARAMETERS andKey: [self getValueEnumGAParameter:SESSION_CONTROL_GAPARAMETERS] andValue: @"start"];
```

### GAParameterEnum
Enumerated listing the Google Analytics parameters to use along with the instantiation of the `ItemGA` class and the `getValueEnumGAParameter` method. For more details on each parameter go to the link [Protocol Parameter Reference](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters?hl=en).

```objective-c
typedef NS_ENUM(NSInteger, GAParametersEnum){
    ANONYMIZE_IP_GAPARAMETERS,
    DATA_SOURCE_GAPARAMETERS,
    QUEUE_TIME_GAPARAMETERS,
    CACHE_BUSTER_GAPARAMETERS,
    USER_ID_GAPARAMETERS,
    SESSION_CONTROL_GAPARAMETERS,
    IP_OVERRIDE_GAPARAMETERS,
    USER_AGENT_OVERRIDE_GAPARAMETERS,
    GEOGRAPHICAL_OVERRIDE_GAPARAMETERS,
    DOCUMENT_REFERRER_GAPARAMETERS,
    CAMPAIGN_NAME_GAPARAMETERS,
    CAMPAIGN_ORIGIN_GAPARAMETERS,
    CAMPAIGN_MEDIA_GAPARAMETERS,
    CAMPAIGN_KEYWORD_GAPARAMETERS,
    CAMPAIGN_CONTENT_GAPARAMETERS,
    CAMPAIGN_ID_GAPARAMETERS,
    GOOGLE_ADWORDS_ID_GAPARAMETERS,
    GOOGLE_DISPLAY_ADS_ID_GAPARAMETERS,
    SCREEN_RESOLUTION_GAPARAMETERS,
    VIEWPORT_SIZE_GAPARAMETERS,
    DOCUMENT_ENCODING_GAPARAMETERS,
    SCREEN_COLORS_GAPARAMETERS,
    USER_LANGUAGE_GAPARAMETERS,
    JAVA_ENABLED_GAPARAMETERS,
    FLASH_VERSION_GAPARAMETERS,
    NON_INTERACTION_HIT_GAPARAMETERS,
    DOCUMENT_LOCATION_URL_GAPARAMETERS,
    DOCUMENT_HOST_NAME_GAPARAMETERS,
    DOCUMENT_PATH_GAPARAMETERS,
    DOCUMENT_TITLE_GAPARAMETERS,
    SCREEN_NAME_GAPARAMETERS,
    CONTENT_GROUP_GAPARAMETERS,
    LINK_ID_GAPARAMETERS,
    APPLICATION_NAME_GAPARAMETERS,
    APPLICATION_ID_GAPARAMETERS,
    APPLICATION_VERSION_GAPARAMETERS,
    APPLICATION_INSTALLER_ID_GAPARAMETERS,
    EVENT_CATEGORY_GAPARAMETERS,
    EVENT_ACTION_GAPARAMETERS,
    EVENT_LABEL_GAPARAMETERS,
    EVENT_VALUE_GAPARAMETERS,
    TRANSACTION_ID_GAPARAMETERS,
    TRANSACTION_AFFILIATION_GAPARAMETERS,
    TRANSACTION_REVENUE_GAPARAMETERS,
    TRANSACTION_SHIPPING_GAPARAMETERS,
    TRANSACTION_TAX_GAPARAMETERS,
    ITEM_NAME_GAPARAMETERS,
    ITEM_PRICE_GAPARAMETERS,
    ITEM_QUANTITY_GAPARAMETERS,
    ITEM_CODE_GAPARAMETERS,
    ITEM_CATEGORY_GAPARAMETERS,
    PRODUCT_SKU_GAPARAMETERS,
    PRODUCT_NAME_GAPARAMETERS,
    PRODUCT_BRAND_GAPARAMETERS,
    PRODUCT_CATEGORY_GAPARAMETERS,
    PRODUCT_VARIANT_GAPARAMETERS,
    PRODUCT_PRICE_GAPARAMETERS,
    PRODUCT_QUANTITY_GAPARAMETERS,
    PRODUCT_COUPON_CODE_GAPARAMETERS,
    PRODUCT_POSITION_GAPARAMETERS,
    PRODUCT_CUSTOM_DIMENSION_GAPARAMETERS,
    PRODUCT_CUSTOM_METRIC_GAPARAMETERS,
    PRODUCT_ACTION_GAPARAMETERS,
    ID_TRANSACTION_GAPARAMETERS,
    AFFILIATION_GAPARAMETERS,
    REVENUE_GAPARAMETERS,
    TAX_GAPARAMETERS,
    SHIPPING_GAPARAMETERS,
    COUPON_CODE_GAPARAMETERS,
    PRODUCT_ACTION_LIST_GAPARAMETERS,
    CHECKOUT_STAGE_GAPARAMETERS,
    CHECKOUT_STAGE_OPTION_GAPARAMETERS,
    PRODUCT_IMPRESSION_LIST_NAME_GAPARAMETERS,
    PRODUCT_IMPRESSION_SKU_GAPARAMETERS,
    PRODUCT_IMPRESSION_NAME_GAPARAMETERS,
    PRODUCT_IMPRESSION_BRAND_GAPARAMETERS,
    PRODUCT_IMPRESSION_CATEGORY_GAPARAMETERS,
    PRODUCT_IMPRESSION_VARIANT_GAPARAMETERS,
    PRODUCT_IMPRESSION_POSITION_GAPARAMETERS,
    PRODUCT_IMPRESSION_PRICE_GAPARAMETERS,
    PRODUCT_IMPRESSION_CUSTOM_DIMENSION_GAPARAMETERS,
    PRODUCT_IMPRESSION_CUSTOM_METRIC_GAPARAMETERS,
    PROMOTION_ID_GAPARAMETERS,
    PROMOTION_NAME_GAPARAMETERS,
    PROMOTION_CREATIVE_GAPARAMETERS,
    PROMOTION_POSITION_GAPARAMETERS,
    PROMOTION_ACTION_GAPARAMETERS,
    CURRENCY_CODE_GAPARAMETERS,
    SOCIAL_NETWORK_GAPARAMETERS,
    SOCIAL_ACTION_GAPARAMETERS,
    SOCIAL_ACTION_TARGET_GAPARAMETERS,
    USER_TIMING_CATEGORY_GAPARAMETERS,
    USER_TIMING_VARIABLE_NAME_GAPARAMETERS,
    USER_TIMING_TIME_GAPARAMETERS,
    USER_TIMING_LABEL_GAPARAMETERS,
    PAGE_LOAD_TIME_GAPARAMETERS,
    DNS_TIME_GAPARAMETERS,
    PAGE_DOWNLOAD_TIME_GAPARAMETERS,
    REDIRECT_RESPONSE_TIME_GAPARAMETERS,
    TCP_CONNECT_TIME_GAPARAMETERS,
    SERVER_RESPONSE_TIME_GAPARAMETERS,
    DOM_INTERACTIVE_TIME_GAPARAMETERS,
    CONTENT_LOAD_TIME_GAPARAMETERS,
    EXCEPTION_DESCRIPTION_GAPARAMETERS,
    IS_FATAL_EXCEPTION_GAPARAMETERS,
    CUSTOM_DIMENSION_GAPARAMETERS,
    CUSTOM_METRIC_GAPARAMETERS,
    EXPERIMENT_ID_GAPARAMETERS,
    EXPERIMENT_VARIANT_GAPARAMETERS,
    ENUM_COUNT
};
```

### HitTypeEnum

The type of hit. Must be one of 'pageview', 'screenview', 'event', 'transaction', 'item', 'social', 'exception', 'timing'.
```objective-c
typedef NS_ENUM(NSInteger, HitTypeEnum){
    EVENT_HIT,
    EXCEPTION_HIT,
    ITEM_HIT,
    PAGE_VIEW_HIT,
    SCREEN_VIEW_HIT,
    SOCIAL_HIT,
    TRANSACTION_HIT,
    TIMING_HIT,
    HIT_TYPE_ENUM_COUNT
};
```

### setRequiredParameters

Method for set a required parameters to send data to Google Analytics and init session.

* tid -> The ID that distinguishes the Google Analytics property that should receive the data.
* cid -> A unique code for a specific user.
* hitTypeEnum -> The type of interaction collected for a specific user.

```objective-c
-(void) setRequiredParameters: (NSString*) tid withCid: (NSString*) cid andHitType: (NSInteger) hitTypeEnum;
```

### changeHitType

Method for set a Hit Type with HitTypeEnum.

* hitTypeEnum -> Enum value. Example: EVENT_HIT.


```objective-c
-(void) changeHitType:(NSInteger) hitTypeEnum;
```

### getValueEnumGAParameter
Takes the value that enumerator represents.

 * codeEnum -> This is Enum GAParameters.
 * return -> Value of parameter.
 
 ```objective-c
-(NSString*) getValueEnumGAParameter: (int) codeEnum;
```
---

## License

SimpleGoogleAnalytics is released under the GNU license. See COPYING for details.
