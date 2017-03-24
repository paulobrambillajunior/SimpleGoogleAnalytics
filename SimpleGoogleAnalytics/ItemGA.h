//
//  itemGA.h
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
