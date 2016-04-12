//
//  ATContext2dJS.h
//  Context2d
//
//  Created by Henryk Wollik on 10/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATSketchCanvasTarget.h"

@interface ATContext2dJS : NSObject
+ (void) setVerbose:(BOOL)verbose;
+ (void) runScript:(NSString*)script withTarget:(ATSketchCanvasTarget*) target;
+ (void) runScriptAtPath:(NSString *)path withTarget:(ATSketchCanvasTarget *)target;
@end
