//
//  ATSketchImage.m
//  Context2d
//
//  Created by Henryk Wollik on 22/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import "ATSketchImage.h"
#import "ATJSContext.h"
#import "ATCOScriptInterface.h"
#import <AppKit/Appkit.h>

#pragma mark - ATSketchImage
@implementation ATSketchImage
- (instancetype) init{
    self = [super init];
    if(self){
        _src = @"";
        _imageSrc = nil;
        _image    = _imageSrc;
    }
    return self;
}
- (instancetype) copyWithZone:(NSZone *)zone{
    ATSketchImage *image = [ATSketchImage new];
    image->_src = [_src copy];
    [image setWidth: [self width]];
    [image setHeight:[self height]];
    return image;
}
- (void) updateImageData{
    _imageData = [[MSImageData_Class alloc] initWithImage:_image convertColorSpace:NO];
}

- (BOOL)validateUrl:(NSString *)candidate {
    static NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (void) setSrc:(NSString *)src{
    if(![self validateUrl:src]){
        if(![[NSFileManager defaultManager] fileExistsAtPath:src isDirectory:NO]){
            NSString *msg = [NSString stringWithFormat:@"File does not exist: %@", src];
            ATJSContextThrowErrorString(msg);
        }
        _imageSrc = [[NSImage alloc] initWithContentsOfFile:src];
    } else {
        ATJSContextThrowErrorString(@"Not implemented");
    }
 
    if(![_imageSrc isValid]){
        NSString *msg = [NSString stringWithFormat:@"No valid image: %@", src];
        ATJSContextThrowErrorString(msg);
    }
    _src = src;
    _image = _imageSrc;
    [self updateImageData];
    _naturalSize.width  = [_image size].width;
    _naturalSize.height = [_image size].height;
}
- (NSString *)src{
    return _src;
}
- (unsigned long) naturalWidth{
    return _naturalSize.width;
}
- (unsigned long) naturalHeight{
    return _naturalSize.height;
}
- (void) resizeToWidth:(unsigned long) width andHeight:(unsigned long)height{
    if(!_imageSrc){
        return;
    }
    _image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [_image lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [_image drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, width, height) operation:NSCompositeCopy fraction:1.0];
    [_image unlockFocus];
    
    [self updateImageData];
}
- (void) setWidth:(unsigned long)width{
    [self resizeToWidth:width andHeight:self.height];
}
- (unsigned long) width{
    return !_image ? 0 : [_image size].width;
}
- (void) setHeight:(unsigned long)height{
    [self resizeToWidth:self.width andHeight:height];
}
- (unsigned long) height{
    return !_image ? 0 : [_image size].height;
}
@end
