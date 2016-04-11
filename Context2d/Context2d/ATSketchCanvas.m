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
- (instancetype) initWithGroup:(MSLayerGroup *)group{
    self = [super init];
    if(self){
        _group = group;
        _context = [ATSketchContext2d contextWithGroup:_group];
        _targetWidth  = [[_group frame] width];
        _targetHeight = [[_group frame] height];
        ATCOScriptPrint([_group frame]);
    }
    return self;
}

+ (instancetype) canvasWithGroup:(MSLayerGroup *)group{
    return [[ATSketchCanvas alloc] initWithGroup:group];
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
