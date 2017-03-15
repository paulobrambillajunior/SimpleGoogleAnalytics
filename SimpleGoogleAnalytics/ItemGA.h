//
//  itemGA.h
//  TesteGA
//
//  Created by Paulo Brambilla Junior on 12/03/17.
//  Copyright © 2017 Paulo Roberto Brambilla Junior. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemGA : NSObject
@property (nonatomic) int codeEnum;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;


/**
 Init a ItemGA with parameters above.

 @param codeEnum Enum code GAParameters
 @param key Google Analytics option.
 @param value Key value.
 @return Objetc to ItemGA instantiated.
 */
-(instancetype) initWithCodEnumParameterGA: (int) codeEnum andKey: (NSString*) key andValue:(NSString*) value;
@end
