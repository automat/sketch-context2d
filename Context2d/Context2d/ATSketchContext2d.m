//
//  ATSketchContext2d.m
//  Context2d
//
//  Created by Henryk Wollik on 30/03/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATSketchContext2d.h"
#import "ATSketchInterface.h"
#import "ATCOScriptInterface.h"

#pragma mark - ATStylePart

@implementation ATStylePart
@end

#pragma mark - ATCanvasGradient

@implementation ATCanvasGradient
- (instancetype) init{
    self = [super init];
    if(self){
        _numColorStops = 0;
        _msgradient    = [MSGradient_Class new];
    }
    return self;
}

- (void) addColorStop:(CGFloat)offset color:(NSString *)color{
    MSColor *color_ = [MSColor_Class colorWithSVGString:color];
    if(_numColorStops++ < 2){
        MSGradientStop* stop = [_msgradient stopAtIndex:(_numColorStops-1)];
        [stop setPosition:offset];
        [stop setColor:color_];
        return;
    }
    [[_msgradient stops] addObject:[MSGradientStop_Class stopWithPosition:offset color:color_]];
}

- (void) setMsgradient:(MSGradient *)msgradient{
    _numColorStops = [[msgradient stops] count];
    _msgradient    = [msgradient copy];
}

- (instancetype) copyWithZone:(NSZone *)zone{
    ATCanvasGradient *copy = [ATCanvasGradient new];
    if(copy){
        [copy setMsgradient:_msgradient];
    }
    return copy;
}
@end

@interface ATRGBAColor
@property (nonatomic) NSString* rgb;
@property (nonatomic) CGFloat a;
@end


#pragma mark - ATSketchContext2d

@implementation ATSketchContext2d

#pragma mark - Init

+ (NSDictionary *) defaultState{
    static NSDictionary *defaults;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        defaults = @{
                     //style, color
                     @"fillStyle":  @"black",
                     @"strokeStyle": @"black",
                     @"transform":   [NSAffineTransform transform],
                     //compositing
                     @"globalAlpha": @1.0,
                     @"globalCompositionOperation": @"source-over",
                     //shadows
                     @"shadowOffsetX": @0.0,
                     @"shadowOffsetY": @0.0,
                     @"shadowBlur":    @0.0,
                     @"shadowColor":   @"transparent black",
                     //line caps / joins
                     @"lineWidth":     @1.0,
                     @"lineCap":       @"butt",
                     @"lineJoin":      @"miter",
                     @"miterLimit":    @10,
                     @"lineDash":      @[],
                     @"lineDashOffset": @0,
                     //text
                     @"font":         @"10px sans-serif",
                     @"textAlign":    @"start",
                     @"textBaseline": @"alphabetic"
                     };
    });
    return defaults;
}

- (instancetype) initWithGroup:(MSLayerGroup *)group{
    self = [super init];
    if(self){
        [self resetWithGroup:group];
    }
    return self;
}

- (void) resetWithGroup:(MSLayerGroup *)group{
    _layer = nil;
    _group = group;
    _path  = nil;
    
    _state           = [NSMutableDictionary dictionaryWithDictionary:[ATSketchContext2d defaultState]];
    _statePrev       = [NSMutableDictionary dictionaryWithDictionary:[ATSketchContext2d defaultState]];
    _stateStack      = [NSMutableArray arrayWithObject:[_state copy]];
    
    _stylePartStroke = [ATStylePart new];
    _stylePartFill   = [ATStylePart new];
    _stylePartShadow = nil;
    [self applyState:_state];

}

+ (instancetype) contextWithGroup:(MSLayerGroup *)group{
    return [[ATSketchContext2d alloc]initWithGroup:group];
}

#pragma mark - State

- (void) applyStateStyleParts:(NSMutableDictionary*)state{
    //style, color
    [self setFillStyle:     [[state objectForKey:@"fillStyle"] copy]];
    [self setStrokeStyle:   [[state objectForKey:@"strokeStyle"] copy]];
    [self setLineWidth:     [[state objectForKey:@"lineWidth"] floatValue]];
    [self setLineDash:      [[state objectForKey:@"lineDash"] copy]];
    [self setLineDashOffset:[[state objectForKey:@"lineDashOffset"] floatValue]];
    [self setLineCap:       [[state objectForKey:@"lineCap"] copy]];
    
    //shadows
    [self setShadowBlur:   [[state objectForKey:@"shadowBlur"] floatValue]];
    [self setShadowOffsetX:[[state objectForKey:@"shadowOffsetX"] floatValue]];
    [self setShadowOffsetY:[[state objectForKey:@"shadowOffsetY"] floatValue]];
    [self setShadowColor:  [[state objectForKey:@"shadowColor"] copy]];
}

