//
//  PotraceViewController.m
//  OpenGL-IOS
//
//  Created by william on 2019/10/31.
//  Copyright © 2019 william. All rights reserved.
//

#import "PotraceViewController.h"

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

- (int)runPotroce
{
    int x, y, i;
    potrace_bitmap_t *bm;
    potrace_param_t *param;
    potrace_path_t *p;
    potrace_state_t *st;
    int n, *tag;
    // tag[i]表示第i条线段的类型1. #define POTRACE_CURVETO 1 2.#define POTRACE_CORNER 2
    potrace_dpoint_t (*c)[3];
    /* create a bitmap */
    bm = bm_new(WIDTH, HEIGHT);
    if (!bm) {
      fprintf(stderr, "Error allocating bitmap: %s\n", strerror(errno));
      return 1;
    }

    /* fill the bitmap with some pattern */
    for (y=0; y<HEIGHT; y++) {
      for (x=0; x<WIDTH; x++) {
        BM_PUT(bm, x, y, ((x*x + y*y*y) % 10000 < 5000) ? 1 : 0);
      }
    }

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
    printf("%%%%BoundingBox: 0 0 %d %d\n", WIDTH, HEIGHT);
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
      printf("%f %f lineto\n", c[i][1].x, c[i][1].y);
      printf("%f %f lineto\n", c[i][2].x, c[i][2].y);
      break;
        case POTRACE_CURVETO:
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
    return 0;
}

@end
