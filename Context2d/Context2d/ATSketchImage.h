//
//  ATSketchImage.h
//  Context2d
//
//  Created by Henryk Wollik on 22/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ATSketchInterface.h"

#pragma mark - ATImage
@protocol ATSketchImageExports<JSExport>
@property (nonatomic) NSString *src;
@property (nonatomic) unsigned long width;
@property (nonatomic) unsigned long height;
@property (readonly,nonatomic) unsigned long naturalWidth;
@property (readonly,nonatomic) unsigned long naturalHeight;
@end

@interface ATSketchImage : NSObject<NSCopying,ATSketchImageExports>{
    NSString *_src;
    NSImage  *_imageSrc;
    CGSize _naturalSize;
}
@property (readonly,nonatomic) MSImageData *imageData;
@property (readonly,nonatomic) NSImage *image;
@end
