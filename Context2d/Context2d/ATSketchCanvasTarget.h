//
//  ATSketchCanvasTarget.h
//  Context2d
//
//  Created by Henryk Wollik on 12/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSLayerGroup;

@interface ATSketchCanvasTarget : NSObject
@property (nonatomic) MSLayerGroup *group;
@property (nonatomic) CGSize size;
@end
