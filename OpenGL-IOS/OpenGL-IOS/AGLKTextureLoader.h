//
//  AGLKTextureLoader.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/27.
//  Copyright © 2019 william. All rights reserved.
//

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

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage
                                options:(NSDictionary *)options
                                  error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
