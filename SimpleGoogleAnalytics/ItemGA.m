//
//  itemGA.m
//  TesteGA
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
