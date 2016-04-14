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

//state
//style, color
static NSString *const kATStateFillStyle   = @"fillStyle";
static NSString *const kATStateStrokeStyle = @"strokeStyle";
static NSString *const kATStateTransform   = @"transform";
//compositing
static NSString *const kATStateGlobalAlpha = @"globalAlpha";
static NSString *const kATStateGlobalCompositeOperation = @"globalCompositeOperation";
//shadows
static NSString *const kATStateShadowOffsetX = @"shadowOffsetX";
static NSString *const kATStateShadowOffsetY = @"shadowOffsetY";
static NSString *const kATStateShadowBlur    = @"shadowBlur";
static NSString *const kATStateShadowColor   = @"shadowColor";
//line caps / joins
static NSString *const kATStateLineWidth      = @"lineWidth";
static NSString *const kATStateLineCap        = @"lineCap";
static NSString *const kATStateLineJoin       = @"lineJoin";
static NSString *const kATStateMiterLimit     = @"miterLimit";
static NSString *const kATStateLineDash       = @"lineDash";
static NSString *const kATStateLineDashOffset = @"lineDashOffset";
//text
static NSString *const kATStateFont         = @"font";
static NSString *const kATStateTextAlign    = @"textAlign";
static NSString *const kATStateTextBaseline = @"textBaseline";

//compositing
static NSString *const kATGlobalCompositeOperationSourceAtop      = @"source-atop";
static NSString *const kATGlobalCompositeOperationSourceIn        = @"source-in";
static NSString *const kATGlobalCompositeOperationSourceOut       = @"source-out";
static NSString *const kATGlobalCompositeOperationSourceOver      = @"source-over";
static NSString *const kATGlobalCompositeOperationDestinationAtop = @"destination-atop";
static NSString *const kATGlobalCompositeOperationDestinationIn   = @"destination-in";
static NSString *const kATGlobalCompositeOperationDestinationOut  = @"destination-out";
static NSString *const kATGlobalCompositeOperationDestinationOver = @"destination-over";
static NSString *const kATGlobalCompositeOperationLighter         = @"lighter";
static NSString *const kATGlobalCompositeOperationCopy            = @"copy";
static NSString *const kATGlobalCompositeOperationXor             = @"xor";

//lineCap
static NSString *const kATLineCapButt   = @"butt";
static NSString *const kATLineCapRound  = @"round";
static NSString *const kATLineCapSquare = @"square";
//lineJoin
static NSString *const kATLineJoinRound = @"round";
static NSString *const kATLineJoinBevel = @"bevel";
static NSString *const kATLineJoinMiter = @"miter";
//winding rule
static NSString *const kATWindingRuleNonZero = @"nonzero";
static NSString *const kATWindingRuleEvenOdd = @"evenodd";

static NSString *const kATDefaultFont = @"10px sans-serif";
//textalign
static NSString *const kATTextAlignStart  = @"start";
static NSString *const kATTextAlignEnd    = @"end";
static NSString *const kATTextAlignLeft   = @"left";
static NSString *const kATTextAlignRight  = @"right";
static NSString *const kATTextAlignCenter = @"center";
//textbaseline
static NSString *const kATTextBaselineTop         = @"top";
static NSString *const kATTextBaselineHanging     = @"hanging";
static NSString *const kATTextBaselineMiddle      = @"middle";
static NSString *const kATTextBaselineAlphabetic  = @"alphabetic";
static NSString *const kATTextBaselineIdeographic = @"ideographic";
static NSString *const kATTextBaselineBottom      = @"bottom";

@implementation ATSketchContext2d

#pragma mark - Init

