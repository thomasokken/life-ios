//
//  LifeView.m
//  Life
//
//  Created by Thomas Okken on 4/3/22.
//

#import "LifeView.h"

#import <Foundation/Foundation.h>

@implementation LifeView

@synthesize speedSlider;

#define SCALE 2

static unsigned short crc16[] = {
    0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241,
    0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
    0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
    0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
    0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40,
    0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
    0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641,
    0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
    0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
    0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
    0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41,
    0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
    0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41,
    0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
    0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
    0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
    0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240,
    0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
    0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41,
    0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
    0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
    0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
    0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
    0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
    0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241,
    0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
    0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
    0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
    0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40,
    0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
    0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641,
    0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040
};

/* number of generations to keep track of for detecting loops */
#define HISTORY 32

/* number of times a loop must be detected before I actually restart */
#define PATIENCE 100

static uint32_t *bits1 = NULL, *bits2 = NULL;
static int width = 0, height = 0, stride;
static unsigned int history[HISTORY];
static int repeats;
static float delay = 8;

- (void) restart {
    int size = stride * height;
    int w = self.bounds.size.width / SCALE;
    int h = self.bounds.size.height / SCALE;
    if (w != width || h != height) {
        width = w;
        height = h;
        free(bits1);
        free(bits2);
        stride = (width + 31) >> 5;
        size = stride * height;
        bits1 = (uint32_t *) malloc(size * 4);
        bits2 = (uint32_t *) malloc(size * 4);
    }
    for (int i = 0; i < size; i++) {
        bits1[i] = (uint32_t) (((random() & 255) << 24)
                    | ((random() & 255) << 16)
                    | ((random() & 255) << 8)
                    | (random() & 255));
    }
    repeats = PATIENCE;
    memset(history, 0, HISTORY * sizeof(unsigned int));
}

- (IBAction) speedSliderUpdated {
    delay = [speedSlider value];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self restart];
    [self setNeedsDisplay];
    [speedSlider setValue:delay];
    speedSlider.hidden = YES;
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:recog];
    [self performSelector:@selector(worker) withObject:nil afterDelay:pow(2, -delay)];
}

- (void) handleTap:(UITapGestureRecognizer *)recog {
    speedSlider.hidden = !speedSlider.isHidden;
}

