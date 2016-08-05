//
//  ATSketchContext2d.m
//  Context2d
//
//  Created by Henryk Wollik on 30/03/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/Appkit.h>

#import "ATJSContext.h"
#import "ATSketchContext2d.h"
#import "ATSketchInterface.h"
#import "ATCOScriptInterface.h"

#include <math.h>
#include <float.h>

#pragma mark - LU

//state
static NSString *const kATStateGroup = @"group";
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
static NSString *const kATGlobalCompositeOperationMultiply        = @"multiply";
static NSString *const kATGlobalCompositeOperationScreen          = @"screen";
static NSString *const kATGlobalCompositeOperationOverlay         = @"overlay";
static NSString *const kATGlobalCompositeOperationDarken          = @"darken";
static NSString *const kATGlobalCompositeOperationLighten         = @"lighten";
static NSString *const kATGlobalCompositeOperationColorDodge      = @"color-dodge";
static NSString *const kATGlobalCompositeOperationColorBurn       = @"color-burn";
static NSString *const kATGlobalCompositeOperationHardLight       = @"hard-light";
static NSString *const kATGlobalCompositeOperationSoftLight       = @"soft-light";
static NSString *const kATGlobalCompositeOperationDifference      = @"difference";
static NSString *const kATGlobalCompositeOperationExclusion       = @"exclusion";
static NSString *const kATGlobalCompositeOperationHue             = @"hue";
static NSString *const kATGlobalCompositeOperationSaturation      = @"saturation";
static NSString *const kATGlobalCompositeOperationColor           = @"color";
static NSString *const kATGlobalCompositeOperationLuminosity      = @"luminosity";

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
//font
static NSString *const kATDefaultFont = @"10px sans-serif";
static NSString *const kATFontSerif     = @"serif";
static NSString *const kATFontSansSerif = @"sans-serif";
static NSString *const kATFontMonospace = @"monospace";
static NSString *const kATFontSerifFont     = @"Times";
static NSString *const kATFontSansSerifFont = @"Helvetica";
static NSString *const kATFontMonospaceFont = @"Courier";
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

//pattern repetition
static NSString *const kATRepetitionRepeat = @"repeat";
static NSString *const kATRepetitionRepeatX = @"repeat-x";
static NSString *const kATRepetitionRepeatY = @"repeat-y";
static NSString *const kATRepetitionNoRepeat = @"no-repeat";

//TODO: ...
#define AT_LU_DICT(dict)\
    static NSDictionary *dict_;\
    static dispatch_once_t once;\
    dispatch_once(&once,^{\
        dict_ = dict;\
    });\
    return dict_;

@interface ATSketchPropertyValue : NSObject
+ (NSDictionary *) borderEnd;
+ (NSDictionary *) borderJoin;
+ (NSDictionary *) patternFillType;
+ (NSDictionary *) blendMode;
@end

@implementation ATSketchPropertyValue
+ (NSDictionary *) borderEnd{
    AT_LU_DICT((@{
                  kATLineCapButt: @0,
                  kATLineCapRound: @1,
                  kATLineCapSquare: @2
                  }));
}
+ (NSDictionary *) borderJoin{
    AT_LU_DICT((@{
                  kATLineJoinMiter: @0,
                  kATLineJoinRound: @1,
                  kATLineJoinBevel: @2
                  }));
}
+ (NSDictionary *) patternFillType{
    AT_LU_DICT((@{
                  kATRepetitionRepeat : @0,
                  kATRepetitionNoRepeat: @1
                  }));
}
+ (NSDictionary *) blendMode{
    AT_LU_DICT((@{
                  kATGlobalCompositeOperationSourceOver : @0,
                  kATGlobalCompositeOperationDarken: @1,
                  kATGlobalCompositeOperationMultiply: @2,
                  kATGlobalCompositeOperationColorBurn: @3,
                  kATGlobalCompositeOperationLighten: @4,
                  kATGlobalCompositeOperationScreen: @5,
                  kATGlobalCompositeOperationColorDodge: @6,
                  kATGlobalCompositeOperationOverlay: @7,
                  kATGlobalCompositeOperationSoftLight: @8,
                  kATGlobalCompositeOperationHardLight: @9,
                  kATGlobalCompositeOperationDifference: @10,
                  kATGlobalCompositeOperationExclusion: @11,
                  kATGlobalCompositeOperationHue: @12,
                  kATGlobalCompositeOperationSaturation: @13,
                  kATGlobalCompositeOperationColor: @14,
                  kATGlobalCompositeOperationLuminosity: @15,
                  kATGlobalCompositeOperationSourceIn : @16,
                  kATGlobalCompositeOperationSourceOut: @17,
                  kATGlobalCompositeOperationSourceAtop: @18,
                  kATGlobalCompositeOperationDestinationOver: @19,
                  kATGlobalCompositeOperationDestinationIn: @20,
                  kATGlobalCompositeOperationDestinationOut: @21,
                  kATGlobalCompositeOperationDestinationAtop: @22
                 }));
}
@end