- (void) applyState:(NSMutableDictionary*)state{
    //transform
    [_state setObject:[state[@"transform"] copy] forKey:@"transform"];

    //compositing
    [self setGlobalAlpha:[[state objectForKey:@"globalAlpha"] floatValue]];
    [self setGlobalCompositionOperation:[state objectForKey:@"globalCompositionOperation"]];
    
    [self applyStateStyleParts:state];

    //text
}

- (void) save{
    [_stateStack addObject:[_state copy]];
}

- (void) restore{
    if([_stateStack count] == 1){
        return;
    }
    [self applyState:[_stateStack lastObject]];
    [_stateStack removeLastObject];
}

- (void) setStatePropertyWithKey:(NSString *)stateKey value:(id)value{
    [_statePrev setValue:[_state objectForKey:stateKey] forKey:stateKey];
    [_state setValue:value forKey:stateKey];
}

// updates a state value used by style parts, indicating if stylepart should be updated
- (void) setStatePropertyWithKey:(NSString *)stateKey value:(id)value stylePart:(ATStylePart *)stylePart{
    [_statePrev setValue:[_state objectForKey:stateKey] forKey:stateKey];
    stylePart.dirty = YES;
    stylePart.valid = value != nil;
    [_state setValue:value forKey:stateKey];
}

#pragma mark - Transformations

- (void) scaleX:(CGFloat)x y:(CGFloat)y{
    [[_state objectForKey:@"transform"] scaleXBy:x yBy:y];
}

- (void) rotate:(CGFloat)radians{
    [[_state objectForKey:@"transfrom"] rotateByRadians:radians];
}

- (void) translateX:(CGFloat)x y:(CGFloat)y{
    [[_state objectForKey:@"transform"] translateXBy:x yBy:y];
}

- (void) transformA:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d tx:(CGFloat)tx ty:(CGFloat)ty{
    NSAffineTransform *transform = [NSAffineTransform transform];
    NSAffineTransformStruct matrix = [transform transformStruct];
    matrix.m11 = a;
    matrix.m12 = b;
    matrix.m21 = c;
    matrix.m22 = d;
    matrix.tX = tx;
    matrix.tY = ty;
    [transform setTransformStruct:matrix];
    [[_state objectForKey:@"transform"] appendTransform:transform];
}

- (void) setTransform:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d tx:(CGFloat)tx ty:(CGFloat)ty{
    NSAffineTransform *transform = [_state objectForKey:@"transform"];
    NSAffineTransformStruct matrix = [transform transformStruct];
    matrix.m11 = a;
    matrix.m12 = b;
    matrix.m21 = c;
    matrix.m22 = d;
    matrix.tX = tx;
    matrix.tY = ty;
    [transform setTransformStruct:matrix];
}

#pragma mark - Colors and Styles

- (void) setStrokeStyle:(id)strokeStyle{
    [self setStatePropertyWithKey:@"strokeStyle" value:strokeStyle stylePart:_stylePartStroke];
}

- (id) strokeStyle{
    return [_state objectForKey:@"strokeStyle"];
}

- (void) setFillStyle: (id)fillStyle{
    [self setStatePropertyWithKey:@"fillStyle" value:fillStyle stylePart:_stylePartFill];
}

- (id) fillStyle{
    return _state[@"fillStyle"];
}

- (ATCanvasGradient *) createLinearGradientAtX0:(CGFloat)x0 y0:(CGFloat)y0 x1:(CGFloat)x1 y1:(CGFloat)y1{
    ATCanvasGradient *gradient = [ATCanvasGradient new];
    MSGradient *msgradient = [gradient msgradient];
    [msgradient setGradientType:0];
    [msgradient setFrom:CGPointMake(x0, y0)];
    [msgradient setTo:CGPointMake(x1, y1)];
    return gradient;
}

- (ATCanvasGradient *) createRadialGradientAtX0:(CGFloat)x0 y0:(CGFloat)y0 r0:(CGFloat)r0 x1:(CGFloat)x1 y1:(CGFloat)y1 r1:(CGFloat)r1{
    ATCanvasGradient *gradient = [ATCanvasGradient new];
    MSGradient *msgradient = [gradient msgradient];
    [msgradient setGradientType:1];
    [msgradient setFrom:CGPointMake(x0, y0)];
    [msgradient setTo:CGPointMake(x1, y1)];
    [msgradient setElipseLength:r0];
    return gradient;
}

