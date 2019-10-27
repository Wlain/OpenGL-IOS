//
//  AGLKViewController.m
//  OpenGL-IOS
//
//  Created by william on 2019/10/26.
//  Copyright © 2019 william. All rights reserved.
//

#import "AGLKViewController.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger kAGLKDefaultFramesPerSecond = 30;

@implementation AGLKViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    if(nil != (self = [super initWithNibName:nibNameOrNil
                                      bundle:nibBundleOrNil]))
    {
        displayLink =
            [CADisplayLink displayLinkWithTarget:self
                                        selector:@selector(drawView:)];
        self.preferredFramesPerSecond =
            kAGLKDefaultFramesPerSecond;
        
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
         forMode:NSDefaultRunLoopMode];
        
        self.paused = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (nil != (self = [super initWithCoder:aDecoder])) {
        displayLink =
            [CADisplayLink displayLinkWithTarget:self
                                        selector:@selector(drawView:)];
        self.preferredFramesPerSecond =
            kAGLKDefaultFramesPerSecond;
        
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
        
        self.paused = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]],
             @"View controller's view is not a AGLKView");
    view.opaque = YES;
    view.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    self.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.paused = YES;
}

- (void) drawView:(id)sender
{
    [(AGLKView *)self.view display];
}


- (NSInteger)framesPerSecond;
{
    return 60 / displayLink.frameInterval;
}

- (NSInteger)preferredFramesPerSecond
{
    return preferredFramesPerSecond;
}

- (void)setPreferredFramesPerSecond:(NSInteger)aValue
{
    preferredFramesPerSecond = aValue;
    displayLink.frameInterval = MAX(1, 60 / aValue);
}

- (BOOL)isPaused
{
    return displayLink.paused;
}

- (void) setPaused:(BOOL)aValue
{
    displayLink.paused = aValue;
}

- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect
{
    
}

@end
