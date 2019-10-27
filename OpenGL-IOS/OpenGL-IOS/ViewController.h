//
//  ViewController.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/25.
//  Copyright © 2019 william. All rights reserved.
//
#import "AGLKViewController.h"
#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


@interface ViewController : AGLKViewController
{
    AGLKVertexAttribArrayBuffer *vertexBuffer;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexbuffer;

@end

