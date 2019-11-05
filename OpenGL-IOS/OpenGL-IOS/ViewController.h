//
//  ViewController.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/25.
//  Copyright © 2019 william. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#import "PotraceViewController.h"
#import "AGLCompileShader.h"
#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;

@interface ViewController : GLKViewController
{
    GLKMatrix4 _modelViewPorjectionMatrix;
    
    float *_verticesData;
    int    _verticesNum;
}

@property (strong, nonatomic) AGLCompileShader *shader;

@property (strong, nonatomic) PotraceViewController *potrace;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexbuffer;


- (void)viewDidUnload;


@end

