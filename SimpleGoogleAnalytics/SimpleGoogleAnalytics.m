//
//  SimpleGoogleAnalytics.m
//  SimpleGoogleAnalytics
//
//  Created by Paulo Brambilla Junior on 03/02/17.
//  Copyright © 2017 Paulo Roberto Brambilla Junior. All rights reserved.
//

#import "SimpleGoogleAnalytics.h"


@interface SimpleGoogleAnalytics()
/* Tracking ID / Web Property ID
 * Required for all hit types.
 * The tracking ID / web property ID. The format is UA-XXXX-Y. All collected data is associated with this ID.
 */
@property (nonatomic, strong) NSString *tid;

/* Client ID
 * Required for all hit types.
 * This field is required if User ID (uid) is not specified in the request. This anonymously identifies a particular
 * user, device, or browser instance. For the web, this is generally stored as a first-party cookie with a two-year
 * expiration.
 * For mobile apps, this is randomly generated for each particular instance of an application install. The value of
 * this field should be a random UUID (version 4) as described in http://www.ietf.org/rfc/rfc4122.txt.
 */
@property (nonatomic, strong) NSString *cid;

/* Hit type
 * Required for all hit types.
 * The type of hit. Must be one of 'pageview', 'screenview', 'event', 'transaction', 'item', 'social',
 * 'exception', 'timing'.
 */
@property (nonatomic, strong) NSString *hitType;

@property (strong, nonatomic, readonly) NSOperationQueue *queue;
@property (strong, nonatomic) NSArray<NSString*> *objects;
@property (strong, nonatomic) NSMutableArray<NSNumber*> *keys;
@property (strong, nonatomic) NSMutableDictionary<NSNumber*, NSNumber*> *counts;
@property (strong, nonatomic) NSArray<NSString*> *hitsType;
@property (nonatomic) BOOL isStartSession;
@property (nonatomic) BOOL isEndSession;
@end

@implementation SimpleGoogleAnalytics
@synthesize objects = _objects;
@synthesize keys = _keys;
@synthesize hitsType = _hitsType;

static const int TEN_BYTES                           = 10;
static const int TWENTY_BYTES                        = 20;
static const int FORTY_BYTES                         = 40;
static const int FIFTY_BYTES                         = 50;
static const int ONE_HUNDRED_BYTES                   = 100;
static const int ONE_HUNDRED_AND_FIFTY_BYTES         = 100;
static const int FIFTY_HUNDRED_BYTES                 = 500;
static const int TWO_MEGA_BYTES                      = 2048;
static const int ONE_THOUSAND_AND_FIVE_HUNDRED_BYTES = 1500;
static const int MAX_LIMIT_PAYLOAD_DATA              = 8192;

static NSDictionary<NSNumber*,NSString*> *paramtersGA;

static NSString *url = @"https://www.google-analytics.com/collect";
static NSString *version = @"1";
NSUInteger bytes;


- (instancetype)init {
    [NSException raise:@"Instance Not Allowed"
                format:@"Use a method [ +initShared ]."];
    return nil;
}

+ (instancetype)startShared: (NSString*) tid withCid: (NSString*) cid andHitType: (NSInteger) hitTypeEnum withCallBack: (CallBackError) callBack{
    static dispatch_once_t onceToken;
    __strong static SimpleGoogleAnalytics *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[SimpleGoogleAnalytics alloc] initStart];
    });
    [instance setRequiredParameters:tid withCid:cid andHitType:hitTypeEnum withCallBack:^(NSError *__autoreleasing * _Nullable erro) {
        instance = nil;
        callBack(erro);        
    }];
    
    return instance;
}

-(instancetype) initStart{
    self = [super init];
    if (self){
        _queue = [NSOperationQueue new];
        [_queue setName:@"FGA"];
        [_queue setQualityOfService:NSQualityOfServiceUserInteractive];
        [_queue setMaxConcurrentOperationCount:1000];
        paramtersGA = [self populateParametersGA];
    }
    return self;
}

