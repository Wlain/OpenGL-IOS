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
    
#pragma mark - OpenGL ES 2 shader compilation
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)program;
- (BOOL)validateProgram:(GLuint)program;

@end

@implementation ViewController

@synthesize baseEffect;
@synthesize vertexbuffer;

// GLSL program uniform indices
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    NUM_NUNIFORMS
};

// GLSL Program uniform IDs
GLint uniform[NUM_NUNIFORMS];

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
    
    [self loadShaders];
    
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
    glUseProgram(_program);
    glUniformMatrix4fv(uniform[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewPorjectionMatrix.m);
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
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }

    // clean up
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    // release memory
    _potrace = nil;
    if (_verticesData) {
        free(_verticesData);
        _verticesData = NULL;
    }
}



#pragma mark - OpenGL ES 2 shader compilation
- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname, *pointPath;
    
    // Create a program
    _program = glCreateProgram();
    
    // Create and compile vertex shader
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"textured" ofType:@"vert"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    // Create and compile fragment shader
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"textured" ofType:@"frag"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    pointPath = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"txt"];
    const GLchar *pointSource;
    pointSource = (GLchar *)[[NSString stringWithContentsOfFile:pointPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    // Attach vertex shader to program
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program
    glAttachShader(_program, fragShader);
    
    // Bind attribute location
    // This needs to done prior to linking
    glBindAttribLocation(_program, GLKVertexAttribPosition, "aPosition");
//    glBindAttribLocation(_program, GLKVertexAttribNormal, "aNormal");
//    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "aTextureCoord0");
//    glBindAttribLocation(_program, GLKVertexAttribTexCoord1, "aTextureCoord1");
    
    // Link program
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return NO;
    }
    
    // Get uniform locations.
    uniform[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "uModelViewProjectionMatrix");
    
    // Release vertex and fragment shader
    if (vertShader) {
       // detach a shader object from a program object
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
        vertShader = 0;
   }
   if (fragShader) {
       // detach a shader object from a program object
       glDetachShader(_program, fragShader);
       glDeleteShader(fragShader);
       fragShader = 0;
   }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file
{
    GLint status;
    // const 指针常量，内容不可被修改
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        char *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}

- (BOOL)linkProgram:(GLuint)program
{
    GLint status;
    glLinkProgram(program);
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

// 验证program
- (BOOL)validateProgram:(GLuint)program
{
    GLint logLength, status;
    
    glValidateProgram(program);
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

@end
