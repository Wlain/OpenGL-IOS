//
//  PotraceViewController.m
//  OpenGL-IOS
//
//  Created by william on 2019/10/31.
//  Copyright © 2019 william. All rights reserved.
//

#import "PotraceViewController.h"
#import <GLKit/GLKit.h>

/* return new un-initialized bitmap. NULL with errno on error */
static potrace_bitmap_t *bm_new(int w, int h) {
    potrace_bitmap_t *bm;
    int dy = (w + BM_WORDBITS - 1) / BM_WORDBITS;
 
    bm = (potrace_bitmap_t *) malloc(sizeof(potrace_bitmap_t));
    if (!bm) {
        return NULL;
    }
    bm->w = w;
    bm->h = h;
    bm->dy = dy;
    bm->map = (potrace_word *) calloc(h, dy * BM_WORDSIZE);
    if (!bm->map) {
        free(bm);
        return NULL;
    }
    return bm;
}
 
/* free a bitmap */
static void bm_free(potrace_bitmap_t *bm) {
    if (bm != NULL) {
        free(bm->map);
    }
    free(bm);
}

@implementation PotraceViewController

- (unsigned char *)uiimageToGray:(UIImage *)image
{
    size_t width  = image.size.width;
    NSAssert(width > 0, @"uiimageToGray:Invalid width");
    size_t height = image.size.height;
    NSAssert(height > 0, @"uiimageToGray:Invalid width");
    unsigned char *imageDate = (unsigned char*)malloc(width * height);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contexRef = CGBitmapContextCreate(imageDate, width, height, 8, width, colorSpaceRef, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpaceRef);
    UIGraphicsPushContext(contexRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(contexRef, rect, [image CGImage]);
    UIGraphicsPopContext();
    CGContextRelease(contexRef);
    return imageDate;
}


- (unsigned char*) uiimageToRGBA:(UIImage *)image
{
    size_t width  = image.size.width;
    NSAssert(width > 0, @"uiimageToGray:Invalid width");
    size_t height = image.size.height;
    NSAssert(height > 0, @"uiimageToGray:Invalid width");
    unsigned char* imageData = (unsigned char *) malloc(4 * width * height);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contexRef = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpaceRef, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpaceRef);
    UIGraphicsPushContext(contexRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage( contexRef, rect, [image CGImage] );
    UIGraphicsPopContext();
    CGContextRelease(contexRef);
    return imageData;
}

- (int)runPotroce:(float *)vertices
{
    int result = 0;
    UIImage *image =[UIImage imageNamed:@"test.png"];
    unsigned char *data = [self uiimageToRGBA:image];
    size_t width  = image.size.width;
    size_t height = image.size.height;
    int x, y, i = 0;
    unsigned char *tempData = data;
    unsigned char *redDate = (unsigned char *)malloc(height * width * sizeof(unsigned char));
    memset(redDate, 0, height * width * sizeof(unsigned char));
    for (y = 0, i = 0; y < height * width; y++, i++) {
        redDate[i] = tempData[1];
        tempData += 4;
    }
    potrace_bitmap_t *bm;
    potrace_param_t *param;
    potrace_path_t *p;
    potrace_state_t *st;
    int n, *tag;
    // tag[i]表示第i条线段的类型1. #define POTRACE_CURVETO 1 2.#define POTRACE_CORNER 2
    potrace_dpoint_t (*c)[3];
    /* create a bitmap */
    bm = bm_new((int)width, (int)height);
    if (!bm) {
      fprintf(stderr, "Error allocating bitmap: %s\n", strerror(errno));
      return 1;
    }
    /* fill the bitmap with some pattern */
    for (y=0; y<height; y++) {
      for (x=0; x<width; x++) {
        BM_PUT(bm, x, (height - y), (redDate[x + y * width] < 250) ? 1 : 0);
      }
    }
    free(redDate);
    /* set tracing parameters, starting from defaults */
    param = potrace_param_default();
    if (!param) {
      fprintf(stderr, "Error allocating parameters: %s\n", strerror(errno));
      return 1;
    }
    param->turdsize = 2;

    /* trace the bitmap */
    st = potrace_trace(param, bm);
    if (!st || st->status != POTRACE_STATUS_OK) {
      fprintf(stderr, "Error tracing bitmap: %s\n", strerror(errno));
      return 1;
    }
    bm_free(bm);
    
    /* output vector data, e.g. as a rudimentary EPS file */
    printf("%%!PS-Adobe-3.0 EPSF-3.0\n");
    printf("%%%%BoundingBox: 0 0 %zu %zu\n", width, height);
    printf("gsave\n");

    /* draw each curve */
    p = st->plist;
    while (p != NULL) {
        n = p->curve.n;
        tag = p->curve.tag;
        c = p->curve.c;
        printf("%f %f moveto\n", c[n-1][2].x, c[n-1][2].y);
        for (i=0; i<n; i++) {
            switch (tag[i]) {
                case POTRACE_CORNER:
                {
                    vertices[result++] = c[i][1].x/width * 2 - 1.0;
                    vertices[result++] = c[i][1].y/height * 2 - 1.0;
                    vertices[result++] = c[i][2].x/width * 2 - 1.0;
                    vertices[result++] = c[i][2].y/height * 2 - 1.0;
                    printf("%f %f lineto\n", c[i][1].x, c[i][1].y);
                    printf("%f %f lineto\n", c[i][2].x, c[i][2].y);
                    break;
                }
                case POTRACE_CURVETO:
                {
                    vertices[result++] = c[i][0].x/width * 2 - 1.0;
                    vertices[result++] = c[i][0].y/height * 2 - 1.0;
                    vertices[result++] = c[i][1].x/width * 2 - 1.0;
                    vertices[result++] = c[i][1].y/height * 2 - 1.0;
                    vertices[result++] = c[i][2].x/width * 2 - 1.0;
                    vertices[result++] = c[i][2].y/height * 2 - 1.0;
                    printf("%f %f %f %f %f %f curveto\n",
                           c[i][0].x, c[i][0].y,
                           c[i][1].x, c[i][1].y,
                           c[i][2].x, c[i][2].y);
                    break;
                }
            }
        }
        /* at the end of a group of a positive path and its negative
            children, fill. */
        if (p->next == NULL || p->next->sign == '+') {
            printf("0 setgray fill\n");
        }
        p = p->next;
    }
    printf("grestore\n");
    printf("%%EOF\n");
    
    potrace_state_free(st);
    potrace_param_free(param);
    return result;
}
@end