#pragma mark - Compositing

- (void) setGlobalAlpha:(CGFloat)alpha{
    [self setStatePropertyWithKey:@"globalAlpha" value:[NSNumber numberWithFloat:alpha]];
}

- (CGFloat) globalAlpha{
    NSNumber *globalAlpha = _state[@"globalAlpha"];
    if(!globalAlpha){
        return 1.0;
    }
    return [globalAlpha floatValue];
}

// (default: "source-over")
- (void) setGlobalCompositionOperation:(NSString *)operation{
    if (!([operation isEqual: @""] || [operation isEqual:@""] || [operation isEqual:@""])) {
        operation = @"source-over";
    }
    [self setStatePropertyWithKey:@"globalCompositionOperation" value:operation];
}

- (NSString*) globalCompositionOperation{
    return [_state[@"globalCompositionOperation"] copy];
}

#pragma mark - Shadows

- (void) setShadowOffsetX:(CGFloat)offset{
    [self setStatePropertyWithKey:@"shadowOffsetX" value:[NSNumber numberWithFloat:offset] stylePart:_stylePartShadow];
}

- (CGFloat) shadowOffsetX{
    return [[_state objectForKey:@"shadowOffsetX"] floatValue];
}

- (void) setShadowOffsetY:(CGFloat)offset{
    [self setStatePropertyWithKey:@"shadowOffsetY" value:[NSNumber numberWithFloat:offset] stylePart:_stylePartShadow];
}

- (CGFloat) shadowOffsetY{
    return [[_state objectForKey:@"shadowOffsetY"] floatValue];
}

- (void) setShadowBlur:(CGFloat)blur{
    [self setStatePropertyWithKey:@"shadowBlur" value:[NSNumber numberWithFloat:blur] stylePart:_stylePartShadow];
}

- (CGFloat) shadowBlur{
    return [[_state objectForKey:@"shadowBlur"] floatValue];
}

- (void) setShadowColor:(NSString *)color{
    [self setStatePropertyWithKey:@"shadowColor" value:color stylePart:_stylePartShadow];
}

- (NSString *) shadowColor{
    return [_state objectForKey:@"shadowColor"];
}

#pragma mark - Line Cap / Joins

- (void) setLineWidth:(CGFloat)lineWidth{
    [self setStatePropertyWithKey:@"lineWidth" value:[NSNumber numberWithFloat:lineWidth] stylePart:_stylePartStroke];
}

- (CGFloat) lineWidth{
    NSNumber *lineWidth = _state[@"lineWidth"];
    if(!lineWidth){
        return 1.0;
    }
    return [lineWidth floatValue];
}

- (void) setLineCap:(NSString*)lineCap{
    [self setStatePropertyWithKey:@"lineCap" value:lineCap];
}

- (NSString*) lineCap{
    return [[_state objectForKey:@"lineCap"] copy];
}

- (void) setMiterLimit:(CGFloat)miterLimit{
    [self setStatePropertyWithKey:@"miterLimit" value:[NSNumber numberWithFloat:miterLimit]];
}

- (CGFloat) miterLimit{
    NSNumber *miterLimit = _state[@"miterLimit"];
    if(!miterLimit){
        return 10.0;
    }
    return [miterLimit floatValue];
}

- (void) setLineDash:(NSArray *) array{
    [self setStatePropertyWithKey:@"lineDash" value:array];
}

- (NSArray *) lineDash{
    return [[_state objectForKey:@"lineDash"] copy];
}

- (void) setLineDashOffset:(CGFloat)offset{
    [self setStatePropertyWithKey:@"lineDashOffset" value:[NSNumber numberWithFloat:offset]];
}

- (CGFloat) lineDashOffset{
    NSNumber *lineDashOffset = _state[@"lineDashOffset"];
    if(!lineDashOffset){
        return 0;
    }
    return [lineDashOffset floatValue];
}

#pragma mark - Path API

/*
- (ATRGBAColor *) parseRGBAString:(NSString*)rgba{
   // ATRGBAColor *color = [ATRGBAColor new];
    
}
 */

- (BOOL) isRGBAColor:(NSString*)color{
    
    return false;
}

