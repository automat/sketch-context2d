//
//  ATSketchCanvas.m
//  Context2d
//
//  Created by Henryk Wollik on 10/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import "ATSketchCanvas.h"
#import "ATCOScriptInterface.h"

@implementation ATSketchCanvas
- (instancetype) initWithTarget:(ATSketchCanvasTarget *)target{
    self = [super init];
    if(self){
        _group = [target group];
        _context = [ATSketchContext2d contextWithGroup:_group];
        _targetWidth  = [target size].width;
        _targetHeight = [target size].height;
    }
    return self;
}

+ (instancetype) canvasWithTarget:(ATSketchCanvasTarget *)target{
    return [[ATSketchCanvas alloc] initWithTarget:target];
}

- (void) setWidth:(CGFloat)width{
    [[_group frame] setWidth:width];
    _targetWidth = width;
}

//prevent auto-grow
- (CGFloat) width{
    return _targetWidth;
}

- (void) setHeight:(CGFloat)height{
    [[_group frame] setHeight:height];
    _targetHeight = height;
}

//prevent auto-grow
- (CGFloat) height{
    return _targetHeight;
}

//mimic canvas context get API
- (ATSketchContext2d *) getContext:(NSString *)type{
    return _context;
}
@end