#pragma mark - ATStylePart

@implementation ATStylePart
@end

#pragma mark - ATCanvasGradient

@implementation ATCanvasGradient
- (instancetype) init{
    self = [super init];
    if(self){
        _msgradient = [[MSGradient_Class alloc] initBlankGradient];
    }
    return self;
}

- (void) addColorStop:(CGFloat)offset color:(NSString *)color{
    if([_msgradient gradientType] == 1){
        offset = 1.0 - offset;
    }
    unsigned long index = [_msgradient addStopAtLength:offset];
    [_msgradient setColor:[MSColor_Class colorWithSVGString:color] atIndex:index];
}

- (void) setMsgradient:(MSGradient *)msgradient{
    _msgradient = [msgradient copy];
}

- (instancetype) copyWithZone:(NSZone *)zone{
    ATCanvasGradient *copy = [ATCanvasGradient new];
    [copy setMsgradient: _msgradient];
    return copy;
}
@end

#pragma mark - ATCanvasPattern
@implementation ATCanvasPattern
-(instancetype) copyWithZone:(NSZone *)zone{
    ATCanvasPattern *copy = [ATCanvasPattern new];
    copy->_image = self->_image;
    copy->_repetition = [self->_repetition copy];
    return copy;
}
@end

#pragma mark - ATImageData

@implementation ATImageData
@synthesize width = _width;
@synthesize height = _height;
@synthesize data = _data;
- (instancetype) init{
    self = [super init];
    if(self){
        _width = 0;
        _height = 0;
        _data = [JSValue valueWithNewArrayInContext: [JSContext currentContext]];
        
    }
    return self;
}
@end
@interface ATRGBAColor
@property (nonatomic) NSString* rgb;
@property (nonatomic) CGFloat a;
@end

#pragma mark - ATTextMetrics
@implementation ATTextMetrics
- (void) setWidth:(CGFloat)width{
    _width = width;
}
- (CGFloat) width{
    return _width;
}
@end

#pragma mark - ATTFontMetrics
@implementation ATFontMetrics
- (instancetype) initWithFont:(NSFont *)font{
    self = [super init];
    if(self){
        CGFloat baselineHeight = [font ascender];
        CGFloat descent = [font descender];
        CGFloat capHeight = [font capHeight];
        CGFloat xHeight = [font xHeight];
        CGFloat defaultLineHeight = [[[NSLayoutManager alloc] init] defaultLineHeightForFont:font];
        
        //relative to absolute metrics
        _defaultLineHeight = defaultLineHeight;
        _baselineHeight    = baselineHeight;
        _descentHeight     = defaultLineHeight - descent;
        _capHeight         = baselineHeight - capHeight;
        _xHeight           = baselineHeight - xHeight;
        _capHeightCenter   = baselineHeight - capHeight * 0.5;
        _xHeightCenter     = baselineHeight - xHeight * 0.5;
        _italicAngle       = [font italicAngle];
        _maxAdvancement    = [font maximumAdvancement];
        _boundingRect      = [font boundingRectForFont];
    }
    return self;
}
+ (instancetype) metricsWithFont:(NSFont *)font{
    return [[ATFontMetrics alloc] initWithFont:font];
}
@end


#pragma mark - ATSketchContext2d

@implementation ATSketchContext2d

@synthesize useTextLayerShapes = _useTextLayerShapes;

#pragma mark - Init

