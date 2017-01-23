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

@interface MSImmutableModelObject
- (id)newMutableCounterpart;
@end

@interface MSRect
@property(nonatomic) struct CGPoint origin;
@property(nonatomic) double width;
@property(nonatomic) double height;
- (void)setY:(double)arg1;
- (void)setX:(double)arg1;
@end

#pragma mark - ImageData
@interface MSImageCollection
@property(readonly, nonatomic) NSDictionary *images;
@end

#define MSImageData_Class NSClassFromString(@"MSImageData")
@interface MSImageData : NSObject
- (id)initWithImage:(id)arg1 convertColorSpace:(BOOL)arg2;
@property(retain, nonatomic) NSImage *image;
@property(retain, nonatomic) NSData *sha1;
@property(retain, nonatomic) NSData *data;
@end

#pragma mark - Document
#define MSDocument_Class NSClassFromString(@"MSDocument")
@interface MSDocument
+(id)currentDocument;
@end

@interface MSDocumentData
@property(readonly, nonatomic) MSImageCollection *images;
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

@interface MSLayer : NSObject
@property(retain, nonatomic) MSRect *frame;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)setName:(id)arg1;
@end

#define MSLayerGroup_Class NSClassFromString(@"MSLayerGroup")
@interface MSLayerGroup : MSLayer
//MSLayer
@property(retain, nonatomic) MSRect *frame;
- (void) addLayers:(NSArray* )layers;
- (BOOL)resizeToFitChildrenWithOption:(long long)arg1;
- (void)removeLayer:(id)arg1;
@end

#define MSShapeGroup_Class NSClassFromString(@"MSShapeGroup")
@interface MSShapeGroup : MSLayerGroup
@property(nonatomic) unsigned long long windingRule;
@property(readonly, nonatomic) struct CGRect bounds;
+ (id) shapeWithBezierPath:(NSBezierPath *) path;
- (id)outlinePathForPath:(id)arg1 withBorder:(id)arg2;
- (id)outlineShapeWithBorder:(id)arg1;
- (BOOL)canConvertToOutlines;
- (void) setStyle:(id)style;
@end

#define MSTextLayer_Class NSClassFromString(@"MSTextLayer")
@interface MSTextLayer : MSLayer
- (void)setFont:(id)arg1;
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
@end

#define MSImmutableColor_Class NSClassFromString(@"MSImmutableColor")
@interface MSImmutableColor : MSImmutableModelObject
@property(readonly, nonatomic) double alpha;
+ (id)colorWithSVGString:(id)arg1;
@end

@class MSImmutableGradientStop;
@class MSImmutableGradient;

#define MSGradientStop_Class NSClassFromString(@"MSGradientStop")
@interface MSGradientStop
@property(retain, nonatomic) MSColor *color;
@property(nonatomic) double position;
@end

#define MSGradient_Class NSClassFromString(@"MSGradient")
@interface MSGradient : NSObject <NSCopying>
@property(nonatomic) long long gradientType;
@property(nonatomic) struct CGPoint to;
@property(nonatomic) struct CGPoint from;
@property(nonatomic) double elipseLength;
@property(retain, nonatomic) MSArray *stops;
- (unsigned long long)addStopAtLength:(double)arg1;
- (void)setColor:(id)arg1 atIndex:(unsigned long long)arg2;
- (id) initBlankGradient;
@end

@interface MSGraphicsContextSettings
@property(nonatomic) long long blendMode;
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
@end

@interface MSStyleShadow
@property(retain, nonatomic) MSColor *color;
- (void)setOffsetY:(double)arg1;
- (void)setOffsetX:(double)arg1;
- (void)setBlurRadius:(double)arg1;
@end

#define MSStyle_Class NSClassFromString(@"MSStyle")
@interface MSStyle : NSObject
- (id) addStylePartOfType:(unsigned long long)arg1;
- (id) stylePartsOfType:(unsigned long long)arg1;
@property(retain, nonatomic) MSStyleBorderOptions *borderOptions;
@property(retain, nonatomic) MSGraphicsContextSettings *contextSettings;
@end



#endif /* ATSketchInterface_h */