+ (NSDictionary *) defaultState{
    static NSDictionary *defaults;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        defaults = @{
                     //style, color
                     kATStateFillStyle:   @"black",
                     kATStateStrokeStyle: @"black",
                     kATStateTransform:   [NSAffineTransform transform],
                     //compositing
                     kATStateGlobalAlpha: @1.0,
                     kATStateGlobalCompositeOperation: @"source-over",
                     //shadows
                     kATStateShadowOffsetX: @0.0,
                     kATStateShadowOffsetY: @0.0,
                     kATStateShadowBlur:    @0.0,
                     kATStateShadowColor:   @"transparent black",
                     //line caps / joins
                     kATStateLineWidth:     @1.0,
                     kATStateLineCap:       [kATLineCapButt copy],
                     kATStateLineJoin:      [kATLineJoinMiter copy],
                     kATStateMiterLimit:     @10,
                     kATStateLineDash:       @[],
                     kATStateLineDashOffset: @0,
                     //text
                     kATStateFont:         [kATDefaultFont copy],
                     kATStateTextAlign:    [kATTextAlignLeft copy],
                     kATStateTextBaseline: [kATTextBaselineAlphabetic copy]
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
    
    _state      = [NSMutableDictionary dictionaryWithDictionary:[ATSketchContext2d defaultState]];
    _statePrev  = [NSMutableDictionary dictionaryWithDictionary:[ATSketchContext2d defaultState]];
    _stateStack = [NSMutableArray arrayWithObject:[_state copy]];
    
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
    [self setFillStyle:      [state objectForKey:kATStateFillStyle]];
    [self setStrokeStyle:    [state objectForKey:kATStateStrokeStyle]];
    [self setLineWidth:     [[state objectForKey:kATStateLineWidth] floatValue]];
    [self setLineDash:       [state objectForKey:kATStateLineDash]];
    [self setLineDashOffset:[[state objectForKey:kATStateLineDashOffset] floatValue]];
    [self setLineCap:        [state objectForKey:kATStateLineCap]];
    [self setLineJoin:       [state objectForKey:kATStateLineJoin]];
    
    //shadows
    [self setShadowBlur:   [[state objectForKey:kATStateShadowBlur] floatValue]];
    [self setShadowOffsetX:[[state objectForKey:kATStateShadowOffsetX] floatValue]];
    [self setShadowOffsetY:[[state objectForKey:kATStateShadowOffsetY] floatValue]];
    [self setShadowColor:   [state objectForKey:kATStateShadowColor]];
}

- (void) applyState:(NSMutableDictionary*)state{
    //style parts
    [self applyStateStyleParts:state];
    
    //transform
    [_state setObject:[state[kATStateTransform] copy] forKey:kATStateTransform];

    //compositing
    [self setGlobalAlpha:              [[state objectForKey:kATStateGlobalAlpha] floatValue]];
    [self setGlobalCompositeOperation:[state objectForKey:kATStateGlobalCompositeOperation]];

    //text
    [self setFont:        [state objectForKey:kATStateFont]];
    [self setTextAlign:   [state objectForKey:kATStateTextAlign]];
    [self setTextBaseline:[state objectForKey:kATStateTextBaseline]];
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
    [[_state objectForKey:kATStateTransform] scaleXBy:x yBy:y];
}

- (void) rotate:(CGFloat)radians{
    [[_state objectForKey:kATStateTransform] rotateByRadians:radians];
}

- (void) translateX:(CGFloat)x y:(CGFloat)y{
    [[_state objectForKey:kATStateTransform] translateXBy:x yBy:y];
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
    [[_state objectForKey:kATStateTransform] appendTransform:transform];
}

- (void) setTransform:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d tx:(CGFloat)tx ty:(CGFloat)ty{
    NSAffineTransform *transform = [_state objectForKey:kATStateTransform];
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
    [self setStatePropertyWithKey:kATStateStrokeStyle
                            value:strokeStyle ? [strokeStyle copy] : @"000000"
                        stylePart:_stylePartStroke];
}

- (id) strokeStyle{
    return [_state objectForKey:kATStateStrokeStyle];
}

- (void) setFillStyle: (id)fillStyle{
    [self setStatePropertyWithKey:kATStateFillStyle
                            value:fillStyle ? [fillStyle copy] : @"000000"
                        stylePart:_stylePartFill];
}

- (id) fillStyle{
    return _state[kATStateFillStyle];
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
    [self setStatePropertyWithKey:kATStateGlobalAlpha value:[NSNumber numberWithFloat:alpha]];
}

- (CGFloat) globalAlpha{
    NSNumber *globalAlpha = _state[kATStateGlobalAlpha];
    if(!globalAlpha){
        return 1.0;
    }
    return [globalAlpha floatValue];
}

// (default: "source-over")
- (void) setGlobalCompositeOperation:(NSString *)operation{
    [self setStatePropertyWithKey:kATStateGlobalCompositeOperation
                            value:!([operation isEqualToString:kATGlobalCompositeOperationSourceAtop] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationSourceIn] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationSourceOut] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationSourceOver] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationDestinationAtop] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationDestinationIn] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationDestinationOut] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationDestinationOver] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationLighter] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationCopy] ||
                                    [operation isEqualToString:kATGlobalCompositeOperationXor]) ?
                                   [kATGlobalCompositeOperationSourceOver copy] :
                                   [operation copy]];
}

- (NSString*) globalCompositeOperation{
    return [_state[kATStateGlobalCompositeOperation] copy];
}

#pragma mark - Shadows

