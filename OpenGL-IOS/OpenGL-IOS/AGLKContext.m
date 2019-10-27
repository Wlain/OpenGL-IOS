//
//  AGLKContext.m
//  OpenGL-IOS
//
//  Created by william on 2019/10/26.
//  Copyright © 2019 william. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext

- (void)setClearColor:(GLKVector4)clearColorRGBA
{
    clearColor = clearColorRGBA;
    
    NSAssert(self == [[self class] currentContext],
             @"Receiving context rquired to be current context");
    glClearColor(clearColorRGBA.r, clearColorRGBA.g, clearColorRGBA.b, clearColorRGBA.a);
}


- (GLKVector4)clearColor
{
    return clearColor;
}

- (void) clear:(GLbitfield)mask
{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to current context");
    
    glClear(mask);
}

- (void)enable:(GLenum)capability
{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to current context");
    
    glEnable(capability);
}

- (void)disable:(GLenum)capability
{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to current context");
    
    glDisable(capability);
}

- (void) setBlendSourceFunction:(GLenum)sfactor
            distinationFunction:(GLenum)dfactor
{
    glBlendFunc(sfactor, dfactor);
}
@end
