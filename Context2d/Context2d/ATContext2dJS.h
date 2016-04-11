//
//  ATContext2dJS.h
//  Context2d
//
//  Created by Henryk Wollik on 10/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSLayerGroup;
@interface ATContext2dJS : NSObject
+ (void) runScript:(NSString*)script withSourceMap:(NSString*)sourceMap andTarget:(MSLayerGroup*)target;
+ (void) runScriptAtPath:(NSString *)path withSourceMap:(NSString*)sourceMap andTarget:(MSLayerGroup *)target;
@end