- (void) setShadowOffsetX:(CGFloat)offset{
    [self setStatePropertyWithKey:kATStateShadowOffsetX
                            value:[NSNumber numberWithFloat:offset]
                        stylePart:_stylePartShadow];
}

- (CGFloat) shadowOffsetX{
    return [[_state objectForKey:kATStateShadowOffsetX] floatValue];
}

- (void) setShadowOffsetY:(CGFloat)offset{
    [self setStatePropertyWithKey:kATStateShadowOffsetY
                            value:[NSNumber numberWithFloat:offset]
                        stylePart:_stylePartShadow];
}

- (CGFloat) shadowOffsetY{
    return [[_state objectForKey:kATStateShadowOffsetY] floatValue];
}

- (void) setShadowBlur:(CGFloat)blur{
    [self setStatePropertyWithKey:kATStateShadowBlur
                            value:[NSNumber numberWithFloat:blur]
                        stylePart:_stylePartShadow];
}

- (CGFloat) shadowBlur{
    return [[_state objectForKey:kATStateShadowBlur] floatValue];
}

- (void) setShadowColor:(NSString *)color{
    [self setStatePropertyWithKey:kATStateShadowColor
                            value:color ? [color copy] : @"000000"
                        stylePart:_stylePartShadow];
}

- (NSString *) shadowColor{
    return [_state objectForKey:kATStateShadowColor];
}

#pragma mark - Line Cap / Joins

- (void) setLineWidth:(CGFloat)lineWidth{
    [self setStatePropertyWithKey:kATStateLineWidth
                            value:[NSNumber numberWithFloat:lineWidth]
                        stylePart:_stylePartStroke];
}

- (CGFloat) lineWidth{
    NSNumber *lineWidth = _state[kATStateLineWidth];
    if(!lineWidth){
        return 1.0;
    }
    return [lineWidth floatValue];
}

- (void) setLineCap:(NSString*)lineCap{
    [self setStatePropertyWithKey:kATStateLineCap value:lineCap ? [lineCap copy] : [kATLineCapButt copy]];
}

- (NSString*) lineCap{
    return [[_state objectForKey:kATStateLineCap] copy];
}

- (void) setLineJoin:(NSString *)lineJoin{
    [self setStatePropertyWithKey:kATStateLineJoin value:lineJoin ? [lineJoin copy] : [kATLineJoinMiter copy]];
}

- (NSString *) lineJoin{
    return [[_state objectForKey:kATStateLineJoin] copy];
}

- (void) setMiterLimit:(CGFloat)miterLimit{
    [self setStatePropertyWithKey:kATStateMiterLimit value:[NSNumber numberWithFloat:miterLimit]];
}

- (CGFloat) miterLimit{
    NSNumber *miterLimit = _state[kATStateMiterLimit];
    if(!miterLimit){
        return 10.0;
    }
    return [miterLimit floatValue];
}

- (void) setLineDash:(NSArray *) array{
    [self setStatePropertyWithKey:kATStateLineDash value:array ? [array copy] : @{}];
}

- (NSArray *) getLineDash{
    return [[_state objectForKey:kATStateLineDash] copy];
}

- (void) setLineDashOffset:(CGFloat)offset{
    [self setStatePropertyWithKey:kATStateLineDashOffset value:[NSNumber numberWithFloat:offset]];
}