-(NSArray<NSString*>*) objects{
    if (!_objects){
        _objects = [[NSArray alloc] initWithObjects: @"aip", @"ds", @"qt", @"z", @"uid", @"sc", @"uip", @"ua", @"geoid", @"dr",
                    @"cn", @"cs", @"cm", @"ck", @"cc", @"ci", @"gclid", @"dclid", @"sr", @"vp",
                    @"de", @"sd", @"ul", @"je",@"fl", @"ni", @"dl", @"dh", @"dp", @"dt",
                    @"cd", @"cg<groupIndex>", @"linkid", @"an", @"aid", @"av", @"aiid", @"ec", @"ea", @"el",
                    @"ev", @"ti", @"ta", @"tr", @"ts", @"tt", @"in", @"ip", @"iq", @"ic",
                    @"iv", @"pr<productIndex>id", @"pr<productIndex>nm", @"pr<productIndex>br", @"pr<productIndex>ca", @"pr<productIndex>va", @"pr<productIndex>pr", @"pr<productIndex>qt", @"pr<productIndex>cc", @"pr<productIndex>ps",
                    @"pr<productIndex>cd<dimensionIndex>", @"pr<productIndex>cm<metricIndex>", @"pa", @"ti", @"ta", @"tr", @"tt", @"ts", @"tcc", @"pal",
                    @"cos", @"col", @"il<listIndex>nm", @"il<listIndex>pi<productIndex>id", @"il<listIndex>pi<productIndex>nm", @"il<listIndex>pi<productIndex>br", @"il<listIndex>pi<productIndex>ca", @"il<listIndex>pi<productIndex>va", @"il<listIndex>pi<productIndex>ps", @"il<listIndex>pi<productIndex>pr",
                    @"il<listIndex>pi<productIndex>cd<dimensionIndex>", @"il<listIndex>pi<productIndex>cm<metricIndex>", @"promo<promoIndex>id", @"promo<promoIndex>nm", @"promo<promoIndex>cr", @"promo<promoIndex>ps", @"promoa", @"cu", @"sn", @"sa",
                    @"st", @"utc", @"utv", @"utt", @"utl", @"plt", @"dns", @"pdt", @"rrt", @"tcp",
                    @"srt", @"dit", @"clt", @"exd", @"exf", @"cd<dimensionIndex>", @"cm<metricIndex>", @"xid", @"xvar", nil];
    }
    
    return _objects;
}

-(NSArray<NSString*>*) hitsType{
    if (!_hitsType){
        _hitsType = [[NSArray alloc] initWithObjects:@"event", @"exception", @"item", @"pageview", @"screenview", @"social", @"transaction", @"timing", nil];
    }
    return _hitsType;
}

-(NSMutableArray<NSNumber*>*) keys{
    if (!_keys){
        _keys = [NSMutableArray new];
        
        for (int i = 0; i < [self.objects count]; i++){
            [_keys addObject: [[NSNumber alloc] initWithInt:i]];
        }
    }
    
    return _keys;
}

-(NSDictionary*) populateParametersGA{
    return [[NSDictionary alloc] initWithObjects:self.objects forKeys:self.keys];
}

