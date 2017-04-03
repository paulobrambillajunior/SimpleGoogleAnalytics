//
//  SimpleGoogleAnalytics.h
//  SimpleGoogleAnalytics
//
//  Created by Paulo Brambilla Junior on 03/02/17.
//  Copyright © 2017 Paulo Roberto Brambilla Junior.
//
//  This file is part of SimpleGoogleAnalytics.
//
//  SimpleGoogleAnalytics is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  SimpleGoogleAnalytics is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

#import <Foundation/Foundation.h>
#import "ItemGA.h"

typedef void(^CallBackSend) (NSData *_Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable erro);
typedef void(^CallBackError) (NSError *_Nullable erro);

@interface SimpleGoogleAnalytics : NSObject

typedef NS_ENUM(NSInteger, GAParameters){
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

NS_ASSUME_NONNULL_BEGIN

/**
 Method to init a SimpleGoogleAnalytics.

 @param tid The ID that distinguishes the Google Analytics property that should receive the data.
 @param cid A unique code for a specific user.
 @param hitTypeEnum The type of interaction collected for a specific user.
  @return Objetc to SimpleGoogleAnatics instantiated.
 */
+(instancetype)startSharedWithTid: (NSString*) tid withCid: (NSString*) cid andHitType: (NSInteger) hitTypeEnum;

/**
 Send 1 lote to Google Analytics metrics with you define.
 
 @param parameters Array of ItemGA with key (Google Analytics option) and value.
 @param callback Callback with NSURLResponse and NSError.
 */
-(void) sendMessage: (NSArray<ItemGA *> *) parameters withCallBack: (CallBackSend) callback;


/**
 Send multiple messages at once.
 Example: 
          v=1&tid=UA-123456-1&cid=5555&t=pageview&dp=%2FpageA
          v=1&tid=UA-123456-1&cid=5555&t=pageview&dp=%2FpageB
          v=1&tid=UA-123456-1&cid=5555&t=pageview&dp=%2FpageC

 @param parameters Array of arrays of ItemGa.
 @param callback Callback with NSData, NSURLResponse and NSError.
 */
-(void) sendBatchMessage: (NSArray<NSArray<ItemGA *> *> *) parameters withCallBack: (CallBackSend) callback;
/**
 Method for set a required parameters to send data to Google Analytics and init session:

 @param tid The ID that distinguishes the Google Analytics property that should receive the data.
 @param cid A unique code for a specific user.
 @param hitTypeEnum The type of interaction collected for a specific user.
*/
-(void) setRequiredParameters: (NSString*) tid withCid: (NSString*) cid andHitType: (NSInteger) hitTypeEnum;

/**
 Method for set a Hit Type with HitTypeEnum.

 @param hitTypeEnum Enum value. Example: EVENT_HIT.
*/
-(void) changeHitType:(NSInteger) hitTypeEnum;

/**
 Start session in Google Analtytics.

 @param callBack Return NSData, NSURLResponse and NSError.
*/
-(void) startSession: (CallBackSend) callBack;

/**
 End session in Google Analtytics.

 @param callBack Return NSData, NSURLResponse and NSError.
*/
-(void) endSession: (CallBackSend) callBack;

/**
 Takes the value that enumerator represents.

 @param codeEnum This is Enum GAParameters
 @return value of parameter.
 */
-(NSString*) getValueEnumGAParameter: (int) codeEnum;
NS_ASSUME_NONNULL_END
@end
