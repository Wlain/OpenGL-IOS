//
//  AGLKTextureLoader.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/27.
//  Copyright © 2019 william. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark -AGLKTextureInfo
@interface AGLKTextureInfo : NSObject
{
@private
    GLuint name;
    GLenum target;
    GLuint width;
    GLuint height;
}
@property (readonly) GLuint name;
@property (readonly) GLenum target;
@property (readonly) GLuint width;
@property (readonly) GLuint height;

@end

#pragma mark -AGLKTextureLoader
@interface AGLKTextureLoader : NSObject

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef __nullable)cgImage
                                options:(NSDictionary * __nullable)options
                                  error:(NSError ** __nullable)outError;

@end

NS_ASSUME_NONNULL_END