- (NSError *)validateParameters: (NSArray<ItemGA *> *) parameters{
    NSDictionary *dictionary;
    NSError *error;
    
    if (!parameters){
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Parameters not is null.", @1, nil];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
    }else{
        for (ItemGA *item in parameters){
            if (!item){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"A itemGA is null.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (!item.codeEnum || (item.codeEnum < 0 || item.codeEnum >= ENUM_COUNT)){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Code Enum not exist.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (!item.key || [self isStringEmpty:item.key]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Key is empty or null.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (!item.value || [self isStringEmpty:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Value is empty or null.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }
            
            if (item.codeEnum == ANONYMIZE_IP_GAPARAMETERS && ([item.value compare:@"1"] !=	NSOrderedSame && [item.value compare:@"0"] != NSOrderedSame)){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value for ANONYMIZE_IP_GAPARAMETERS must be equal to 0 or 1.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == QUEUE_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of QUEUE_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == QUEUE_TIME_GAPARAMETERS){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of QUEUE_TIME_GAPARAMETERS can not be less than 0.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == DOCUMENT_REFERRER_GAPARAMETERS && [self countBytesInString:item.value] > TWO_MEGA_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of DOCUMENT_REFERRER_GAPARAMETERS can not be greater than %d bytes.", TWO_MEGA_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CAMPAIGN_ORIGIN_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of CAMPAIGN_ORIGIN_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CAMPAIGN_MEDIA_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of CAMPAIGN_MEDIA_GAPARAMETERS can not be greater than %d bytes.", FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CAMPAIGN_KEYWORD_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of CAMPAIGN_KEYWORD_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CAMPAIGN_CONTENT_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of CAMPAIGN_CONTENT_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CAMPAIGN_ID_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of CAMPAIGN_ID_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == SCREEN_RESOLUTION_GAPARAMETERS && [self countBytesInString:item.value] > TWENTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of SCREEN_RESOLUTION_GAPARAMETERS can not be greater than %d bytes.", TWENTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == VIEWPORT_SIZE_GAPARAMETERS && [self countBytesInString:item.value] > TWENTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of SCREEN_RESOLUTION_GAPARAMETERS can not be greater than %d bytes.", TWENTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == DOCUMENT_ENCODING_GAPARAMETERS && [self countBytesInString:item.value] > TWENTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of DOCUMENT_ENCODING_GAPARAMETERS can not be greater than %d bytes.", TWENTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == SCREEN_COLORS_GAPARAMETERS && [self countBytesInString:item.value] > TWENTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of SCREEN_COLORS_GAPARAMETERS can not be greater than %d bytes.", TWENTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == USER_LANGUAGE_GAPARAMETERS && [self countBytesInString:item.value] > TWENTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of USER_LANGUAGE_GAPARAMETERS can not be greater than %d bytes.", TWENTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == JAVA_ENABLED_GAPARAMETERS && ([item.value compare:@"1"] != NSOrderedSame && [item.value compare:@"0"] != NSOrderedSame)){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value for JAVA_ENABLED_GAPARAMETERS must be equal to 0 or 1.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == FLASH_VERSION_GAPARAMETERS && [self countBytesInString:item.value] > TWENTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of FLASH_VERSION_GAPARAMETERS can not be greater than %d bytes.", TWENTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == NON_INTERACTION_HIT_GAPARAMETERS && ([item.value compare:@"1"] != NSOrderedSame && [item.value compare:@"0"] != NSOrderedSame)){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value for NON_INTERACTION_HIT_GAPARAMETERS must be equal to 0 or 1.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == DOCUMENT_LOCATION_URL_GAPARAMETERS && [self countBytesInString:item.value] > TWO_MEGA_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of DOCUMENT_LOCATION_URL_GAPARAMETERS can not be greater than %d bytes.", TWO_MEGA_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == DOCUMENT_HOST_NAME_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of DOCUMENT_HOST_NAME_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == DOCUMENT_PATH_GAPARAMETERS && [self countBytesInString:item.value] > TWO_MEGA_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of DOCUMENT_PATH_GAPARAMETERS can not be greater than %d bytes.", TWO_MEGA_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == DOCUMENT_TITLE_GAPARAMETERS && [self countBytesInString:item.value] > ONE_THOUSAND_AND_FIVE_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of DOCUMENT_TITLE_GAPARAMETERS can not be greater than %d bytes.", ONE_THOUSAND_AND_FIVE_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == SCREEN_NAME_GAPARAMETERS && [self countBytesInString:item.value] > TWO_MEGA_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of SCREEN_NAME_GAPARAMETERS can not be greater than %d bytes.", TWO_MEGA_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CONTENT_GROUP_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of CONTENT_GROUP_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == APPLICATION_NAME_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of APPLICATION_NAME_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == APPLICATION_ID_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_AND_FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of APPLICATION_ID_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_AND_FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == APPLICATION_VERSION_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of APPLICATION_VERSION_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == APPLICATION_INSTALLER_ID_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_AND_FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of APPLICATION_INSTALLER_ID_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_AND_FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == EVENT_CATEGORY_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_AND_FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of EVENT_CATEGORY_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_AND_FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == EVENT_ACTION_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of EVENT_ACTION_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == EVENT_LABEL_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of EVENT_LABEL_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == EVENT_VALUE_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of EVENT_VALUE_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == TRANSACTION_ID_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of TRANSACTION_ID_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == TRANSACTION_AFFILIATION_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of TRANSACTION_AFFILIATION_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == TRANSACTION_REVENUE_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of TRANSACTION_REVENUE_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == TRANSACTION_SHIPPING_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of TRANSACTION_SHIPPING_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == TRANSACTION_TAX_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of TRANSACTION_TAX_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == ITEM_NAME_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of ITEM_NAME_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == ITEM_PRICE_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of ITEM_PRICE_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == ITEM_QUANTITY_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of ITEM_QUANTITY_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == ITEM_CODE_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of ITEM_CODE_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == ITEM_CATEGORY_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of ITEM_CATEGORY_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_SKU_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of PRODUCT_SKU_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_NAME_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of PRODUCT_NAME_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_BRAND_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of PRODUCT_BRAND_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_CATEGORY_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of PRODUCT_CATEGORY_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_VARIANT_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of PRODUCT_VARIANT_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_PRICE_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PRODUCT_PRICE_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_QUANTITY_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PRODUCT_QUANTITY_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_COUPON_CODE_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of PRODUCT_COUPON_CODE_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_POSITION_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PRODUCT_POSITION_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_CUSTOM_METRIC_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PRODUCT_CUSTOM_METRIC_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == REVENUE_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of REVENUE_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == TAX_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of TAX_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == SHIPPING_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of SHIPPING_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CHECKOUT_STAGE_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of CHECKOUT_STAGE_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_IMPRESSION_POSITION_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PRODUCT_IMPRESSION_POSITION_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_IMPRESSION_PRICE_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PRODUCT_IMPRESSION_PRICE_GAPARAMETERS is not a currency number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PRODUCT_IMPRESSION_CUSTOM_METRIC_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PRODUCT_IMPRESSION_CUSTOM_METRIC_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CURRENCY_CODE_GAPARAMETERS && [self countBytesInString:item.value] > TEN_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of CURRENCY_CODE_GAPARAMETERS can not be greater than %d bytes.", TEN_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == SOCIAL_NETWORK_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of SOCIAL_NETWORK_GAPARAMETERS can not be greater than %d bytes.", FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == SOCIAL_ACTION_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of SOCIAL_ACTION_GAPARAMETERS can not be greater than %d bytes.", FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == SOCIAL_ACTION_TARGET_GAPARAMETERS && [self countBytesInString:item.value] > TWO_MEGA_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of SOCIAL_ACTION_TARGET_GAPARAMETERS can not be greater than %d bytes.", TWO_MEGA_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == USER_TIMING_CATEGORY_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_AND_FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of USER_TIMING_CATEGORY_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_AND_FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == USER_TIMING_VARIABLE_NAME_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of USER_TIMING_VARIABLE_NAME_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == USER_TIMING_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of USER_TIMING_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == USER_TIMING_LABEL_GAPARAMETERS && [self countBytesInString:item.value] > FIFTY_HUNDRED_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of USER_TIMING_LABEL_GAPARAMETERS can not be greater than %d bytes.", FIFTY_HUNDRED_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PAGE_LOAD_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PAGE_LOAD_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == DNS_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of DNS_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == PAGE_DOWNLOAD_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of PAGE_DOWNLOAD_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == REDIRECT_RESPONSE_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of REDIRECT_RESPONSE_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == TCP_CONNECT_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of TCP_CONNECT_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == SERVER_RESPONSE_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of SERVER_RESPONSE_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == DOM_INTERACTIVE_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of DOM_INTERACTIVE_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CONTENT_LOAD_TIME_GAPARAMETERS && ![self stringIsIntegerNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of CONTENT_LOAD_TIME_GAPARAMETERS is not a interger number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == EXCEPTION_DESCRIPTION_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_AND_FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of EXCEPTION_DESCRIPTION_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_AND_FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == IS_FATAL_EXCEPTION_GAPARAMETERS && ([item.value compare:@"1"] != NSOrderedSame && [item.value compare:@"0"] != NSOrderedSame)){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value for IS_FATAL_EXCEPTION_GAPARAMETERS must be equal to 0 or 1.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CUSTOM_DIMENSION_GAPARAMETERS && [self countBytesInString:item.value] > ONE_HUNDRED_AND_FIFTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of CUSTOM_DIMENSION_GAPARAMETERS can not be greater than %d bytes.", ONE_HUNDRED_AND_FIFTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }else if (item.codeEnum == CUSTOM_METRIC_GAPARAMETERS && ![self stringIsNumber:item.value]){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"The value of CUSTOM_METRIC_GAPARAMETERS is not a number.", @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
                break;
            }else if (item.codeEnum == EXPERIMENT_ID_GAPARAMETERS && [self countBytesInString:item.value] > FORTY_BYTES){
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat: @"The size of the value of EXPERIMENT_ID_GAPARAMETERS can not be greater than %d bytes.", FORTY_BYTES ], @1, nil];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSKeyValueValidationError userInfo:dictionary];
                break;
            }
        }
    }
    
    return error;
}

