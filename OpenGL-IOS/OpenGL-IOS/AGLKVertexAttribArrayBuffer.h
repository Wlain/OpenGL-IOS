//
//  AGLKVertexAttribArrayBuffer.h
//  OpenGL-IOS
//  该类封装了顶点缓存的七个步骤
//  Created by william on 2019/10/26.
//  Copyright © 2019 william. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    AGLKVertexAttribPosition  = GLKVertexAttribPosition,
    AGLKVertexAttribNormal    = GLKVertexAttribNormal,
    AGLKVertexAttribColor     = GLKVertexAttribColor,
    AGLKVertexAttribTexcoord0 = GLKVertexAttribTexCoord0,
    AGLKVertexAttribTexcoord1 = GLKVertexAttribTexCoord1,
} AGLKVertexAttrib;

@interface AGLKVertexAttribArrayBuffer : NSObject
{
    GLsizeiptr stride;
    GLsizeiptr bufferSizeBytes;
    GLuint     name;
}

@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) GLsizeiptr bufferSizeBytes;
@property (nonatomic, readonly) GLsizeiptr stride;


+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;

- (id)initWithAttribStride:(GLsizei)stride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizeiptr)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;

@end



NS_ASSUME_NONNULL_END
