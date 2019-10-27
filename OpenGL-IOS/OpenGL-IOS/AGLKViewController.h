//
//  AGLKViewController.h
//  OpenGL-IOS
//
//  Created by william on 2019/10/26.
//  Copyright © 2019 william. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGLKView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGLKViewController : UIViewController <AGLKViewDelegate>
{
    CADisplayLink   *displayLink;
    NSInteger       preferredFramesPerSecond;
}

@property (nonatomic) NSInteger preferredFramesPerSecond;
@property (nonatomic, readonly) NSInteger framesPerSecond;
@property (nonatomic, getter=isPaused) BOOL paused;


@end

NS_ASSUME_NONNULL_END
