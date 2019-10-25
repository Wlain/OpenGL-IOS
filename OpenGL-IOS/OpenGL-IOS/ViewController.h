//
//  ViewController.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/25.
//  Copyright © 2019 william. All rights reserved.
//


#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController
{
    GLint vertexBufferID;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;


@end

