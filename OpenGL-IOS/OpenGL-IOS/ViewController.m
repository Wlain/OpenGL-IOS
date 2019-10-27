//
//  ViewController.m
//  OpenGL-IOS
//
//  Created by william on 2019/10/25.
//  Copyright © 2019 william. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

// vertex info
typedef struct {
    GLKVector3 positionCoords;
}
SceneVertex;

static const SceneVertex vertices[] =
{
    {{-0.5, -0.5, 0.0}},
    {{ 0.0,  0.5, 0.0}},
    {{ 0.5, -0.5, 0.0}}
};


@interface ViewController ()

@end

@implementation ViewController

@synthesize baseEffect;


- (void)viewDidLoad {
    [super viewDidLoad];
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]], @"View Controller's view is not a AGLKView");
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    self.vertexbuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                         bytes:vertices usage:GL_STATIC_DRAW];
}

// AGLKView
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffect prepareToDraw];
    
    // Clear Frame Buffer (erase previous drawing)
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexbuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    [self.vertexbuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:3];
}


// clean-up
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Make the view's context current
    AGLKView *view = (AGLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.vertexbuffer = nil;
    

    // clean up
    ((AGLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}


@end
