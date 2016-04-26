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

@interface MSRect
@property(nonatomic) struct CGPoint origin;
@property(nonatomic) double width;
@property(nonatomic) double height;
- (void)setY:(double)arg1;
- (void)setX:(double)arg1;
@end

#pragma mark - Image
#define MSImageData_Class NSClassFromString(@"MSImageData")
@interface MSImageData : NSObject
- (id)initWithImage:(id)arg1 convertColorSpace:(BOOL)arg2;
@end

#pragma mark - Layers & Groups

#define MSMaskWithShape_Class NSClassFromString(@"MSMaskWithShape")
@interface MSMaskWithShape
+ (id)nameForMaskWithLayers:(id)arg1;
+ (id)createMaskWithShapeFromMultipleLayers:(id)arg1;
+ (id)toggleMaskForSingleShape:(id)arg1;
+ (id)createMaskForSingleBitmap:(id)arg1;
+ (id)createMaskWithShapeForLayers:(id)arg1;
@end

#define MSShapeGroup_Class NSClassFromString(@"MSShapeGroup")
@interface MSShapeGroup
@property(nonatomic) unsigned long long windingRule;
@property(readonly, nonatomic) struct CGRect bounds;
+ (id) shapeWithBezierPath:(NSBezierPath *) path;
- (void) setStyle:(id)style;
@end

@interface MSLayer
@property(retain, nonatomic) MSRect *frame;
- (void)setName:(id)arg1;
@end

#define MSLayerGroup_Class NSClassFromString(@"MSLayerGroup")
@interface MSLayerGroup : NSObject
//MSLayer
@property(retain, nonatomic) MSRect *frame;
- (id) addLayerOfType:(id)arg1;
- (void) addLayers:(NSArray* )layers;
- (BOOL)resizeToFitChildrenWithOption:(long long)arg1;
- (void)removeLayer:(id)arg1;
@end

#define MSTextLayer_Class NSclassFromString(@"MSTextLayer")
@interface MSTextLayer : MSLayer
- (void)setFont:(id)arg1;
- (void)setStringValueWithoutUndo:(id)arg1;
- (void)setTextColor:(id)arg1;
- (struct CGSize)textContainerSize;
@property(readonly, nonatomic) NSBezierPath *bezierPath;
@property(copy, nonatomic) NSString *stringValue;
@end

#pragma mark - Color & Style

#define MSColor_Class NSClassFromString(@"MSColor")
@interface MSColor
@property(readonly, nonatomic) double alpha;
- (void) setAlpha:(double)alpha;
+ (id) colorWithSVGString:(NSString*)string;
@end

@class MSImmutableGradientStop;
@class MSImmutableGradient;

#define MSGradientStop_Class NSClassFromString(@"MSGradientStop")
@interface MSGradientStop
@property(retain, nonatomic) MSColor *color;
@property(nonatomic) double position;
+ (id)stopWithPosition:(double)arg1 color:(id)arg2;
@end

#define MSGradient_Class NSClassFromString(@"MSGradient")
@interface MSGradient : NSObject <NSCopying>
@property(nonatomic) long long gradientType;
@property(nonatomic) struct CGPoint to;
@property(nonatomic) struct CGPoint from;
@property(nonatomic) double elipseLength;
@property(retain, nonatomic) MSArray *stops;
- (id) stopAtIndex:(unsigned long long)arg1;
- (id) initBlankGradient;
@end

@interface MSStyleBorder
@property(nonatomic) double thickness;
@property(copy, nonatomic) MSColor *color;
@end

@interface MSStyleBorderOptions
@property(nonatomic) unsigned long long lineJoinStyle;
@property(nonatomic) unsigned long long lineCapStyle;
@property(copy, nonatomic) NSArray *dashPattern;
@end

@interface MSStyleFill
@property(nonatomic) unsigned long long fillType;
@property(copy, nonatomic) MSColor *color;
@property(nonatomic) double patternTileScale;
@property(nonatomic) long long patternFillType;
@property(nonatomic) double noiseIntensity;
@property(nonatomic) long long noiseIndex;
@property(retain, nonatomic) id gradient;
@property(retain, nonatomic) MSImageData *image;
- (void)setPatternImage:(id)arg1;
@end

@interface MSStyleShadow
@property(retain, nonatomic) MSColor *color;
- (void)setOffsetY:(double)arg1;
- (void)setOffsetX:(double)arg1;
- (void)setBlurRadius:(double)arg1;
@end

@interface MSBorderStyleCollection
- (MSStyleBorder *) addNewStylePart;
- (void) removeStylePart:(MSStyleBorder *)stylePart;
@end

@interface MSFillStyleCollection
- (MSStyleFill *) addNewStylePart;
- (void) removeStylePart:(MSStyleFill *)stylePart;
@end

@interface MSShadowStyleCollection
- (MSStyleShadow *) addNewStylePart;
- (void) removeStylePart:(MSStyleShadow *)stylePart;
@end

#define MSStyle_Class NSClassFromString(@"MSStyle")
@interface MSStyle : NSObject
@property(retain, nonatomic) MSBorderStyleCollection *borders;
@property(retain, nonatomic) MSFillStyleCollection *fills;
@property(retain, nonatomic) MSShadowStyleCollection *shadows;
@property(retain, nonatomic) MSStyleBorderOptions *borderOptions;
@end



#endif /* ATSketchInterface_h */
