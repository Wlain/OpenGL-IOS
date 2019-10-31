//
//  ViewController.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/25.
//  Copyright © 2019 william. All rights reserved.
//
#import <GLKit/GLKit.h>
#import "PotraceViewController.h"

@class AGLKVertexAttribArrayBuffer;


@interface ViewController : GLKViewController
{
    GLuint _program;
    
    GLKMatrix4 _modelViewPorjectionMatrix;
    GLKMatrix3 _normatMatrix;
    GLfloat _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _texture0ID;
    GLuint _texture1ID;
}

@property (strong, nonatomic) PotraceViewController *potrace;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexbuffer;


- (void)viewDidUnload;


@end

