//
//  AGLKView.m
//  OpenGL-IOS
//
//  Created by william on 2019/10/26.
//  Copyright © 2019 william. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AGLKView

@synthesize delegate;
@synthesize context;

@synthesize drawableDepthFormat;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
            context:(EAGLContext *)aContext;
{
    if ((self = [super initWithFrame: frame]))
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties =
            [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO],
            kEAGLDrawablePropertyRetainedBacking,
            kEAGLColorFormatRGBA8,
            kEAGLDrawablePropertyColorFormat,
            nil];
        self.context = aContext;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties =
            [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO],
            kEAGLDrawablePropertyRetainedBacking,
            kEAGLColorFormatRGBA8,
            kEAGLDrawablePropertyColorFormat,
            nil];
    }
    return self;
}

- (void)setContext:(EAGLContext *)aContext
{
    if (context != aContext)
    {
        [EAGLContext setCurrentContext:context];
        
        if (0 != defaultFrameBuffer)
        {
            glDeleteFramebuffers(1, &defaultFrameBuffer); // Step 7
            defaultFrameBuffer = 0;
        }
        
        if (0 != colorRenderBuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderBuffer); // Step 7
            colorRenderBuffer = 0;
        }
        
        if (0 != depthRenderBuffer)
        {
            glDeleteRenderbuffers(1, &depthRenderBuffer); //Step 7
            depthRenderBuffer = 0;
        }
        
        context = aContext;
        
        if (nil != context)
        {
            context = aContext;
            [EAGLContext setCurrentContext:context];
            
            glGenFramebuffers(1, &defaultFrameBuffer);              // Step 1
            glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);  // Step 2
            
            glGenRenderbuffers(1, &colorRenderBuffer);              // Step 1
            glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);       // Step 2
            
            glFramebufferRenderbuffer(
                  GL_FRAMEBUFFER,
                  GL_COLOR_ATTACHMENT0,
                  GL_RENDERBUFFER,
                  colorRenderBuffer);
            
            [self layoutSubviews];
        }
    }
}

- (EAGLContext *)context
{
    return context;
}

- (void)display;
{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, (GLsizei)self.drawableWidth, (GLsizei)self.drawableHeight);
    
    [self drawRect:[self bounds]];
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (void)drawRect:(CGRect)rect
{
    if(delegate)
    {
        [self.delegate glkView:self drawInRect:[self bounds]];
    }
}


- (void)layoutSubviews
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    [EAGLContext setCurrentContext:self.context];
    
    [self.context renderbufferStorage:GL_RENDERBUFFER
                         fromDrawable:eaglLayer];
    
    if(0 != depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &depthRenderBuffer); // Step 7
        depthRenderBuffer = 0;
    }
    
    GLint currentDrawableWidth  = (GLint)self.drawableWidth;
    GLint currentDrawableHeight = (GLint)self.drawableHeight;
    
    if(self.drawableDepthFormat !=
        AGLKViewDrawableDepthFormatNone &&
        0 < currentDrawableWidth &&
        0 < currentDrawableHeight)
    {
        glGenRenderbuffers(1, &depthRenderBuffer);          // Step 1;
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);   // Step 2
        
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, currentDrawableWidth, currentDrawableHeight);                         // Step 3
        
        glFramebufferRenderbuffer(GL_RENDERBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
                  // Step 3
    }
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    if(status != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"failed to make complete frame buffer object %x", status);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
}

- (NSInteger)drawableWidth;
{
    GLint       backingWidth;
    
    glGetRenderbufferParameteriv(
         GL_RENDERBUFFER,
         GL_RENDERBUFFER_WIDTH,
         &backingWidth);
    return (NSInteger)backingWidth;
}

- (NSInteger)drawableHeight;
{
    GLint       backingHeight;
    
    glGetRenderbufferParameteriv(
         GL_RENDERBUFFER,
         GL_RENDERBUFFER_HEIGHT,
         &backingHeight);
    return (NSInteger)backingHeight;
}


- (void)dealloc
{
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    context = nil;
}

@end
