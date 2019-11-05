//
//  ViewController.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/25.
//  Copyright © 2019 william. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#import <GLKit/GLKit.h>
#import "PotraceViewController.h"

@class AGLKVertexAttribArrayBuffer;


@interface ViewController : GLKViewController
{
    GLuint _program;
    GLKMatrix4 _modelViewPorjectionMatrix;
    
    float *_verticesData;
    int    _verticesNum;
}

@property (strong, nonatomic) PotraceViewController *potrace;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexbuffer;


- (void)viewDidUnload;


@end