+ (NSDictionary *) defaultState{
    static NSDictionary *defaults;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        defaults = @{
                     kATStateGroup: [NSNull null],
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
    _useTextLayerShapes = YES;
    
    _group = group;
    _target = _group;
    
    _layer       = nil;
    _layerActive = nil;
    _path        = nil;
    
    [_group resizeToFitChildrenWithOption:1];
    
    _state      = [NSMutableDictionary dictionaryWithDictionary:[ATSketchContext2d defaultState]];
    _statePrev  = [NSMutableDictionary dictionaryWithDictionary:[ATSketchContext2d defaultState]];
    _stateStack = [NSMutableArray arrayWithObject:[_state copy]];
    
    _stylePartStroke = [ATStylePart new];
    _stylePartFill   = [ATStylePart new];
    _stylePartShadow = nil;
    
    _state[kATStateGroup] = _target;
 
    [self applyState:_state];
}

+ (instancetype) contextWithGroup:(MSLayerGroup *)group{
    return [[ATSketchContext2d alloc]initWithGroup:group];
}

- (void) setCanvas:(ATSketchCanvas *)canvas{
    _canvas = canvas;
}

- (ATSketchCanvas *)canvas{
    return _canvas;
}

#pragma mark - State

- (void) applyStateStyleParts:(NSMutableDictionary*)state{
    //style, color
    [self setFillStyle:      state[kATStateFillStyle]];
    [self setStrokeStyle:    state[kATStateStrokeStyle]];
    [self setLineWidth:     [state[kATStateLineWidth] floatValue]];
    [self setLineDash:       state[kATStateLineDash]];
    [self setLineDashOffset:[state[kATStateLineDashOffset] floatValue]];
    [self setLineCap:        state[kATStateLineCap]];
    [self setLineJoin:       state[kATStateLineJoin]];
    
    //shadows
    [self setShadowBlur:   [state[kATStateShadowBlur] floatValue]];
    [self setShadowOffsetX:[state[kATStateShadowOffsetX] floatValue]];
    [self setShadowOffsetY:[state[kATStateShadowOffsetY] floatValue]];
    [self setShadowColor:   state[kATStateShadowColor]];
}

- (void) applyState:(NSMutableDictionary*)state{
    _target = state[kATStateGroup];
    
    //style parts
    [self applyStateStyleParts:state];
    
    //transform
    _state[kATStateTransform] = [state[kATStateTransform] copy];
    
    //compositing
    [self setGlobalAlpha:[state[kATStateGlobalAlpha] floatValue]];
    [self setGlobalCompositeOperation:[state[kATStateGlobalCompositeOperation] copy]];
    
    //text
    [self setFont:        state[kATStateFont]];
    [self setTextAlign:   state[kATStateTextAlign]];
    [self setTextBaseline:state[kATStateTextBaseline]];
}

- (void) save{
    //temp
    [_stateStack addObject: [NSMutableDictionary dictionaryWithDictionary:_state]];
    NSMutableDictionary* last = [_stateStack lastObject];
    last[kATStateTransform] = [[NSAffineTransform alloc] initWithTransform:_state[kATStateTransform]];
}

- (void) restore{
    if([_stateStack count] == 1){
        return;
    }
    [self applyState:[_stateStack lastObject]];
    [_stateStack removeLastObject];
}

- (void) setStatePropertyWithKey:(NSString *)stateKey value:(id)value{
    _statePrev[stateKey] = [_state[stateKey] copy];
    _state[stateKey] = value;
}

// updates a state value used by style parts, indicating if stylepart should be updated
- (void) setStatePropertyWithKey:(NSString *)stateKey value:(id)value stylePart:(ATStylePart *)stylePart{
    _statePrev[stateKey] = _state[stateKey];
    stylePart.dirty = YES;
    stylePart.valid = value != nil;
    _state[stateKey] = value;
}

#pragma mark - Transformations

- (void) scaleX:(CGFloat)x y:(CGFloat)y{
    [_state[kATStateTransform] scaleXBy:x yBy:y];
}

- (void) rotate:(CGFloat)radians{
    [_state[kATStateTransform] rotateByRadians:radians];
}

- (void) translateX:(CGFloat)x y:(CGFloat)y{
    [_state[kATStateTransform] translateXBy:x yBy:y];
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
    [_state[kATStateTransform] appendTransform:transform];
}

- (void) setTransform:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d tx:(CGFloat)tx ty:(CGFloat)ty{
    NSAffineTransform *transform = _state[kATStateTransform];
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
    return _state[kATStateStrokeStyle];
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
    //only linear gradient
    [msgradient setFrom:CGPointMake(x0, y0)];
    [msgradient setTo:CGPointMake(x0 + r0, y0)];
    [msgradient setElipseLength:1.0];
    return gradient;
}

- (ATCanvasPattern *) createPatternWithImage:(ATSketchImage *)image andRepetition:(NSString *)repetition{
    //set image data
    ATCanvasPattern *pattern = [ATCanvasPattern new];
    [pattern setImage:image];
    //set pattern fill type
    NSDictionary *patternFillType = [ATSketchPropertyValue patternFillType];
    //repeat-x, repeat-y not supported by Sketch
    if(![patternFillType objectForKey:repetition]){
        ATCOScriptPrint(([NSString stringWithFormat:@"Unsupported repitition \"%@\"",repetition]));
        repetition = kATRepetitionRepeat;
    }
    [pattern setRepetition:[repetition copy]];
    return pattern;
}

#pragma mark - Compositing

- (void) setGlobalAlpha:(CGFloat)alpha{
    [self setStatePropertyWithKey:kATStateGlobalAlpha value:[NSNumber numberWithFloat:fmaxf(alpha, 0.0)]];
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
    NSDictionary *blendMode = [ATSketchPropertyValue blendMode];
    if(![blendMode objectForKey:operation]){
        ATCOScriptPrint(([NSString stringWithFormat:@"Unsupported globalCompositeOperation \"%@\"", operation]));
        //fallback "source-over"
        operation = kATGlobalCompositeOperationSourceOver;
    }
    [self setStatePropertyWithKey:kATStateGlobalCompositeOperation value:[operation copy]];
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
    return [_state[kATStateShadowOffsetX] floatValue];
}

- (void) setShadowOffsetY:(CGFloat)offset{
    [self setStatePropertyWithKey:kATStateShadowOffsetY
                            value:[NSNumber numberWithFloat:offset]
                        stylePart:_stylePartShadow];
}

- (CGFloat) shadowOffsetY{
    return [_state[kATStateShadowOffsetY] floatValue];
}

- (void) setShadowBlur:(CGFloat)blur{
    [self setStatePropertyWithKey:kATStateShadowBlur
                            value:[NSNumber numberWithFloat:blur]
                        stylePart:_stylePartShadow];
}

- (CGFloat) shadowBlur{
    return [_state[kATStateShadowBlur] floatValue];
}

- (void) setShadowColor:(NSString *)color{
    [self setStatePropertyWithKey:kATStateShadowColor
                            value:color ? [color copy] : @"000000"
                        stylePart:_stylePartShadow];
}

- (NSString *) shadowColor{
    return _state[kATStateShadowColor];
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
    NSDictionary *borderEnd = [ATSketchPropertyValue borderEnd];
    if(![borderEnd objectForKey:lineCap]){
        ATCOScriptPrint(([NSString stringWithFormat:@"Unsupported lineCap \"%@\"",lineCap]));
        //fallback to default "butt"
        lineCap = kATLineCapButt;
    }
    [self setStatePropertyWithKey:kATStateLineCap value:[lineCap copy]];
}

- (NSString*) lineCap{
    return [_state[kATStateLineCap] copy];
}

- (void) setLineJoin:(NSString *)lineJoin{
    NSDictionary *borderJoin = [ATSketchPropertyValue borderJoin];
    if(![borderJoin objectForKey:lineJoin]){
        ATCOScriptPrint(([NSString stringWithFormat:@"Unsupported lineJoin \"%@\"",lineJoin]));
        //fallback to default "miter"
        lineJoin = kATLineJoinMiter;
    }
    [self setStatePropertyWithKey:kATStateLineJoin value:[lineJoin copy]];
}

- (NSString *) lineJoin{
    return [_state[kATStateLineJoin] copy];
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
    return [_state[kATStateLineDash] copy];
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

- (BOOL) isRGBAColor:(NSString*)color{
    return false;
}

- (MSColor*)colorWithSVGStringWithGlobalAlpha:(NSString *)value{
    NSNumber *stateGlobalAlpha = _state[kATStateGlobalAlpha];
    CGFloat globalAlpha = stateGlobalAlpha ? [stateGlobalAlpha floatValue] : 1.0;
    
    MSColor *color = [MSColor_Class colorWithSVGString:value];
    [color setAlpha:([color alpha] * globalAlpha)];
    return color;
}

- (void) updateGroupBounds{
    //FIXME: this alters layer positions
    //[_group resizeToFitChildrenWithOption:0];
}

- (void) addPathWithStylePartStroke:(BOOL)stroke fill:(BOOL)fill shadow:(BOOL)shadow{
    //todo: add style add if path has not been altered, no need to repaint same paths
    //1 element + valid segments
    if ([_path elementCount] < 1 || !_pathDirty) {
        return;
    }
    
    //set layer blendMode
    NSString *globalCompositeOperation = _state[kATStateGlobalCompositeOperation];
    unsigned long blendMode = [[ATSketchPropertyValue blendMode][globalCompositeOperation] unsignedLongLongValue];
    [[_style contextSettings] setBlendMode: blendMode];
    
    //already stroked path, need to copy path and paint on top
    if(fill && _stylePartStroke.ref){
        _path = [_path copy];
        _pathDirty = YES;
        _pathPaintCount = 0;
        
        [self resetLayerAndStyle];
    }
    
    //transform
    NSAffineTransform *transform = _state[kATStateTransform];
    if(transform){
        [_path transformUsingAffineTransform: transform];
    }
    if(!_layer){
        _layer = [MSShapeGroup_Class shapeWithBezierPath:_path];
        [_layer setStyle:_style];
        [_target addLayers:@[_layer]];
    }
    //TODO: Move to partial updates, not reinitializations
    
    // update stroke
    if(stroke && _stylePartStroke.valid){
        id value = _state[kATStateStrokeStyle];
        id ref = _stylePartStroke.ref = (!_stylePartStroke.ref || _pathPaintCount > 0) ?
        [_style addStylePartOfType:1] :
        _stylePartStroke.ref;
        if([value isKindOfClass:[NSString class]]){
            [ref setColor: [self colorWithSVGStringWithGlobalAlpha:value]];
            [ref setFillType:0];
            
        } else if([value isKindOfClass:[ATCanvasGradient class]]){
            MSGradient *gradient = [self gradientScaled:[value msgradient] bySize:[_layer bounds].size];
            [ref setGradient:gradient];
            [ref setFillType:1];
        }
        
        [ref setThickness:[_state[kATStateLineWidth] floatValue]];
        
        //update border options
        MSStyleBorderOptions *options = [_style borderOptions];
        
        //lineCap
        NSString *lineCap  = _state[kATStateLineCap];
        unsigned long long lineCapStyle = [lineCap isEqualToString:kATLineCapRound]  ? 1 :
        [lineCap isEqualToString:kATLineCapSquare] ? 2 :
        0; //default: butt
        [options setLineCapStyle:lineCapStyle];
        
        //lineJoin
        NSString *lineJoin = _state[kATStateLineJoin];
        unsigned long long lineJoinStyle = [lineJoin isEqualToString:kATLineJoinRound] ? 1 :
        [lineJoin isEqualToString:kATLineJoinBevel] ? 2 :
        0; //default: miter
        [options setLineJoinStyle:lineJoinStyle];
        
        //lineDash
        NSArray *lineDash = [_state[kATStateLineDash] copy];
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
        
        if([value isKindOfClass:[ATCanvasPattern class]]){
            //valid outline
            if([_layer canConvertToOutlines]){
                ATCanvasPattern *pattern = value;
                //create outline
                MSShapeGroup *outlinePath = [_layer outlineShapeWithBorder:ref];
                //create isolated fill style
                MSStyle *style = [MSStyle_Class new];
                MSStyleFill *fill = [style addStylePartOfType:0];
                [fill setFillType:4];
                [fill setImage:[[pattern image] imageData]];
                NSDictionary *patternFillType = [ATSketchPropertyValue patternFillType];
                [fill setPatternFillType: [patternFillType[[pattern repetition]] longLongValue]];
                [outlinePath setStyle:style];
                //add new outline path, keep reference path
                [_target addLayers:@[outlinePath]];
            //invalid outline
            } else {
                ATCOScriptPrint(@"Unable to transform path to outlines.");
            }
        }
    }
    
    // update fill
    if(fill && _stylePartFill.valid){
        id value = _state[kATStateFillStyle];
        MSStyleFill* ref = _stylePartFill.ref = (!_stylePartFill.ref || _pathPaintCount > 0) ?
        [_style addStylePartOfType:0] :
        _stylePartFill.ref;
        
        //color string
        if([value isKindOfClass:[NSString class]]){
            [ref setFillType:0];
            [ref setColor: [self colorWithSVGStringWithGlobalAlpha:value]];
        //gradient
        } else if([value isKindOfClass:[ATCanvasGradient class]]){
            [ref setFillType:1];
            MSGradient *gradient = [self gradientScaled:[value msgradient] bySize:[_layer bounds].size];
            [ref setGradient:gradient];
        //pattern
        } else if([value isKindOfClass:[ATCanvasPattern class]]){
            [ref setFillType:4];
            ATCanvasPattern *pattern = value;
            [ref setImage:[[pattern image] imageData]];
            NSDictionary *patternFillType = [ATSketchPropertyValue patternFillType];
            [ref setPatternFillType: [patternFillType[[pattern repetition]] longLongValue]];
        }
        
        unsigned long long windingRule = [_pathWindingRule isEqualToString:kATWindingRuleNonZero] ? 0 : 1;
        
        if ([_layer windingRule] != windingRule) {
            [_layer setWindingRule:windingRule];
        }
    }
    
    //update shadow
    if(shadow){
        CGFloat offsetX = [_state[kATStateShadowOffsetX] floatValue];
        CGFloat offsetY = [_state[kATStateShadowOffsetY] floatValue];
        CGFloat blur    = [_state[kATStateShadowBlur] floatValue];
        
        if(offsetX != 0.0 || offsetY != 0.0 || blur != 0.0){
            id ref = _stylePartShadow.ref = _stylePartShadow.ref ?
            _stylePartShadow.ref :
            [_style addStylePartOfType:2];
            [ref setColor: [self colorWithSVGStringWithGlobalAlpha:_state[kATStateShadowColor]]];
            [ref setOffsetX:offsetX];
            [ref setOffsetY:offsetY];
            [ref setBlurRadius:blur];
        }
    }
    
    _layerActive = _layer;
    [self updateGroupBounds];
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

- (void) resetLayerAndStyle{
    //TODO: non hard copy
    _layer = nil;
    _style = [MSStyle_Class new];
    _stylePartStroke = [ATStylePart new];
    _stylePartFill   = [ATStylePart new];
    _stylePartShadow = [ATStylePart new];
    [self applyStateStyleParts:_state];
}

- (void) beginPath{
    _path           = [NSBezierPath bezierPath];
    _pathDirty      = NO;
    _pathPaintCount = 0;
    
    [self resetLayerAndStyle];
}

- (void) closePath{
    if(!_path){
        return;
    }
    [_path closePath];
}

- (void) moveToX:(CGFloat)x y:(CGFloat)y{
    if(!_path || _pathPaintCount > 0){ //can skip beginPath
        [self beginPath];
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
    double ratio = 2.0 / 3.0;
    
    NSPoint qp0 = [_path currentPoint];
    NSPoint cp3 = NSMakePoint(x, y);
    NSPoint cp1 = NSMakePoint(qp0.x + ratio * (cpx - qp0.x), qp0.y + ratio * (cpy - qp0.y));
    NSPoint cp2 = NSMakePoint(x +     ratio * (cpx - x),     y +     ratio * (cpy - y));
    
    [_path curveToPoint:cp3 controlPoint1:cp1 controlPoint2:cp2];
    
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
    if(!_path || _pathPaintCount > 0){ //can skip beginPath
        [self beginPath];
    }
    [_path appendBezierPathWithRect:NSMakeRect(x,y,width,height)];
    [self markPathChanged];
}

- (void) fillRectAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height{
    [self beginPath];
    [self rectAtX:x y:y width:width height:height];
    [self addPathWithStylePartStroke:NO fill:YES shadow:YES];
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

- (void) arcAtX:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius
     startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
  anticlockwise:(BOOL)anticlockwise{
    if(!_path || _pathPaintCount > 0){ //can skip beginPath
        [self beginPath];
    }
    
    startAngle = startAngle * 180.0 / M_PI;
    endAngle   = endAngle   * 180.0 / M_PI;
    
    //tempfix
    if(anticlockwise && fabs(360.0 - (endAngle - startAngle)) < DBL_EPSILON){
        anticlockwise = NO;
    }
    
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

- (void) clipWithWindingRule:(NSString *)rule{
    //rule not supported
    if(!_layerActive){
        return;
    } else if(!_useTextLayerShapes && [_layerActive isKindOfClass:[NSClassFromString(@"MSTextLayer") class]]){
        //convert text-layer to path, use result as mask
        _layer = [MSShapeGroup_Class shapeWithBezierPath:[_layerActive bezierPath]];
        [_target addLayers:@[_layer]];
        
        _layerActive = _layer;
        _path  = nil;
    }
    
    [MSMaskWithShape_Class toggleMaskForSingleShape:_layer];
    
    MSLayerGroup *group = [MSLayerGroup_Class new];
    [_target removeLayer:_layer];
    
    [group addLayers:@[_layer]];
    [_target addLayers:@[group]];
    
    _target = group;
}

#pragma mark - Text

- (void) setFont:(NSString *)font{
    if([font isEqualToString:_state[kATStateFont]]){
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
    strFamily = [strFamily isEqualToString:kATFontSansSerif] ? kATFontSansSerifFont :
    [strFamily isEqualToString:kATFontSerif]     ? kATFontSerifFont :
    [strFamily isEqualToString:kATFontMonospace] ? kATFontMonospaceFont :
    strFamily;
    
    _font = [NSFont fontWithName:strFamily size:size];
    _fontMetrics = [ATFontMetrics metricsWithFont:_font];
    _state[kATStateFont] = [font copy];
}

- (NSString*) font{
    return [_state[kATStateFont] copy];
}

- (void) setTextAlign:(NSString *)textAlign{
    if([textAlign isEqualToString: _state[kATStateTextAlign]]){
        return;
    }
    //fall back to kATTextAlignStart if no valid alignment
    BOOL isValid = [textAlign isEqualToString:kATTextAlignStart] ||
                   [textAlign isEqualToString:kATTextAlignEnd] ||
                   [textAlign isEqualToString:kATTextAlignLeft] ||
                   [textAlign isEqualToString:kATTextAlignRight] ||
                   [textAlign isEqualToString:kATTextAlignCenter];
    _state[kATStateTextAlign] = isValid ? [textAlign copy] : [kATTextAlignStart copy];
}

- (NSString *)textAlign{
    return [_state[kATStateTextAlign] copy];
}

- (void) setTextBaseline:(NSString *)textBaseline{
    if([textBaseline isEqualToString: _state[kATStateTextBaseline]]){
        return;
    }
    //fall back to kATTextBaselineAlphabetic if no valid alignment
    BOOL isValid = [textBaseline isEqualToString:kATTextBaselineTop] ||
                   [textBaseline isEqualToString:kATTextBaselineHanging] ||
                   [textBaseline isEqualToString:kATTextBaselineMiddle] ||
                   [textBaseline isEqualToString:kATTextBaselineAlphabetic] ||
                   [textBaseline isEqualToString:kATTextBaselineIdeographic] ||
                   [textBaseline isEqualToString:kATTextBaselineBottom];
    _state[kATStateTextBaseline] = isValid ? [textBaseline copy] : [kATTextBaselineAlphabetic copy];
}

- (NSString *)textBaseline{
    return [_state[kATStateTextBaseline] copy];
}

//get offset of textlayer based on alignment and basline
- (CGPoint) offsetTextLayer:(MSTextLayer *)textLayer{
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    
    CGFloat width = [self measureText_internal:[textLayer stringValue]];
    
    NSString *textAlign = _state[kATStateTextAlign];
    if([textAlign isEqualToString:kATTextAlignCenter]){
        offsetX = -width * 0.5;
    } else if([textAlign isEqualToString:kATTextAlignRight] || [textAlign isEqualToString:kATTextAlignEnd]){
        offsetX = -width;
    }
    
    NSString *textBaseline = _state[kATStateTextBaseline];
    
    if([textBaseline isEqualToString:kATTextBaselineHanging]){ //cap-height top
        offsetY = [_fontMetrics capHeight];
    } else if([textBaseline isEqualToString:kATTextBaselineMiddle]){ //cap-height center
        offsetY = [_fontMetrics capHeightCenter];
    } else if([textBaseline isEqualToString:kATTextBaselineAlphabetic]){ //baseline
        offsetY = [_fontMetrics baselineHeight];
    } else if([textBaseline isEqualToString:kATTextBaselineIdeographic]){
        offsetY = [_fontMetrics baselineHeight];
    } else if([textBaseline isEqualToString:kATTextBaselineBottom]){ //bottom em square
        offsetY = [[textLayer frame] height];
    }
    
    return NSMakePoint(offsetX, offsetY * -1.0);
}

- (MSTextLayer *)textLayerWithText:(NSString *)text atX:(CGFloat)x y:(CGFloat)y{
    MSTextLayer *textLayer = [[MSTextLayer_Class alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_group addLayers:@[textLayer]];
    [textLayer setFont:_font];
    [textLayer setStringValue:text];
    [textLayer setName:text];
    
    CGPoint offset = [self offsetTextLayer:textLayer];
    
    //TODO: Add transform
    [[textLayer frame] setX:x + offset.x];
    [[textLayer frame] setY:y + offset.y];
    
    return textLayer;
}

- (void) fillText:(NSString *)text x:(CGFloat)x y:(CGFloat)y maxWidth:(CGFloat)maxWidth{
    if(!text || [text length] == 0){
        return;
    }
    MSTextLayer *textLayer = [self textLayerWithText:text atX:x y:y];
    if(!_useTextLayerShapes){
        //translation only
        NSAffineTransform *transform = _state[kATStateTransform];
        CGPoint origin = [transform transformPoint:[[textLayer frame] origin]];
        [[textLayer frame] setX:origin.x];
        [[textLayer frame] setY:origin.y];
        
        //textcolor from fill
        [textLayer setTextColor:[self colorWithSVGStringWithGlobalAlpha:_state[kATStateFillStyle]]];
        
        if(!isnan(maxWidth)){
            //TODO: Add max width here,textLayer => GroupShape => skew, actual usecase?
        }
        
        _layerActive = textLayer;
        [self updateGroupBounds];
        return;
    }
    //textLayer vectorized
    [self beginPath];
    [_path appendBezierPath:[textLayer bezierPath]];
    [self markPathChanged];
    [self addPathWithStylePartStroke:NO fill:YES shadow:YES];
    
    //FIXME: Create textlayer without adding to group
    [_target removeLayer:textLayer];
}

- (void) strokeText:(NSString *)text x:(CGFloat)x y:(CGFloat)y maxWidth:(CGFloat)maxWidth{
    if(!text || [text length] == 0){
        return;
    }
    MSTextLayer *textLayer = [self textLayerWithText:text atX:x y:y];
    if(!_useTextLayerShapes){
        //translation only
        NSAffineTransform *transform = _state[kATStateTransform];
        CGPoint origin = [transform transformPoint:[[textLayer frame] origin]];
        [[textLayer frame] setX:origin.x];
        [[textLayer frame] setY:origin.y];
        
        //transparent fill color
        MSColor *color = [MSColor_Class colorWithSVGString:@"#ffffff"];
        [color setAlpha:0.0];
        [textLayer setTextColor:color];
        
        if(!isnan(maxWidth)){
            //TODO: Add max width here,textLayer => GroupShape => skew, actual usecase?
        }
        
        _layerActive = textLayer;
        [self updateGroupBounds];
        return;
    }
    //textLayer vectorized
    [self beginPath];
    [_path appendBezierPath:[textLayer bezierPath]];
    [self markPathChanged];
    [self addPathWithStylePartStroke:YES fill:NO shadow:YES];
    
    //FIXME: Create textlayer without adding to group
    [_target removeLayer:textLayer];
    
}

- (CGFloat) measureText_internal:(NSString *)text{
    return [text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_font,NSFontAttributeName,nil]].width;
}

- (ATTextMetrics *)measureText:(NSString *)text{
    ATTextMetrics *metrics = [ATTextMetrics new];
    [metrics setWidth: [self measureText_internal:text]];
    return metrics;
}

#pragma mark - ImageData

- (ATImageData *)createImageDataWithWidth:(unsigned long long)width andHeight:(unsigned long long)height{
    ATImageData *imageData = [ATImageData new];
    //TODO: add
    return imageData;
}

- (ATImageData *) getImageDataWithX:(unsigned long long)x y:(unsigned long long)y
                           andWidth:(unsigned long long)width height:(unsigned long long)height{
    ATImageData *imageData = [ATImageData new];
    //TODO: add
    return imageData;
}

- (void) putImageData:(ATImageData *)imageData withX:(unsigned long long)x y:(unsigned long long)y
            andDirtyX:(unsigned long long)dirtyX dirtyY:(unsigned long long)
       andDirtyWidth :(unsigned long long)width dirtyHeight:(unsigned long long)height{
    //TODO:add
}

#pragma mark - Image
- (void) drawImage:(ATSketchImage *)image
            fromSx:(CGFloat)sx sy:(CGFloat)sy
             andSw:(CGFloat)sw sh:(CGFloat)sh
              toDx:(CGFloat)dx dy:(CGFloat)dy
             andDw:(CGFloat)dw dh:(CGFloat)dh{
    if(!image || ![image imageData]){
        return;
    }
    CGFloat imageWidth  = [image width];
    CGFloat imageHeight = [image height];
    
    sx = isnan(sx) ? 0.0 : sx;
    sy = isnan(sy) ? 0.0 : sy;
    sw = fmaxf(isnan(sw) ? imageWidth  : sw, 0.0);
    sh = fmaxf(isnan(sh) ? imageHeight : sh, 0.0);
    
    if (sw == 0.0 || sh == 0.0) {
        return;
    }
    
    dx = isnan(dx) ? sx : dx;
    dy = isnan(dy) ? sy : dy;
    dw = fmaxf(isnan(dw) ? sw : dw, 0.0);
    dh = fmaxf(isnan(dh) ? sh : dh, 0.0);
    
    if(dw == 0.0 || dh == 0.0){
        return;
    }
    
    NSAffineTransform *transform = _state[kATStateTransform];
    
    //state stack independent
    MSLayerGroup *target = _target;
    MSShapeGroup *layer;
    NSBezierPath *path;
    MSStyle *style = [MSStyle_Class new];
    MSStyleFill *fill = [style addStylePartOfType:0];
    [fill setFillType:4];
    [fill setImage:[image imageData]];
    
    //original input image
    if(sx == 0 && dx == sx &&
       sy == 0 && dy == sy &&
       sw == imageWidth  && dw == sw &&
       sh == imageHeight && dh == sh){
        path = [NSBezierPath bezierPathWithRect:CGRectMake(0, 0, imageWidth, imageHeight)];
        //fit, orginal aspect ratio and size
        [fill setPatternFillType:1];
    //destination size differs, possible offset
    } else if(sx == dx &&
              sy == dy &&
              sw != imageWidth && dw == sw &&
              sh != imageHeight && dh == sh){
        path = [NSBezierPath bezierPathWithRect:CGRectMake(sx, sy, sw, sh)];
        //stretch to fit target size
        [fill setPatternFillType:2];
    //source & destination offset & size
    } else if(sx != dx || sy != dy || sw != dw || sh != dh){
        //clip layer
        NSBezierPath *clipPath = [NSBezierPath bezierPathWithRect:CGRectMake(dx, dy, dw, dh)];
        MSShapeGroup *clipLayer = [MSShapeGroup_Class shapeWithBezierPath:clipPath];
        //clip container
        [MSMaskWithShape_Class toggleMaskForSingleShape: clipLayer];
        MSLayerGroup *clipGroup = [MSLayerGroup_Class new];
        [clipGroup addLayers:@[clipLayer]];
        //image path layer
        CGFloat x = dx + sy;
        CGFloat y = dy + sy;
        CGFloat w = imageWidth * (dw / sw);
        CGFloat h = imageHeight * (dh / sh);
        path = [NSBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)];
        //destination clip container
        target = clipGroup;
        //stretch to fit target size
        [fill setPatternFillType:2];
    } else {
        //invalid
        return;
    }
    
    //TODO: Transform layer not shape
    [path transformUsingAffineTransform:transform];
    layer = [MSShapeGroup_Class shapeWithBezierPath: path];
    [layer setStyle:style];
    [target addLayers:@[layer]];
    
    //clip group
    if(target != _target){
        [_target addLayers:@[target]];
    }
    
    [self updateGroupBounds];
}


@end