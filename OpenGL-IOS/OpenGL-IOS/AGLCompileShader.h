//
//  AGLCompileShader.h
//  OpenGL-IOS
//
//  Created by william on 2019/11/5.
//  Copyright © 2019 william. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLCompileShader : NSObject

// GLSL program uniform indices
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    NUM_NUNIFORMS,
};

// GLSL Program uniform IDs
@property (nonatomic, assign) GLint *uniform;

@property (nonatomic, assign) GLuint program;
    
#pragma mark - OpenGL ES 2 shader compilation
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)program;
- (BOOL)validateProgram:(GLuint)program;

@end

NS_ASSUME_NONNULL_END
