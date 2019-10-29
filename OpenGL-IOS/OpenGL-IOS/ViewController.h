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

