//
//  ATSketchContext2d.h
//  Context2d
//
//  Created by Henryk Wollik on 30/03/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ATSketchInterface.h"

#pragma mark – ATStylePart
@interface ATStylePart : NSObject
@property (nonatomic) id ref;
@property (nonatomic) BOOL valid;
@property (nonatomic) BOOL dirty;
@end

#pragma mark – ATCanvasGradient
@protocol ATCanvasGradientExports<JSExport>
- (void) addColorStop:(CGFloat)offset color:(NSString *)color;
@end

@interface ATCanvasGradient : NSObject<NSCopying,ATCanvasGradientExports>{
    unsigned long long _numColorStops;
}
@property (nonatomic) MSGradient *msgradient;
@end

#pragma mark – ATCanvasPattern
@interface ATCanvasPattern : NSObject<NSCopying>
@end

#pragma mark - ATTextMetrics
@protocol ATTextMetricsExports<JSExport>
@property CGFloat width;
@end

@interface ATTextMetrics : NSObject<ATTextMetricsExports>
@end

#pragma mark - ATImageData
@protocol ATImageDateExports<JSExport>
@property CGFloat width;
@property CGFloat height;
@property (nonatomic,readonly) NSArray* data;
@end

@interface ATImageData : NSObject<ATTextMetricsExports>
@end

#pragma mark – ATSketchContext2dExports
@protocol ATSketchContext2dExports<JSExport>

#pragma mark - Compositing
@property CGFloat globalAlpha;
@property NSString *globalCompositionOperation;

#pragma mark - Shadow
@property NSString *shadowColor;
@property CGFloat shadowOffsetX;
@property CGFloat shadowOffsetY;
@property CGFloat shadowBlur;

#pragma mark - Colors and Styles
@property id strokeStyle;
@property id fillStyle;
- (ATCanvasGradient *) createLinearGradientAtX0:(CGFloat)x0 y0:(CGFloat)y0 x1:(CGFloat)x1 y1:(CGFloat)y1;
- (ATCanvasGradient *)createRadialGradientAtX0:(CGFloat)x0 y0:(CGFloat)y0 r0:(CGFloat)r0 x1:(CGFloat)x1 y1:(CGFloat)y1 r1:(CGFloat)r1;
- (ATCanvasPattern *) createPattern;
@property CGFloat lineWidth;
@property NSString* lineCap;
@property NSString* lineJoin;
@property CGFloat miterLimit;

- (void) setLineDash:(NSArray *)lineDash;
- (NSArray *) getLineDash;

@property CGFloat lineDashOffset;

#pragma mark - State
+ (NSDictionary *) defaultState;
- (void)save;
- (void)restore;

#pragma mark - Transformations
JSExportAs(scale,
- (void) scaleX:(CGFloat)x y:(CGFloat)y
);
- (void) rotate:(CGFloat)radians;
JSExportAs(translate,
- (void) translateX:(CGFloat)x y:(CGFloat)y
);
JSExportAs(transform,
- (void) transformA:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d tx:(CGFloat)tx ty:(CGFloat)ty
);
JSExportAs(setTransform,
- (void) setTransform:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d tx:(CGFloat)tx ty:(CGFloat)ty
);

#pragma mark - Path API
- (void) beginPath;
- (void) closePath;
JSExportAs(moveTo,
- (void) moveToX:(CGFloat)x y:(CGFloat) y
);
JSExportAs(lineTo,
- (void) lineToX:(CGFloat)x y:(CGFloat) y
);
JSExportAs(quadraticCurveTo,
- (void) quadraticCurveToCpx:(CGFloat)cpx cpy:(CGFloat)cpy x:(CGFloat)x y:(CGFloat) y
);
JSExportAs(bezierCurveTo,
- (void) bezierCurveToCp1x:(CGFloat)cp1x cp1y:(CGFloat)cp1y cp2x:(CGFloat)cp2x cp2y:(CGFloat)cp2y x:(CGFloat)x y:(CGFloat) y
);
JSExportAs(rect,
- (void) rectAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
);
JSExportAs(fillRect,
- (void) fillRectAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
);
JSExportAs(strokeRect,
- (void) strokeRectAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
);
JSExportAs(arcTo,
- (void) arcToX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 radius:(CGFloat)radius
);
JSExportAs(arc,
- (void) arcAtX:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle anticlockwise:(BOOL)anticlockwise
);
- (void) stroke;
JSExportAs(fill,
- (void) fillWithWindingRule:(NSString *)rule
);
- (void) clip;

#pragma mark - Text
@property (nonatomic) NSString *font;
@property (nonatomic) NSString *textAlign;
@property (nonatomic) NSString *textBaseline;
JSExportAs(fillText,
- (void) fillText:(NSString*)text x:(CGFloat)x y:(CGFloat)y maxWidth:(CGFloat)maxWidth
);
JSExportAs(strokeText,
- (void) strokeText:(NSString*)text x:(CGFloat)x y:(CGFloat)y maxWidth:(CGFloat)maxWidth
);
- (ATTextMetrics *) measureText:(NSString *)text;
@end

#pragma mark - ATSketchContext2d
@interface ATSketchContext2d : NSObject<ATSketchContext2dExports>{
    BOOL         _pathDirty;
    unsigned int _pathPaintCount;
    NSString*    _pathWindingRule;
    NSMutableDictionary *_statePrev;
}

@property (readonly,nonatomic) id test;

@property (readonly,nonatomic) MSLayerGroup *group;
@property (readonly,nonatomic) MSShapeGroup *layer;
@property (readonly,nonatomic) NSBezierPath *path;
@property (readonly,nonatomic) NSMutableDictionary *state;
@property (readonly,nonatomic) NSMutableArray *stateStack;

@property (readonly,nonatomic) MSStyle *style;
@property (readonly,nonatomic) ATStylePart *stylePartStroke;
@property (readonly,nonatomic) ATStylePart *stylePartFill;
@property (readonly,nonatomic) ATStylePart *stylePartShadow;

#pragma mark - Init
- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithGroup:(MSLayerGroup*)group;
+ (instancetype) contextWithGroup:(MSLayerGroup*)group;

- (void) resetWithGroup:(MSLayerGroup *)group;
@end