-(void) sendBatchMessage: (NSArray<NSArray<ItemGA *> *> *) parameters withCallBack: (CallBackSend) callback{
    NSDictionary *dictionary;
    NSError *error;
    NSMutableArray<ItemGA *> *array = [NSMutableArray new];
    
    if (!parameters){
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Parameters not is null.", @1, nil];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
        
        callback(nil, &error);
    }else{
        for (int i = 0; i < [parameters count]; i++) {
            NSArray<ItemGA *> *line = [parameters objectAtIndex:i];
            
            error = [self validateParameters:line];
            
            if (error){
                array = nil;
                callback(nil, &error);
                break;
            }else{
                [array addObjectsFromArray:line];
            }
        }
        
        [self sendMessage:array withCallBack:^(NSURLResponse * _Nullable response, NSError *__autoreleasing  _Nullable * _Nullable erro) {
            callback(response, erro);
        }];
    }
}

-(void) sendMessage: (NSArray<ItemGA *> *) parameters withCallBack: (CallBackSend) callback{
    //Verify if Array populated. If populate send a message.
    
    NSDictionary *dictionary;
    NSError *error = [self validateParameters:parameters];
        
    if (error){
        callback(nil, &error);
    }else{
        NSMutableURLRequest *request = [self configRequestWithArray:parameters];
        
        if ([request.HTTPBody length] > MAX_LIMIT_PAYLOAD_DATA){
            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat: @"The size of PAYLOAD_DATA can not be greater than %d bytes.", MAX_LIMIT_PAYLOAD_DATA ], @1, nil];
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSValidationErrorMaximum userInfo:dictionary];
            
            callback(nil, &error);
        }else{
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                                  delegate:nil
                                                             delegateQueue:self.queue];
            
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                callback(response, &error);
            }];
            
            
            [task resume];
        }
    }
}

