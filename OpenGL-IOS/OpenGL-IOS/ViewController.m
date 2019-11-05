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


@interface ViewController()

@end

@implementation ViewController

@synthesize baseEffect;
@synthesize vertexbuffer;
@synthesize shader;

typedef struct
{
    GLKVector2 positionCoords;
}
SceneVertex;

- (void)update
{
    GLKMatrix4 matrix = GLKMatrix4Identity;
    _modelViewPorjectionMatrix = matrix;
}

-(PotraceViewController *)potrace
{
    if (!_potrace) {
        _potrace = [[PotraceViewController alloc] init];
    }
    return _potrace;
}


- (void)viewDidLoad {
    _verticesData = (float *)malloc(sizeof(float) * 1024 * 100);
    memset(_verticesData, 0, sizeof(float) * 1024 * 100);
    _verticesNum = 0;
    [super viewDidLoad];
    
    _verticesNum = [self.potrace runPotroce:_verticesData];
    if (_verticesNum != 0)
    {
        NSLog(@"Error to potrace");
    }
    
    // Verify the type of view created automatically by the
    // Interface Builder storyboard
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller's view is not a GLKView");
    
    // Create an OpenGL ES 2.0 context and provide it to the view
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // Make the new context current
    [AGLKContext setCurrentContext:view.context];
    
    self.shader = [[AGLCompileShader alloc]init];
    [self.shader loadShaders];
    
    // Create a base effect that provides standard OpenGL ES 2.0
    // shading language programs and set constants to be used for
    // all subsequent rendering
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    // Set the background color stored in the current context
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
   
    // Create vertex buffer containing vertices to draw
    self.vertexbuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:_verticesNum / 2
                         bytes:_verticesData usage:GL_STATIC_DRAW];
}

// GLKView
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear Frame Buffer (erase previous drawing)
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT];
    
    [self.vertexbuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    // Render the object again with ES2
    glUseProgram(self.shader.program);
    glUniformMatrix4fv(self.shader.uniform[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewPorjectionMatrix.m);
    [self.vertexbuffer drawArrayWithMode:GL_LINE_STRIP
                        startVertexIndex:0
                        numberOfVertices:_verticesNum/2];
}


// clean-up
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.vertexbuffer = nil;
    
    if (self.shader.program) {
        glDeleteProgram(self.shader.program);
        self.shader.program = 0;
    }

    // clean up
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    // release memory
    _potrace = nil;
    self.shader = nil;
    self.baseEffect = nil;
    
    if (_verticesData) {
        free(_verticesData);
        _verticesData = NULL;
    }
    
}

@end
