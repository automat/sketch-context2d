//
//  ATCOScriptInterface.h
//  Context2d
//
//  Created by Henryk Wollik on 08/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#ifndef ATCOScriptInterface_h
#define ATCOScriptInterface_h

#define COScript_Class NSClassFromString(@"COScript")
@interface COScript
+ (instancetype) currentCOScript;
- (void) print:(id)o;
@end

#define ATCOScriptPrint(o) [[COScript_Class currentCOScript] print:o]

#endif /* ATCOScriptInterface_h */