- (void) addPathWithStylePartStroke:(BOOL)stroke fill:(BOOL)fill shadow:(BOOL)shadow{
    //1 element + valid segments
    if ([_path elementCount] < 1 || !_pathDirty) {
        return;
    }
    
    //transform
    NSAffineTransform *transform = [_state objectForKey:@"transform"];
    if(transform){
        [_path transformUsingAffineTransform: transform];
    }
    if(!_layer){
        _layer = [MSShapeGroup_Class shapeWithBezierPath:_path];
        [_layer setStyle:_style];
        [_group addLayers:@[_layer]];
    }
    
    NSNumber *stateGlobalAlpha = [_state objectForKey:@"globalAlpha"];
    CGFloat globalAlpha = stateGlobalAlpha ? [stateGlobalAlpha floatValue] : 1.0;
    
    //TODO: Move to partial updates, not reinitializations
    
    // update stroke
    if(stroke && _stylePartStroke.valid){
        id value = [_state objectForKey:@"strokeStyle"];
        id ref   = _stylePartStroke.ref = _stylePartStroke.ref ?
                                          _stylePartStroke.ref :
                                          [[_style borders] addNewStylePart];
        
        if([value isKindOfClass:[NSString class]]){
            MSColor *color = [MSColor_Class colorWithSVGString:value];
            [color setAlpha:([color alpha] * globalAlpha)];
            [ref setColor:color];
            [ref setFillType:0];
            
        } else if([value isKindOfClass:[ATCanvasGradient class]]){
            MSGradient *gradient = [self gradientScaled:[value msgradient] bySize:[_layer bounds].size];
            [ref setGradient:gradient];
            [ref setFillType:1];
        }
        
        [ref setThickness:[[_state objectForKey:@"lineWidth"] floatValue]];
        
        //update border options
        MSStyleBorderOptions *options = [_style borderOptions];
        
        //lineCap
        NSString *lineCap  = [_state objectForKey:@"lineCap"];
        unsigned long long lineCapStyle = [lineCap isEqualToString:@"round"]  ? 1 :
                                          [lineCap isEqualToString:@"square"] ? 2 :
                                          0; //default: butt
        [options setLineCapStyle:lineCapStyle];
        
        //lineJoin
        NSString *lineJoin = [_state objectForKey:@"lineJoin"];
        unsigned long long lineJoinStyle = [lineJoin isEqualToString:@"round"] ? 1 :
                                           [lineJoin isEqualToString:@"bevel"] ? 2 :
                                            0; //default: miter
        [options setLineJoinStyle:lineJoinStyle];
    
        //lineDash
        NSArray *lineDash = [[_state objectForKey:@"lineDash"] copy];
        //restrict to sketch just supporting 4 entries
        if(lineDash && [lineDash count] > 4){
            //...
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:4];
            for(uint i = 0; i < 4; ++i){
                [temp addObject:lineDash[i]];
            }
            lineDash = [NSArray arrayWithArray:temp];
        }
        [options setDashPattern:lineDash];
    }
    
    // update fill
    if(fill && _stylePartFill.valid){
        id value = [_state objectForKey:@"fillStyle"];
        id ref   = _stylePartFill.ref = _stylePartFill.ref ?
                                        _stylePartFill.ref :
                                        [[_style fills] addNewStylePart];
        
        if([value isKindOfClass:[NSString class]]){
            MSColor *color = [MSColor_Class colorWithSVGString:value];
            [color setAlpha:([color alpha] * globalAlpha)];
            [ref setColor:color];
            [ref setFillType:0];
            
        } else if([value isKindOfClass:[ATCanvasGradient class]]){
            MSGradient *gradient = [self gradientScaled:[value msgradient] bySize:[_layer bounds].size];
            [ref setGradient:gradient];
            [ref setFillType:1];
        }
    }
    
    if(shadow){
        CGFloat offsetX = [[_state objectForKey:@"shadowOffsetX"] floatValue];
        CGFloat offsetY = [[_state objectForKey:@"shadowOffsetY"] floatValue];
        CGFloat blur    = [[_state objectForKey:@"shadowBlur"] floatValue];
     
        if(offsetX != 0.0 || offsetY != 0.0 || blur != 0.0){
            id ref = _stylePartShadow.ref = _stylePartShadow.ref ?
                                            _stylePartShadow.ref :
                                            [[_style shadows] addNewStylePart];
        
            MSColor *color = [MSColor_Class colorWithSVGString:[_state objectForKey:@"shadowColor"]];
            [color setAlpha:([color alpha] * globalAlpha)];
            
            [ref setColor:color];
            [ref setOffsetX:offsetX];
            [ref setOffsetY:offsetY];
            [ref setBlurRadius:blur];
        }
    }
    
    _pathPaintCount++;
}

