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

// vertex info
typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}
SceneVertex;

static SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}},
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
    {{ 0.5f,  0.5f, 0.0f}, {1.0f, 1.0f}},
};


static const SceneVertex defaultVertices[] =
{
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}},
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
    {{ 0.5f,  0.5f, 0.0f}, {1.0f, 1.0f}},
};

static GLKVector3 movementVectors[4] = {
    {-0.02f,  - 0.01f, 0.0f},
    {-0.02f,  - 0.01f, 0.0f},
    {-0.02f,  - 0.01f, 0.0f},
    {-0.02f,  - 0.01f, 0.0f},
};

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

@implementation ViewController

@synthesize baseEffect;
@synthesize vertexbuffer;
@synthesize isUseLinearFilter;
@synthesize isAnimate;
@synthesize isRepeatTexture;
@synthesize sCoordinateOffset;


// Update the current OpenGL ES contest texture wrapping mode
- (void)updateTextureParamters
{
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S
                                           value:(self.isRepeatTexture ? GL_REPEAT : GL_CLAMP_TO_EDGE)];;
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_MAG_FILTER
                                           value:(self.isUseLinearFilter ? GL_LINEAR : GL_NEAREST)];
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_T
                                           value:(self.isRepeatTexture ? GL_REPEAT : GL_CLAMP_TO_EDGE)];;
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_MIN_FILTER
                                           value:(self.isUseLinearFilter ? GL_LINEAR : GL_NEAREST)];
}


// animation
- (void)updateAnimatedVertexPositions
{
    if(isAnimate)
    {
        int i;
        for (i = 0; i < 4; i++) {
            vertices[i].positionCoords.x += movementVectors[i].x;
            if (vertices[i].positionCoords.x >= 1.0f ||
                vertices[i].positionCoords.x <= -1.0f)
            {
                movementVectors[i].x = -movementVectors[i].x;
            }
            vertices[i].positionCoords.y += movementVectors[i].y;
            if (vertices[i].positionCoords.y >= 1.0f ||
                vertices[i].positionCoords.y <= -1.0f)
            {
                movementVectors[i].y = -movementVectors[i].y;
            }
            vertices[i].positionCoords.z += movementVectors[i].z;
            if (vertices[i].positionCoords.z >= 1.0f ||
                vertices[i].positionCoords.z <= -1.0f)
            {
                movementVectors[i].z = -movementVectors[i].z;
            }
        }
    }
    else
    {
        int i;
        for (i = 0; i < 4; i++) {
            vertices[i].positionCoords.x =
                defaultVertices[i].positionCoords.x;
            vertices[i].positionCoords.y =
                defaultVertices[i].positionCoords.y;
            vertices[i].positionCoords.z =
                defaultVertices[i].positionCoords.z;
        }
    }
    
    {
        // Adjust the S texture coordinates to slide texture
        int i;
        for (i = 0; i < 4; i++) {
            vertices[i].textureCoords.s =
                (defaultVertices[i].textureCoords.s + sCoordinateOffset.s);
        }
        // Adjust the T texture coordinates to slide texture
        for (i = 0; i < 4; i++) {
            vertices[i].textureCoords.t =
                (defaultVertices[i].textureCoords.t + sCoordinateOffset.t);
        }
    }
}

- (void)update
{
    [self updateAnimatedVertexPositions];
    [self updateTextureParamters];
    
    [vertexbuffer reinitWithAttribStride:sizeof(SceneVertex)
                        numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)
                                   bytes:vertices];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredFramesPerSecond = 60;
    self.isAnimate = YES;
    self.isRepeatTexture = YES;
        
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]], @"View Controller's view is not a AGLKView");
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
   
    self.vertexbuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                         bytes:vertices usage:GL_STATIC_DRAW];
    
    // Setup texture
    CGImageRef imageRef =
    [[UIImage imageNamed:@"test.jpg"] CGImage];
    
    AGLKTextureInfo *textureInfo  = [AGLKTextureLoader
                                    textureWithCGImage:imageRef
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES],
                                    GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
    // Setup texture
    CGImageRef imageRef1 =
    [[UIImage imageNamed:@"leaves.gif"] CGImage];
    AGLKTextureInfo *textureInfo1  = [AGLKTextureLoader
                                    textureWithCGImage:imageRef1
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES],
                                    GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
}

// AGLKView
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffect prepareToDraw];
    [self update];
    // Clear Frame Buffer (erase previous drawing)
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexbuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    [self.vertexbuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                           numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];

    
    [self.vertexbuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
                           numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    [self.baseEffect prepareToDraw];
    [self.vertexbuffer drawArrayWithMode:GL_TRIANGLE_STRIP
                        startVertexIndex:0
                        numberOfVertices:4];
}


// clean-up
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Make the view's context current
    AGLKView *view = (AGLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.vertexbuffer = nil;
    

    // clean up
    ((AGLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}


- (IBAction)takeSCoordinateOffsetFromT:(UISlider *)sender
{
    sCoordinateOffset.t = [sender value];
    self.labelT.text = [NSString stringWithFormat:@"%d%%", (int)(sender.value * 100)];
}

- (IBAction)takeSCoordinateOffsetFromS:(UISlider *)sender {
    sCoordinateOffset.s = [sender value];
    self.label.text = [NSString stringWithFormat:@"%d%%", (int)(sender.value * 100)];
}

- (IBAction)takeShouldRepeatTextureForm:(UISwitch *)sender
{
    self.isRepeatTexture = [sender isOn];
}

- (IBAction)takeShouldAnimateForm:(UISwitch *)sender {
    self.isAnimate = [sender isOn];
}

- (IBAction)takeShouldUseLinearFilter:(UISwitch *)sender {
    self.isUseLinearFilter = [sender isOn];
}


@end