-(NSMutableURLRequest*) configRequestWithArray: (NSArray<ItemGA *> *) parameters{
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL: [NSURL URLWithString:url]];
    [request setHTTPMethod:@"Post"];
    [request setHTTPBody:[self createPostData:parameters]];
    
    return request;
}

-(NSData *) createPostData: (NSArray<ItemGA *> *) parameters {
    NSString *aux = [self getRequeridParameters];
    
    for (ItemGA *item in parameters){
        aux = [aux stringByAppendingFormat: @"&%@=%@", item.key, item.value];
    }
    
    return [aux dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion:YES];
}

-(NSUInteger) countBytesInString : (NSString*) text{
    return [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

-(NSString*) getRequeridParameters{
    return [[NSString alloc] initWithFormat: @"v=%@&tid=%@&cid=%@&t=%@",version, self.tid, self.cid, self.hitType];
}

-(void) setRequiredParameters: (NSString*) tid withCid: (NSString*) cid andHitType: (NSInteger) hitTypeEnum withCallBack: (CallBackError) callBack{
    NSDictionary *dictionary;
    NSError *error;
    
    if (!tid){
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"tid not null.", @1, nil];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
    }else if ([self isStringEmpty:tid]){
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"tid not empty.", @1, nil];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
    }else if (!cid){
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"cid not null.", @1, nil];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
    }else if([self isStringEmpty:cid]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"cid not empty.", @1, nil];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
    }else if (hitTypeEnum >= [self.hitsType count] || hitTypeEnum < 0){
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"hittype not found.", @1, nil];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:dictionary];
    }else{
        _tid = tid;
        _cid = cid;
        _hitType = [self.hitsType objectAtIndex:hitTypeEnum];
    }
    
    if (error){
        callBack(&error);
    }else {
        callBack(nil);
    }
    
}