- (void) drawRect:(CGRect)rect {
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(myContext, SCALE, SCALE);
    CGContextSetRGBFillColor(myContext, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(myContext, [self bounds]);
    CGContextSetRGBFillColor(myContext, 0.0, 0.0, 0.0, 1.0);
    CGRect r;
    r.size.width = r.size.height = 1;
    uint32_t *p = bits1;
    for (int v = 0; v < height; v++)
        for (int h = 0; h < stride; h++) {
            uint32_t w = *p++;
            for (int hh = 0; hh < 32; hh++) {
                if (w & 1) {
                    r.origin.x = (h << 5) | hh;
                    r.origin.y = v;
                    CGContextFillRect(myContext, r);
                }
                w >>= 1;
            }
        }
}

- (void) worker {
    int index = 0;
    int aboveindex = -stride;
    int belowindex = stride;
    uint32_t rightedgemask = 0xffffffff >> (31 - (width - 1 & 31));
    int crc = 0;

    if (repeats == 0 || self.bounds.size.width / SCALE != width || self.bounds.size.height / SCALE != height) {
        [self restart];
        goto done;
    }
    
    for (int y = 0; y < height; y++) {
        bool notattop = y != 0;
        bool notatbottom = y != height - 1;
        for (int x = 0; x < stride; x++) {
            uint32_t s0, s1, s2, s3, r;
            uint32_t w00, w01, w02, w10, w11, w12, w20, w21, w22;
            w10 = notattop ? *((uint32_t *) (bits1 + aboveindex)) : 0;
            w11 = *((uint32_t *) (bits1 + index));
            w12 = notatbottom ? *((uint32_t *) (bits1 + belowindex)) : 0;
            if (x == stride - 1) {
                w10 &= rightedgemask;
                w11 &= rightedgemask;
                w12 &= rightedgemask;
            }
            w00 = w10 << 1;
            w01 = w11 << 1;
            w02 = w12 << 1;
            if (x != 0) {
                if (notattop && *((uint32_t *) (bits1 + aboveindex - 1)) & 0x80000000)
                    w00 |= 1;
                if (*((uint32_t *) (bits1 + index - 1)) & 0x80000000)
                    w01 |= 1;
                if (notatbottom && *((uint32_t *) (bits1 + belowindex - 1)) & 0x80000000)
                    w02 |= 1;
            }
            w20 = w10 >> 1;
            w21 = w11 >> 1;
            w22 = w12 >> 1;
            if (x != stride - 1) {
                if (notattop && *((uint32_t *) (bits1 + aboveindex + 1)) & 1)
                    w20 |= 0x80000000;
                if (*((uint32_t *) (bits1 + index + 1)) & 1)
                    w21 |= 0x80000000;
                if (notatbottom && *((uint32_t *) (bits1 + belowindex + 1)) & 1)
                    w22 |= 0x80000000;
            }

            s1 =      w00;
            s0 =                 ~w00;

            s2 = s1 & w01;
            s1 = s0 & w01 | s1 & ~w01;
            s0 =            s0 & ~w01;

            s3 = s2 & w02;
            s2 = s1 & w02 | s2 & ~w02;
            s1 = s0 & w02 | s1 & ~w02;
            s0 =            s0 & ~w02;

            s3 = s2 & w10 | s3 & ~w10;
            s2 = s1 & w10 | s2 & ~w10;
            s1 = s0 & w10 | s1 & ~w10;
            s0 =            s0 & ~w10;

            s3 = s2 & w12 | s3 & ~w12;
            s2 = s1 & w12 | s2 & ~w12;
            s1 = s0 & w12 | s1 & ~w12;
            s0 =            s0 & ~w12;

            s3 = s2 & w20 | s3 & ~w20;
            s2 = s1 & w20 | s2 & ~w20;
            s1 = s0 & w20 | s1 & ~w20;
            s0 =            s0 & ~w20;

            s3 = s2 & w21 | s3 & ~w21;
            s2 = s1 & w21 | s2 & ~w21;
            s1 = s0 & w21 | s1 & ~w21;

            s3 = s2 & w22 | s3 & ~w22;
            s2 = s1 & w22 | s2 & ~w22;

            r = s3 | s2 & w11;
            if (x == stride - 1)
                r &= rightedgemask;
            *((uint32_t *) (bits2 + index)) = r;
            
            for (int i = 0; i < 4; i++) {
                crc = crc >> 8 ^ crc16[crc & 0xFF ^ r & 0xFF];
                r >>= 8;
            }

            index++;
            aboveindex++;
            belowindex++;
        }
    }

    uint32_t *temp = bits1;
    bits1 = bits2;
    bits2 = temp;
    
    /* I use 16-bit CRCs to detect loops.
     * Finding a matching CRC is not an absolute guarantee that a loop
     * is occurring; for this reason, I wait until I detect PATIENCE
     * consecutive matches. The maximum loop length that I detect is
     * given by HISTORY. Don't set this to a too-high value; long loops
     * are bound to be interesting so you don't want to miss them just
     * because you left the room for a minute.
     * TODO: how about setting HISTORY to something way high, and
     * adding some code that checks game and loop length after
     * termination, and saves the initial state for games with long
     * durations and/or long loops?
    */
    bool hit = false;
    for (int i = 0; i < HISTORY; i++) {
        if (crc == history[i])
            hit = true;
        if (i == HISTORY - 1)
            history[i] = crc;
        else
            history[i] = history[i + 1];
    }
    if (hit)
        repeats--;
    else
        repeats = PATIENCE;

    done:
    [self setNeedsDisplay];
    [self performSelector:@selector(worker) withObject:nil afterDelay:pow(2, -delay)];
}

@end
