//
//  ATSketchInterface.h
//  Context2d
//
//  Created by Henryk Wollik on 08/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#ifndef ATSketchInterface_h
#define ATSketchInterface_h

#import <AppKit/AppKit.h>

#pragma mark - Misc
@protocol MSAsset <NSObject, NSCopying>
- (BOOL)isAssetEqual:(id <MSAsset>)arg1;
- (unsigned long long)assetType;
@end

#define MSArray_Class NSClassFromString(@"MSArray")
@class MSArray;
@interface MSArray
+ (id)array;
+ (id)dataArrayWithArray:(id)arg1;
- (void)addObjectsFromArray:(id)arg1;
- (void)addObject:(id)arg1;
- (void)removeObjectAtIndex:(unsigned long long)arg1;
- (void)removeObject:(id)arg1;
- (unsigned long long)length;
- (unsigned long long)count;
@end

@class MSRect;
@interface MSRect
@property(nonatomic) double width;
@property(nonatomic) double height;
@end

#pragma mark - Layers & Groups

#define MSShapeGroup_Class NSClassFromString(@"MSShapeGroup")
@class MSShapeGroup;
@interface MSShapeGroup
@property(readonly, nonatomic) struct CGRect bounds;
+ (id) shapeWithBezierPath:(NSBezierPath *) path;
- (void) setStyle:(id)style;
@end

@class MSLayer;
@interface MSLayer
@end

@class MSLayerGroup;
@interface MSLayerGroup
//MSLayer
@property(retain, nonatomic) MSRect *frame;
- (void) addLayers:(NSArray* )layers;
@end

#pragma mark - Color & Style

#define MSColor_Class NSClassFromString(@"MSColor")
@class MSColor;
@interface MSColor
@property(readonly, nonatomic) double alpha;
- (void) setAlpha:(double)alpha;
+ (id) colorWithSVGString:(NSString*)string;
@end

@class MSImmutableGradientStop;
@class MSImmutableGradient;

#define MSGradientStop_Class NSClassFromString(@"MSGradientStop")
@class MSGradientStop;
@interface MSGradientStop
@property(retain, nonatomic) MSColor *color;
@property(nonatomic) double position;
+ (id)stopWithPosition:(double)arg1 color:(id)arg2;
@end

#define MSGradient_Class NSClassFromString(@"MSGradient")
@class MSGradient;
@interface MSGradient : NSObject <NSCopying>
@property(nonatomic) long long gradientType;
@property(nonatomic) struct CGPoint to;
@property(nonatomic) struct CGPoint from;
@property(nonatomic) double elipseLength;
@property(retain, nonatomic) MSArray *stops;
- (id) stopAtIndex:(unsigned long long)arg1;
- (id) initBlankGradient;
@end

@class MSStyleBorder;
@interface MSStyleBorder
@property(nonatomic) double thickness;
@property(copy, nonatomic) MSColor *color;
@end

@class MSStyleBorderOptions;
@interface MSStyleBorderOptions
@property(nonatomic) unsigned long long lineJoinStyle;
@property(nonatomic) unsigned long long lineCapStyle;
@property(copy, nonatomic) NSArray *dashPattern;
@end

@class MSStyleFill;
@interface MSStyleFill
@property(nonatomic) unsigned long long fillType;
@property(copy, nonatomic) MSColor *color;
@property(nonatomic) double patternTileScale;
@property(nonatomic) long long patternFillType;
@property(nonatomic) double noiseIntensity;
@property(nonatomic) long long noiseIndex;
@property(retain, nonatomic) id gradient;
@end

@class MSStyleShadow;
@interface MSStyleShadow
@property(retain, nonatomic) MSColor *color;
- (void)setOffsetY:(double)arg1;
- (void)setOffsetX:(double)arg1;
- (void)setBlurRadius:(double)arg1;
@end

@class MSBorderStyleCollection;
@interface MSBorderStyleCollection
- (MSStyleBorder *) addNewStylePart;
- (void) removeStylePart:(MSStyleBorder *)stylePart;
@end

@class MSFillStyleCollection;
@interface MSFillStyleCollection
- (MSStyleFill *) addNewStylePart;
- (void) removeStylePart:(MSStyleFill *)stylePart;
@end

@class MSShadowStyleCollection;
@interface MSShadowStyleCollection
- (MSStyleShadow *) addNewStylePart;
- (void) removeStylePart:(MSStyleShadow *)stylePart;
@end

#define MSStyle_Class NSClassFromString(@"MSStyle")
@class MSStyle;
@interface MSStyle : NSObject
@property(retain, nonatomic) MSBorderStyleCollection *borders;
@property(retain, nonatomic) MSFillStyleCollection *fills;
@property(retain, nonatomic) MSShadowStyleCollection *shadows;
@property(retain, nonatomic) MSStyleBorderOptions *borderOptions;
@end



#endif /* ATSketchInterface_h */
