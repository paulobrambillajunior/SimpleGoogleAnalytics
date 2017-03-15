//
//  itemGA.m
//  TesteGA
//
//  Created by Paulo Brambilla Junior on 12/03/17.
//  Copyright © 2017 Paulo Roberto Brambilla Junior. All rights reserved.
//

#import "ItemGA.h"

@implementation ItemGA
-(instancetype) initWithCodEnumParameterGA: (int) codeEnum andKey: (NSString*) key andValue:(NSString*) value{
    self = [super init];
    if (self){
        _codeEnum = codeEnum;
        _key = key;
        _value = value;
    }
    return self;
}
@end