- (MSGradient *) gradientScaled:(MSGradient *)gradient bySize:(CGSize)size{
    MSGradient *scaled = [gradient copy];
    
    CGPoint from = [gradient from];
    CGPoint to   = [gradient to];
    
    CGPoint fromNew = CGPointMake(from.x / size.width, from.y / size.height);
    CGPoint toNew   = CGPointMake(to.x / size.width, to.y / size.height);
    
    [scaled setFrom:fromNew];
    [scaled setTo:toNew];
    
    return scaled;
}

- (void) beginPath{
    _path           = [NSBezierPath bezierPath];
    _pathDirty      = NO;
    _pathPaintCount = 0;
    
    //TODO: non hard copy
    _layer = nil;
    _style = [MSStyle_Class new];
    _stylePartStroke = [ATStylePart new];
    _stylePartFill   = [ATStylePart new];
    _stylePartShadow = [ATStylePart new];
    [self applyStateStyleParts:_state];
}

- (void) closePath{
    if(!_path){
        return;
    }
    [_path closePath];
}

- (void) moveToX:(CGFloat)x y:(CGFloat)y{
    if(!_path){
        return;
    }
    [_path moveToPoint:NSMakePoint(x, y)];
}

- (void) lineToX:(CGFloat)x y:(CGFloat)y{
    if(!_path){
        return;
    }
    [_path lineToPoint:NSMakePoint(x, y)];
    _pathDirty = YES;
}

- (void) quadraticCurveToCpx:(CGFloat)cpx cpy:(CGFloat)cpy x:(CGFloat)x y:(CGFloat)y{
    if(!_path){
        return;
    }
    NSPoint cp = NSMakePoint(cpx, cpy);
    [_path curveToPoint:NSMakePoint(x, y) controlPoint1:cp controlPoint2:cp];
    _pathDirty = YES;
}

- (void) bezierCurveToCp1x:(CGFloat)cp1x cp1y:(CGFloat)cp1y cp2x:(CGFloat)cp2x cp2y:(CGFloat)cp2y x:(CGFloat)x y:(CGFloat)y{
    if(!_path){
        return;
    }
    [_path curveToPoint:NSMakePoint(x,y) controlPoint1:NSMakePoint(cp1x, cp1y) controlPoint2:NSMakePoint(cp2x, cp2y)];
    _pathDirty = YES;
}

- (void) rectAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height{
    if (!_path) {
        return;
    }
    [_path appendBezierPathWithRect:NSMakeRect(x,y,width,height)];
    _pathDirty = YES;
}

- (void) fillRectAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height{
    [self beginPath];
    [self rectAtX:x y:y width:width height:height];
    [self addPathWithStylePartStroke:NO fill:YES shadow:NO];
}

- (void) strokeRectAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height{
    [self beginPath];
    [self rectAtX:x y:y width:width height:height];
    [self addPathWithStylePartStroke:YES fill:NO shadow:NO];
}

- (void) arcToX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 radius:(CGFloat)radius{
    if(!_path){
        return;
    }
    [_path appendBezierPathWithArcFromPoint:NSMakePoint(x1, y1) toPoint:NSMakePoint(x2, y2) radius:radius];
    _pathDirty = YES;
}

- (void) arcAtX:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle anticlockwise:(BOOL)anticlockwise{
    if(!_path){
        return;
    }
    startAngle = startAngle * 180.0 / M_PI;
    endAngle   = endAngle   * 180.0 / M_PI;
    [_path appendBezierPathWithArcWithCenter:NSMakePoint(x, y) radius:radius startAngle:startAngle endAngle:endAngle clockwise:anticlockwise];
    _pathDirty = YES;
}

- (void) stroke{
    if(!_path){
        return;
    }
    [self addPathWithStylePartStroke:YES fill:NO shadow:YES];
}

- (void) fill{
    if(!_path){
        return;
    }
    [self addPathWithStylePartStroke:NO fill:YES shadow:YES];
}

- (void) clip{
    
}

#pragma mark - Text


- (void) setFont:(NSString *)font{
    if(font == [_state objectForKey:@"font"]){
        return;
    }
    NSArray *tokens = [font componentsSeparatedByString:@" "];
    NSString *family;
    NSUInteger size;
   /*
    if([tokens count] < 2){
        font = DefaultFont;
        tokens = [font componentsSeparatedByString:@" "];
        size   = [tokens[1] unsignedIntegerValue];
    } else {
        if([tokens[0] rangeOfString:@"px"].location == NSNotFound){
            font = DefaultFont;
            tokens = [font componentsSeparatedByString:@" "];
        }
    }
    */
}

- (NSString*) font{
    return [[_state objectForKey:@"font"] copy];
}


@end
