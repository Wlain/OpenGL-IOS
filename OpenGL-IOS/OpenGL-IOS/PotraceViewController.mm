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


- (unsigned char *)uiimage2Gray:(UIImage *)image
{
    size_t width  = image.size.width;
    size_t height = image.size.height;
    if (width <= 0 || height <= 0) {
        return 0;
    }
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


// 返回一个基于c带有图片数据的的bitmap
- (unsigned char*) uiimage2RGBA:(UIImage *)image
{
    size_t width  = image.size.width;
    size_t height = image.size.height;
    if(width == 0 || height == 0)
        return 0;
    unsigned char* imageData = (unsigned char *) malloc(4 * width * height);
    
    CGColorSpaceRef cref = CGColorSpaceCreateDeviceRGB();
    CGContextRef gc = CGBitmapContextCreate(imageData,
                                            width,height,
                                            8,width*4,
                                            cref,kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(cref);
    UIGraphicsPushContext(gc);
    
    CGRect rect = {{ 0 , 0 }, {(CGFloat)width, (CGFloat)height }};
    CGContextDrawImage( gc, rect, [image CGImage] );
    UIGraphicsPopContext();
    CGContextRelease(gc);
    return imageData;// CGBitmapContextGetData(gc);
}

- (int)runPotroce:(float *)vertices
{
    int result = 0;
    UIImage *image =[UIImage imageNamed:@"test.png"];
    unsigned char *data = [self uiimage2RGBA:image];
    size_t width  = image.size.width;
    size_t height = image.size.height;
    int x, y, i;
    unsigned char *temp = data;
    unsigned char *redDate = (unsigned char *)malloc(height * width * sizeof(unsigned char));
    memset(redDate, 0, height * width * sizeof(unsigned char));
    i = 0;
    for (y = 0; y < height * width; y++) {
        redDate[i] = temp[1];
        temp += 4;
        i++;
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
//          BM_PUT(bm, x, (height - y), (x > 50 && x < 150 && y > 50 && y < 150) ? 1 : 0);
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
    printf("%%%%BoundingBox: 0 0 %d %d\n", width, height);
    printf("gsave\n");

    /* draw each curve */
    p = st->plist;
    while (p != NULL) {
      n = p->curve.n;
      tag = p->curve.tag;
      c = p->curve.c;
//      vertices[result++] = c[n-1][2].x/width * 2 - 1.0;
//      vertices[result++] = c[n-1][2].y/height  * 2 - 1.0;
//      printf("%f %f moveto\n", c[n-1][2].x/width * 2 - 1.0, c[n-1][2].y/height  * 2 - 1.0);
        printf("%f %f moveto\n", c[n-1][2].x, c[n-1][2].y);
      for (i=0; i<n; i++) {
        switch (tag[i]) {
        case POTRACE_CORNER:
        vertices[result++] = c[i][1].x/width * 2 - 1.0;
        vertices[result++] = c[i][1].y/height * 2 - 1.0;
        vertices[result++] = c[i][2].x/width * 2 - 1.0;
        vertices[result++] = c[i][2].y/height * 2 - 1.0;
                printf("%f %f lineto\n", c[i][1].x, c[i][1].y);
                printf("%f %f lineto\n", c[i][2].x, c[i][2].y);
//      printf("%f %f \n", c[i][1].x/width * 2 - 1.0, c[i][1].y/height * 2 - 1.0);
//      printf("%f %f \n", c[i][2].x/width * 2 - 1.0, c[i][2].y/height * 2 - 1.0);
      break;
        case POTRACE_CURVETO:
                vertices[result++] = c[i][0].x/width * 2 - 1.0;
                vertices[result++] = c[i][0].y/height * 2 - 1.0;
                vertices[result++] = c[i][1].x/width * 2 - 1.0;
                vertices[result++] = c[i][1].y/height * 2 - 1.0;
                vertices[result++] = c[i][2].x/width * 2 - 1.0;
                vertices[result++] = c[i][2].y/height * 2 - 1.0;
//      printf("%f %f %f %f %f %f \n",
//             c[i][0].x/width * 2 - 1.0, c[i][0].y/height * 2 - 1.0,
//             c[i][1].x/width * 2 - 1.0, c[i][1].y/height * 2 - 1.0,
//             c[i][2].x/width * 2 - 1.0, c[i][2].y/height * 2 - 1.0);
                printf("%f %f %f %f %f %f curveto\n",
                c[i][0].x, c[i][0].y,
                c[i][1].x, c[i][1].y,
                c[i][2].x, c[i][2].y);
      break;
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
