//
//  AGLCompileShader.m
//  OpenGL-IOS
//
//  Created by william on 2019/11/5.
//  Copyright © 2019 william. All rights reserved.
//

#import "AGLCompileShader.h"

@implementation AGLCompileShader

//@synthesize program;

- (id) init
{
    if (nil != (self = [super init])) {
        _program = 0;
        _uniform = (GLint *)malloc(sizeof(GLint) * NUM_NUNIFORMS);
    }
    return self;
}

- (void)dealloc
{
    _program = 0;
    if (_uniform)
        free(_uniform);
}


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
    _uniform[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "uModelViewProjectionMatrix");
    
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