-(void) changeHitType:(NSInteger) hitTypeEnum{
    self.hitType = [self.hitsType objectAtIndex:hitTypeEnum];
}

-(void) startEndSession: (BOOL) start withCallBack: (CallBackSend) callBack{
    ItemGA *item = [[ItemGA alloc] initWithCodEnumParameterGA:SESSION_CONTROL_GAPARAMETERS andKey: [@"" stringByAppendingString: [paramtersGA objectForKey:[NSNumber numberWithInt:SESSION_CONTROL_GAPARAMETERS]]] andValue:start ? @"start" : @"end"];
    
    NSArray<ItemGA *> *parameters = [NSArray arrayWithObject:item];
  
  
    [self sendMessage:parameters withCallBack:^(NSURLResponse * _Nullable response, NSError *__autoreleasing * _Nullable erro) {
        callBack(response, erro);
    }];
}

-(void) startSession: (CallBackSend) callBack{
    if (!self.isStartSession){
        [self startEndSession:YES withCallBack:^(NSURLResponse * _Nullable response, NSError *__autoreleasing * _Nullable erro) {
            if (!erro){
                self.isStartSession = YES;
                self.isEndSession = NO;
            }else{
                self.isStartSession = NO;
            }
            
            callBack(response, erro);
        }];
    }
}

-(void) endSession: (CallBackSend) callBack{
    if (!self.isEndSession){
        [self startEndSession:NO withCallBack:^(NSURLResponse * _Nullable response, NSError *__autoreleasing * _Nullable erro) {
            if (!erro){
                self.isEndSession = YES;
                self.isStartSession = NO;
            }else{
                self.isEndSession = NO;
            }
            
            callBack(response, erro);
        }];
    }
}

-(BOOL) isStringEmpty: (NSString*) text{
    return [[self trim: text] isEqualToString:@""];
}

-(NSString*) trim: (NSString*) text{
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

-(BOOL) stringIsIntegerNumber:(NSString*) string{
    NSNumberFormatter *f = [NSNumberFormatter new];
    NSNumber *number = [f numberFromString:string];
    
    if (number){
        if ([number compare: [NSNumber numberWithInt:[number intValue]]] == NSOrderedSame){
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

-(BOOL) stringIsNumber:(NSString*) string{
    NSNumberFormatter *f = [NSNumberFormatter new];
    NSNumber *number = [f numberFromString:string];
    if (number){
        return YES;
    }else{
        return NO;
    }
}

-(NSNumber*) stringToNumber:(NSString*) string{
    NSNumberFormatter *f = [NSNumberFormatter new];
    NSNumber *number = [f numberFromString:string];
    
    if (number){
        return number;
    }else{
        return @-1;
    }
}
@end
