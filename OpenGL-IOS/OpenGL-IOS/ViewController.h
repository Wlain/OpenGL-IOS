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


@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexbuffer;

@property (nonatomic) BOOL isUseLinearFilter;
@property (nonatomic) BOOL isAnimate;
@property (nonatomic) BOOL isRepeatTexture;
@property (nonatomic) GLKVector2 sCoordinateOffset;
@property (weak, nonatomic) IBOutlet UILabel *labelT;
@property (weak, nonatomic) IBOutlet UILabel *label;

- (void)viewDidUnload;
@property (weak, nonatomic) IBOutlet UISlider *takeSCoordinateOffserFromT;

- (IBAction)takeSCoordinateOffsetFromT:(UISlider *)sender;
- (IBAction)takeSCoordinateOffsetFromS:(id)sender;
- (IBAction)takeShouldRepeatTextureForm:(UISwitch *)sender;
- (IBAction)takeShouldAnimateForm:(UISwitch *)sender;
- (IBAction)takeShouldUseLinearFilter:(UISwitch *)sender;

@end

