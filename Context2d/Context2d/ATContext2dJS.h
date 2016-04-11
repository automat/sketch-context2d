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
+ (void) setVerbose:(BOOL)verbose;
+ (void) runScript:(NSString*)script andTarget:(MSLayerGroup*)target;
+ (void) runScriptAtPath:(NSString *)path andTarget:(MSLayerGroup *)target;
@end
