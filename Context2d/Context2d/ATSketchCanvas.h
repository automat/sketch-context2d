//
//  ATSketchCanvas.h
//  Context2d
//
//  Created by Henryk Wollik on 10/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ATSketchCanvasTarget.h"
#import "ATSketchContext2d.h"

@protocol ATSketchCanvasExports <JSExport>
@property CGFloat width;
@property CGFloat height;
- (ATSketchContext2d *)getContext:(NSString *)type;
@end

@interface ATSketchCanvas : NSObject<ATSketchCanvasExports>{
    CGFloat _targetWidth;
    CGFloat _targetHeight;
    MSLayerGroup *_group;
    ATSketchContext2d *_context;
}
- (instancetype) initWithTarget: (ATSketchCanvasTarget *)target;
+ (instancetype) canvasWithTarget: (ATSketchCanvasTarget *)target;
@end
