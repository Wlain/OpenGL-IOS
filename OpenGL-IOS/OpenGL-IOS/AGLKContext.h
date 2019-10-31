//
//  AGLKContext.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/26.
//  Copyright © 2019 william. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKContext : EAGLContext
{
    GLKVector4 clearColor;
}

@property (nonatomic, assign, readwrite) GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;

- (void)enable:(GLenum)capability;

- (void)disable:(GLenum)capability;

- (void)setBlendSourceFunction:(GLenum)sfactor
           distinationFunction:(GLenum)dfactor;

@end

NS_ASSUME_NONNULL_END
