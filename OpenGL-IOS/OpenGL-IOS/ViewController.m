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
#import "AGLKTextureLoader.h"

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;
@end

@implementation GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value
{
    glBindTexture(self.target, self.name);
    
    glTexParameteri(self.target,
                    parameterID,
                    value);
}

@end

@interface ViewController()
    
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
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE0_SAMPLER2D,
    UNIFORM_TEXTURE1_SAMPLER2D,
    NUM_NUNIFORMS
};

// GLSL Program uniform IDs
GLint uniform[NUM_NUNIFORMS];

// vertex info
typedef struct {
    GLKVector3 positionCoords;
    GLKVector3 normalCoords;
    GLKVector2 textureCoords;
}
SceneVertex;


static SceneVertex vertices[] =
{
    {{-1.0f, -1.0f, 0.0f},{{1.0f, 0.0f, 0.0f}}, {0.0f, 0.0f}},
    {{-1.0f,  1.0f, 0.0f},{{1.0f, 0.0f, 0.0f}}, {0.0f, 1.0f}},
    {{ 1.0f, -1.0f, 0.0f},{{1.0f, 0.0f, 0.0f}}, {1.0f, 0.0f}},
    {{ 1.0f,  1.0f, 0.0f},{{1.0f, 0.0f, 0.0f}}, {1.0f, 1.0f}},
};


- (void)update
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    self.baseEffect.transform.projectionMatrix = projectionMatrix;
    GLKMatrix4 matrix = GLKMatrix4MakeScale(1.0, 1.0, 1.0);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);

    // Computer the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;

    //Computer the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normatMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(modelViewMatrix, NULL));
    
    _modelViewPorjectionMatrix = matrix;//GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

    _rotation = 3.14;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"cwb");
    self.view.backgroundColor = [UIColor redColor];
    self.preferredFramesPerSecond = 60;
      
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
                         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                         bytes:vertices usage:GL_STATIC_DRAW];
    
    // Setup texture0
    CGImageRef imageRef0 =
    [[UIImage imageNamed:@"test.jpg"] CGImage];
    
    AGLKTextureInfo *textureInfo0  = [AGLKTextureLoader
                                    textureWithCGImage:imageRef0
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES],
                                    GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S value:GL_REPEAT];
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_T value:GL_REPEAT];
    
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
    
    [self.vertexbuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, normalCoords)
                                  shouldEnable:YES];
    
    [self.vertexbuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];

    
    [self.vertexbuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniform[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewPorjectionMatrix.m);
    glUniformMatrix3fv(uniform[UNIFORM_NORMAL_MATRIX], 1, 0, _normatMatrix.m);
    glUniform1i(uniform[UNIFORM_TEXTURE0_SAMPLER2D], 0);
    glUniform1i(uniform[UNIFORM_TEXTURE1_SAMPLER2D], 1);
    [self.vertexbuffer drawArrayWithMode:GL_TRIANGLE_STRIP
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)];
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
}


#pragma mark - OpenGL ES 2 shader compilation
- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
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

    // Attach vertex shader to program
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program
    glAttachShader(_program, fragShader);
    
    // Bind attribute location
    // This needs to done prior to linking
    glBindAttribLocation(_program, GLKVertexAttribPosition, "aPosition");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "aNormal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "aTextureCoord0");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord1, "aTextureCoord1");
    
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
    uniform[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "uNormalMatrix");
    uniform[UNIFORM_TEXTURE0_SAMPLER2D] = glGetUniformLocation(_program, "uSampler0");
    uniform[UNIFORM_TEXTURE1_SAMPLER2D] = glGetAttribLocation(_program, "uSampler1");
    
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
