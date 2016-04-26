//
//  ATJSContext.h
//  Context2d
//
//  Created by Henryk Wollik on 22/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#ifndef ATJSContext_h
#define ATJSContext_h

#define ATJSContextThrowErrorString(errStr) \
    JSContext *context = [JSContext currentContext]; \
    context.exception = [JSValue valueWithNewErrorFromMessage:errStr inContext:context];

#endif /* ATJSContext_h */