- (CGFloat) lineDashOffset{
    NSNumber *lineDashOffset = _state[kATStateLineDashOffset];
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

- (MSColor*)colorWithSVGStringWithGlobalAlpha:(NSString *)value{
    NSNumber *stateGlobalAlpha = [_state objectForKey:kATStateGlobalAlpha];
    CGFloat globalAlpha = stateGlobalAlpha ? [stateGlobalAlpha floatValue] : 1.0;
    
    MSColor *color = [MSColor_Class colorWithSVGString:value];
    [color setAlpha:([color alpha] * globalAlpha)];
    return color;
}

- (void) addPathWithStylePartStroke:(BOOL)stroke fill:(BOOL)fill shadow:(BOOL)shadow{
    //todo: add style add if path has not been altered, no need to repaint same paths
    
    //1 element + valid segments
    if ([_path elementCount] < 1 || !_pathDirty) {
        return;
    }
    
    //transform
    NSAffineTransform *transform = [_state objectForKey:kATStateTransform];
    if(transform){
        [_path transformUsingAffineTransform: transform];
    }
    if(!_layer){
        _layer = [MSShapeGroup_Class shapeWithBezierPath:_path];
        [_layer setStyle:_style];
        [_group addLayers:@[_layer]];
    }
    //TODO: Move to partial updates, not reinitializations
    
    // update stroke
    if(stroke && _stylePartStroke.valid){
        id value = [_state objectForKey:kATStateStrokeStyle];
        id ref   = _stylePartStroke.ref = (!_stylePartStroke.ref || _pathPaintCount > 0) ?
                                          [[_style borders] addNewStylePart] :
                                          _stylePartStroke.ref;
        
        if([value isKindOfClass:[NSString class]]){
            [ref setColor: [self colorWithSVGStringWithGlobalAlpha:value]];
            [ref setFillType:0];
            
        } else if([value isKindOfClass:[ATCanvasGradient class]]){
            MSGradient *gradient = [self gradientScaled:[value msgradient] bySize:[_layer bounds].size];
            [ref setGradient:gradient];
            [ref setFillType:1];
        }
        
        [ref setThickness:[[_state objectForKey:kATStateLineWidth] floatValue]];
        
        //update border options
        MSStyleBorderOptions *options = [_style borderOptions];
        
        //lineCap
        NSString *lineCap  = [_state objectForKey:kATStateLineCap];
        unsigned long long lineCapStyle = [lineCap isEqualToString:kATLineCapRound]  ? 1 :
                                          [lineCap isEqualToString:kATLineCapSquare] ? 2 :
                                          0; //default: butt
        [options setLineCapStyle:lineCapStyle];
        
        //lineJoin
        NSString *lineJoin = [_state objectForKey:kATStateLineJoin];
        unsigned long long lineJoinStyle = [lineJoin isEqualToString:kATLineJoinRound] ? 1 :
                                           [lineJoin isEqualToString:kATLineJoinBevel] ? 2 :
                                           0; //default: miter
        [options setLineJoinStyle:lineJoinStyle];
    
        //lineDash
        NSArray *lineDash = [[_state objectForKey:kATStateLineDash] copy];
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
        id value = [_state objectForKey:kATStateFillStyle];
        id ref   = _stylePartFill.ref = (!_stylePartFill.ref || _pathPaintCount > 0) ?
                                        [[_style fills] addNewStylePart] :
                                        _stylePartFill.ref;
        
        if([value isKindOfClass:[NSString class]]){
            [ref setColor: [self colorWithSVGStringWithGlobalAlpha:value]];
            [ref setFillType:0];
            
        } else if([value isKindOfClass:[ATCanvasGradient class]]){
            MSGradient *gradient = [self gradientScaled:[value msgradient] bySize:[_layer bounds].size];
            [ref setGradient:gradient];
            [ref setFillType:1];
        }
        
        unsigned long long windingRule = [_pathWindingRule isEqualToString:kATWindingRuleNonZero] ? 0 : 1;
        
        if ([_layer windingRule] != windingRule) {
            [_layer setWindingRule:windingRule];
        }
    }
    
    //update shadow
    if(shadow){
        CGFloat offsetX = [[_state objectForKey:kATStateShadowOffsetX] floatValue];
        CGFloat offsetY = [[_state objectForKey:kATStateShadowOffsetY] floatValue];
        CGFloat blur    = [[_state objectForKey:kATStateShadowBlur] floatValue];
     
        if(offsetX != 0.0 || offsetY != 0.0 || blur != 0.0){
            id ref = _stylePartShadow.ref = _stylePartShadow.ref ?
                                            _stylePartShadow.ref :
                                            [[_style shadows] addNewStylePart];
            [ref setColor: [self colorWithSVGStringWithGlobalAlpha:[_state objectForKey:kATStateShadowColor]]];
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

- (void) markPathChanged{
    _pathDirty      = YES;
    _pathPaintCount = 0;
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
    [self markPathChanged];
}

- (void) quadraticCurveToCpx:(CGFloat)cpx cpy:(CGFloat)cpy x:(CGFloat)x y:(CGFloat)y{
    if(!_path){
        return;
    }
    NSPoint cp = NSMakePoint(cpx, cpy);
    [_path curveToPoint:NSMakePoint(x, y) controlPoint1:cp controlPoint2:cp];
    [self markPathChanged];
}

- (void) bezierCurveToCp1x:(CGFloat)cp1x cp1y:(CGFloat)cp1y cp2x:(CGFloat)cp2x cp2y:(CGFloat)cp2y x:(CGFloat)x y:(CGFloat)y{
    if(!_path){
        return;
    }
    [_path curveToPoint:NSMakePoint(x,y) controlPoint1:NSMakePoint(cp1x, cp1y) controlPoint2:NSMakePoint(cp2x, cp2y)];
    [self markPathChanged];
}

- (void) rectAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height{
    if (!_path) {
        return;
    }
    [_path appendBezierPathWithRect:NSMakeRect(x,y,width,height)];
    [self markPathChanged];
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
    [self markPathChanged];
}

- (void) arcAtX:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle anticlockwise:(BOOL)anticlockwise{
    if(!_path){
        return;
    }
    startAngle = startAngle * 180.0 / M_PI;
    endAngle   = endAngle   * 180.0 / M_PI;
    [_path appendBezierPathWithArcWithCenter:NSMakePoint(x, y) radius:radius startAngle:startAngle endAngle:endAngle clockwise:anticlockwise];
    [self markPathChanged];
}

- (void) stroke{
    if(!_path){
        return;
    }
    [self addPathWithStylePartStroke:YES fill:NO shadow:YES];
}



- (void) fillWithWindingRule:(NSString *)rule{
    if(!_path){
        return;
    }
    _pathWindingRule = ![rule isEqualToString:kATWindingRuleNonZero] && ![rule isEqualToString:kATWindingRuleEvenOdd] ?
                        kATWindingRuleNonZero :
                        rule;
    [self addPathWithStylePartStroke:NO fill:YES shadow:YES];
}

- (void) clip{
    
}

#pragma mark - Text

- (void) setFont:(NSString *)font{
    if(font == [_state objectForKey:kATStateFont]){
        return;
    }

    NSArray  *tokens = [font componentsSeparatedByString:@" "];
    NSString *strFamily;
    NSString *strSize;
    CGFloat  size;
  
    if([tokens count] < 2 || [tokens[0] rangeOfString:@"px"].location == NSNotFound){
        font    = [kATDefaultFont copy];
        tokens  = [font componentsSeparatedByString:@" "];
    }
    
    strSize   = tokens[0];
    size      = [[strSize substringWithRange:NSMakeRange(0, [strSize length] - 2)] floatValue];
    strFamily = tokens[1];
    
    if([strFamily isEqualToString:@"sans-serif"]){
        strFamily = @"Arial";
    }
    
    _font = [NSFont fontWithName:strFamily size:size];
    [_state setObject: [font copy] forKey:kATStateFont];
}

- (NSString*) font{
    return [[_state objectForKey:kATStateFont] copy];
}

- (void) setTextAlign:(NSString *)textAlign{
    if(textAlign == [_state objectForKey:kATStateTextAlign]){
        return;
    }
    [_state setObject:!([textAlign isEqualToString:kATTextAlignStart] &&
                        [textAlign isEqualToString:kATTextAlignEnd] &&
                        [textAlign isEqualToString:kATTextAlignLeft] &&
                        [textAlign isEqualToString:kATTextAlignRight] &&
                        [textAlign isEqualToString:kATTextAlignCenter]) ?
                        [textAlign copy] :
                        [kATTextAlignStart copy]
               forKey:kATStateTextAlign];
}

- (NSString *)textAlign{
    return [[_state objectForKey:kATStateTextAlign] copy];
}

- (void) setTextBaseline:(NSString *)textBaseline{
    if(textBaseline == [_state objectForKey:kATStateTextBaseline]){
        return;
    }
    [_state setObject:!([textBaseline isEqualToString:kATTextBaselineTop] &&
                        [textBaseline isEqualToString:kATTextBaselineHanging] &&
                        [textBaseline isEqualToString:kATTextBaselineMiddle] &&
                        [textBaseline isEqualToString:kATTextBaselineAlphabetic] &&
                        [textBaseline isEqualToString:kATTextBaselineIdeographic] &&
                        [textBaseline isEqualToString:kATTextBaselineBottom]) ?
                        [textBaseline copy] :
                        [kATTextBaselineAlphabetic copy]
               forKey:kATStateTextBaseline];
}

- (NSString *)textBaseline{
    return [[_state objectForKey:kATStateTextBaseline] copy];
}

- (void) fillText:(NSString *)text x:(CGFloat)x y:(CGFloat)y maxWidth:(CGFloat)maxWidth{
    if(!text || [text length] == 0){
        return;
    }
    
    MSTextLayer* textLayer = [_group addLayerOfType:@"text"];
    [textLayer setFont:_font];
    [textLayer setStringValueWithoutUndo:text];
    [textLayer setTextColor:[self colorWithSVGStringWithGlobalAlpha:[_state objectForKey:kATStateFillStyle]]];
    
    //TODO: Add transform
    [[textLayer frame] setX:x];
    [[textLayer frame] setY:y];
}

- (void) strokeText:(NSString *)text x:(CGFloat)x y:(CGFloat)y maxWidth:(CGFloat)maxWidth{
    if(!text || [text length] == 0){
        return;
    }
}

@end