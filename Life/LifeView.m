//
//  LifeView.m
//  Life
//
//  Created by Thomas Okken on 4/3/22.
//

#import "LifeView.h"

#import <Foundation/Foundation.h>

@implementation LifeView

@synthesize scaleSlider;
@synthesize speedSlider;
@synthesize stopButton;
@synthesize stepButton;
@synthesize restartButton;
@synthesize paintSwitch;
@synthesize scaleLabel;
@synthesize speedLabel;
@synthesize paintLabel;
@synthesize kopyButton;
@synthesize pasteButton;

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
static UIInterfaceOrientation orientation;
static unsigned int history[HISTORY];
static int repeats;
static float delay;
static double pixelScale;
static float zoom = 1, zoom_orig;
static float offset_x, offset_y, offset_x_orig, offset_y_orig;
static bool resized = true;
static time_t ui_hide_time = 0;
static bool paused = false;
static bool painting = false;
static CGSize screenSize;
static bool gesturing = false;
static char *stateFileName;

static unsigned char *pbits;
static int pwidth, pheight, pstride, px, py, px_orig, py_orig;

static bool read_w(FILE *f, uint32_t *w) {
    uint32_t r = 0;
    for (int p = 0; p < 32; p += 8) {
        int c = fgetc(f);
        if (c == EOF)
            return false;
        r |= c << p;
    }
    *w = r;
    return true;
}

static void write_w(FILE *f, uint32_t w) {
    for (int i = 0; i < 4; i++) {
        fputc(w, f);
        w >>= 8;
    }
}

- (void) setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    if (bounds.size.width != screenSize.width || bounds.size.height != screenSize.height) {
        screenSize = bounds.size;
        resized = true;
    }
}

- (void) restart {
    int size = stride * height;
    if (resized) {
        int oldwidth = width;
        int oldheight = height;
        int oldstride = stride;
        UIInterfaceOrientation oldorientation = orientation;
        orientation = [UIApplication sharedApplication].statusBarOrientation;
        resized = false;
        width = self.bounds.size.width / pixelScale;
        height = self.bounds.size.height / pixelScale;
        offset_x = width / 2.0;
        offset_y = height / 2.0;
        stride = (width + 31) >> 5;
        size = stride * height;
        if (width == oldheight && height == oldwidth) {
            /* Just transpose the old bitmap; no other action */
            free(bits2);
            bits2 = (uint32_t *) malloc(size * 4 + 4);
            bool rotateLeft = oldorientation == UIInterfaceOrientationPortrait
                              && orientation == UIInterfaceOrientationLandscapeRight
                           || oldorientation == UIInterfaceOrientationLandscapeRight
                              && orientation == UIInterfaceOrientationPortraitUpsideDown
                           || oldorientation == UIInterfaceOrientationPortraitUpsideDown
                              && orientation == UIInterfaceOrientationLandscapeLeft
                           || oldorientation == UIInterfaceOrientationLandscapeLeft
                              && orientation == UIInterfaceOrientationPortrait;
            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++) {
                    int ox, oy;
                    if (rotateLeft) {
                        ox = height - y - 1;
                        oy = x;
                    } else {
                        ox = y;
                        oy = width - x - 1;
                    }
                    if ((bits1[oy * oldstride + (ox >> 5)] >> (ox & 31)) & 1)
                        bits2[y * stride + (x >> 5)] |= 1 << (x & 31);
                    else
                        bits2[y * stride + (x >> 5)] &= ~(1 << (x & 31));
                }
            free(bits1);
            bits1 = bits2;
            bits2 = (uint32_t *) malloc(size * 4 + 4);
        } else {
            /* Preserve bitmap as far as possible */
            free(bits2);
            bits2 = (uint32_t *) malloc(size * 4 + 4);
            memset(bits2, 0, size * 4);
            int dx = (width - oldwidth) / 2;
            int dy = (height - oldheight) / 2;
            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++) {
                    int ox = x - dx;
                    int oy = y - dy;
                    if (ox >= 0 && ox < oldwidth && oy >= 0 && oy < oldheight)
                        if ((bits1[oy * oldstride + (ox >> 5)] >> (ox & 31)) & 1)
                            bits2[y * stride + (x >> 5)] |= 1 << (x & 31);
                        else
                            bits2[y * stride + (x >> 5)] &= ~(1 << (x & 31));
                }
            free(bits1);
            bits1 = bits2;
            bits2 = (uint32_t *) malloc(size * 4 + 4);
        }
    } else {
        /* Not resized, so we're here because the pattern has been repeating itself.
         * Reinitialize with randomness.
         */
        for (int i = 0; i < size; i++) {
            bits1[i] = (uint32_t) (((random() & 255) << 24)
                        | ((random() & 255) << 16)
                        | ((random() & 255) << 8)
                        | (random() & 255));
        }
        repeats = PATIENCE;
        memset(history, 0, HISTORY * sizeof(unsigned int));
    }
    [self setNeedsDisplay];
}

- (IBAction) scaleSliderUpdated {
    int s = (int) (scaleSlider.value + 0.5);
    scaleSlider.value = s;
    [[NSUserDefaults standardUserDefaults] setInteger:(s + 1) forKey:@"scale"];
    double oldPixelScale = pixelScale;
    pixelScale = (1 << s) / [[UIScreen mainScreen] scale];
    if (oldPixelScale != pixelScale)
        resized = true;
    ui_hide_time = time(NULL) + 15;
}

- (IBAction) speedSliderUpdated {
    delay = [speedSlider value];
    [[NSUserDefaults standardUserDefaults] setInteger:(delay + 1) forKey:@"delay"];
    ui_hide_time = time(NULL) + 15;
}

- (IBAction) paintToggled:(id)sender {
    ui_hide_time = time(NULL) + 15;
    painting = [paintSwitch isOn];
    if (painting)
        paused = true;
    [[NSUserDefaults standardUserDefaults] setBool:painting forKey:@"painting"];
    [[NSUserDefaults standardUserDefaults] setBool:paused forKey:@"paused"];
    [self setNeedsDisplay];
}

static UIPanGestureRecognizer *oneFingerPan;

struct dot {
    int x, y;
    bool set;
    struct dot *next;
};

static struct dot *lastDraw = NULL;
static struct dot *undoableDraw = NULL;

static void rememberDot(int x, int y) {
    struct dot *d = lastDraw;
    while (d != NULL) {
        if (d->x == x && d->y == y)
            return;
        d = d->next;
    }
    d = (struct dot *) malloc(sizeof(struct dot));
    d->x = x;
    d->y = y;
    d->set = (bits1[y * stride + (x >> 5)] & (1 << (x & 31))) != 0;
    d->next = lastDraw;
    lastDraw = d;
}

static void undoDots() {
    /* Undo last completed pixel drawing sequence */
    struct dot *d = lastDraw;
    while (d != NULL) {
        if (d->set)
            bits1[d->y * stride + (d->x >> 5)] |= 1 << (d->x & 31);
        else
            bits1[d->y * stride + (d->x >> 5)] &= ~(1 << (d->x & 31));
        struct dot *n = d;
        d = d->next;
        free(n);
    }
    lastDraw = NULL;
}

- (void) undo {
    if (pbits != NULL) {
        /* Undo un-committed Paste */
        free(pbits);
        pbits = NULL;
    } else {
        struct dot *temp = lastDraw;
        lastDraw = undoableDraw;
        undoDots();
        undoableDraw = NULL;
        lastDraw = temp;
    }
    [self setNeedsDisplay];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    screenSize = self.bounds.size;
    srandom((unsigned int) time(NULL));

    NSString *sfn = [NSString stringWithFormat:@"%@/Documents/state.bin", NSHomeDirectory()];
    const char *t = [sfn UTF8String];
    stateFileName = (char *) malloc(strlen(t) + 1);
    strcpy(stateFileName, t);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int n = 0, b = 1, s = (int) [[UIScreen mainScreen] scale];
    while (b < s) {
        b <<= 1;
        n++;
    }
    scaleSlider.maximumValue = n + 3;

    int scale = (int) [defaults integerForKey:@"scale"];
    if (scale == 0)
        scale = n + 1;
    else if (scale > n + 3)
        scale = n + 3;
    else
        scale--;
    scaleSlider.value = scale;

    FILE *f = fopen(stateFileName, "rb");
    if (f != NULL) {
        uint32_t w, h;
        if (!read_w(f, &w) || !read_w(f, &h))
            goto done;
        uint32_t s = (w + 31) >> 5;
        size_t sz = s * h;
        bits1 = (uint32_t *) malloc(sz * 4 + 4);
        bits2 = (uint32_t *) malloc(sz * 4 + 4);
        if (bits1 == NULL || bits2 == NULL) {
            fail:
            free(bits1);
            free(bits2);
            bits1 = bits2 = NULL;
            goto done;
        }
        for (int i = 0; i < sz; i++)
            if (!read_w(f, bits1 + i))
                goto fail;
        width = w;
        height = h;
        stride = s;
        orientation = [UIApplication sharedApplication].statusBarOrientation;
        resized = false;
        offset_x = width / 2.0;
        offset_y = height / 2.0;
        repeats = PATIENCE;
        memset(history, 0, HISTORY * sizeof(unsigned int));
        done:
        fclose(f);
    }

    pixelScale = (1 << ((int) scaleSlider.value)) / [[UIScreen mainScreen] scale];
    if (resized)
        [self restart];
    else
        [self setNeedsDisplay];

    delay = (int) [defaults integerForKey:@"delay"];
    if (delay == 0)
        delay = 8;
    else
        delay--;
    [speedSlider setValue:delay];

    painting = [[NSUserDefaults standardUserDefaults] boolForKey:@"painting"];
    paused = [[NSUserDefaults standardUserDefaults] boolForKey:@"paused"];

    paintSwitch.on = painting;
    if (!painting)
        [self hideUI];

    /* Tap: toggle UI or finalize Paste */
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    recog.delegate = self;
    recog.cancelsTouchesInView = NO;
    [self addGestureRecognizer:recog];

    /* Pinch: zoom */
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    pinch.cancelsTouchesInView = NO;
    [self addGestureRecognizer:pinch];

    /* One finger pan: move pasted bitmap, or draw, or pan */
    oneFingerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    oneFingerPan.delegate = self;
    oneFingerPan.cancelsTouchesInView = NO;
    [self addGestureRecognizer:oneFingerPan];

    /* Two finger pan: pan */
    UIPanGestureRecognizer *twoFingerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
    twoFingerPan.minimumNumberOfTouches = 2;
    twoFingerPan.cancelsTouchesInView = NO;
    [self addGestureRecognizer:twoFingerPan];

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self performSelectorInBackground:@selector(worker) withObject:nil];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    if (self.bounds.size.width != screenSize.width || self.bounds.size.height != screenSize.height) {
        screenSize = self.bounds.size;
        resized = true;
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view != self)
        return NO;
    if (!painting)
        return YES;
    else
        return pbits != NULL || gestureRecognizer != oneFingerPan;
}

- (void) handleTap:(UITapGestureRecognizer *)recog {
    if (pbits != NULL) {
        /* Finish paste operation */
        for (int y = 0; y < pheight; y++)
            for (int x = 0; x < pwidth; x++)
                if ((pbits[y * pstride + (x >> 3)] >> (x & 7)) & 1) {
                    int xx = x + px;
                    int yy = y + py;
                    if (xx >= 0 && xx < width && yy >= 0 && yy < height)
                        bits1[yy * stride + (xx >> 5)] |= (1 << (xx & 31));
                }
        free(pbits);
        pbits = NULL;
        [self setNeedsDisplay];
        return;
    }
    /* Toggle UI */
    if (!painting)
        [self setUIVisibility:scaleSlider.isHidden];
}

- (void) setUIVisibility:(BOOL)visible {
    BOOL hidden = !visible;
    scaleSlider.hidden = hidden;
    speedSlider.hidden = hidden;
    stopButton.hidden = hidden;
    stepButton.hidden = hidden;
    restartButton.hidden = hidden;
    paintSwitch.hidden = hidden;
    scaleLabel.hidden = hidden;
    speedLabel.hidden = hidden;
    paintLabel.hidden = hidden;
    kopyButton.hidden = hidden;
    pasteButton.hidden = hidden;
    ui_hide_time = hidden ? 0 : time(NULL) + 15;
    [[UIApplication sharedApplication] setStatusBarHidden:hidden];
}

- (void) hideUI {
    [self setUIVisibility:NO];
}

- (void) pinOffset {
    float w2 = self.bounds.size.width / 2 / zoom / pixelScale;
    if (offset_x < w2)
        offset_x = w2;
    if (offset_x > width - w2)
        offset_x = width - w2;
    float h2 = self.bounds.size.height / 2 / zoom / pixelScale;
    if (offset_y < h2)
        offset_y = h2;
    if (offset_y > height - h2)
        offset_y = height - h2;
}

- (void) handlePinch:(UIPinchGestureRecognizer *)pinch {
    if (pinch.state == UIGestureRecognizerStateBegan) {
        undoDots();
        gesturing = true;
        [self setNeedsDisplay];
        zoom_orig = zoom;
    } else if (pinch.state == UIGestureRecognizerStateChanged) {
        zoom = zoom_orig * pinch.scale;
        if (zoom < 1)
            zoom = 1;
        else if (zoom > 32)
            zoom = 32;
        [self pinOffset];
        [self setNeedsDisplay];
    }
}

- (void) handlePan:(UIPanGestureRecognizer *)pan {
    [self handlePan2:pan twoFinger:NO];
}

- (void) handleTwoFingerPan:(UIPanGestureRecognizer *)pan {
    [self handlePan2:pan twoFinger:YES];
}

- (void) handlePan2:(UIPanGestureRecognizer *)pan twoFinger:(BOOL)twoFinger {
    bool movingP = pbits != NULL && !twoFinger;
    if (pan.state == UIGestureRecognizerStateBegan) {
        undoDots();
        gesturing = true;
        [self setNeedsDisplay];
        if (movingP) {
            px_orig = px;
            py_orig = py;
        } else {
            offset_x_orig = offset_x;
            offset_y_orig = offset_y;
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint p = [pan translationInView:self];
        if (movingP) {
            px = px_orig + p.x / pixelScale / zoom;
            py = py_orig + p.y / pixelScale / zoom;
        } else {
            offset_x = offset_x_orig - p.x / pixelScale / zoom;
            offset_y = offset_y_orig - p.y / pixelScale / zoom;
            [self pinOffset];
        }
        [self setNeedsDisplay];
    }
}

- (IBAction) stopPressed {
    paused = !paused;
    [[NSUserDefaults standardUserDefaults] setBool:paused forKey:@"paused"];
    ui_hide_time = time(NULL) + 15;
    [UIApplication sharedApplication].idleTimerDisabled = !paused;
}

- (IBAction) stepPressed {
    paused = true;
    [[NSUserDefaults standardUserDefaults] setBool:paused forKey:@"paused"];
    ui_hide_time = time(NULL) + 15;
    [self work];
    [self setNeedsDisplay];
}

- (IBAction) restartPressed {
    ui_hide_time = time(NULL) + 15;
    if (painting) {
        memset(bits1, 0, 4 * height * stride);
        [self setNeedsDisplay];
    } else if (paused) {
        [self restart];
    } else {
        repeats = 0;
    }
}

static int gcd(int a, int b) {
    if (a < b) {
        int t = a;
        a = b;
        b = t;
    }
    while (b != 0) {
        int t = b;
        b = a % b;
        a = t;
    }
    return a;
}

- (IBAction) copyPressed {
    int marg_l = INT_MAX, marg_r = 0, marg_t = INT_MAX, marg_b = 0;
    bool empty = true;
    for (int v = 0; v < height; v++) {
        for (int h = 0; h < width; h++) {
            if ((bits1[v * stride + (h >> 5)] >> (h & 31)) & 1) {
                empty = false;
                if (h < marg_l)
                    marg_l = h;
                if (h > marg_r)
                    marg_r = h;
                if (v < marg_t)
                    marg_t = v;
                if (v > marg_b)
                    marg_b = v;
            }
        }
    }

    if (marg_l > 0)
        marg_l--;
    marg_r = width - marg_r - 1;
    if (marg_r > 0)
        marg_r--;
    if (marg_t > 0)
        marg_t--;
    marg_b = height - marg_b - 1;
    if (marg_b > 0)
        marg_b--;
    int pwidth = width - marg_l - marg_r;
    int pheight = height - marg_t - marg_b;

    int dstride = ((pwidth << 1) + 2) & ~3;
    int dgap = dstride - 2 * pwidth;

    unsigned char *data = (unsigned char *) malloc(pheight * dstride * 2 + 4);
    unsigned char *dst = data;
    for (int v = 0; v < pheight; v++) {
        uint32_t *src = bits1 + (v + marg_t) * stride;
        for (int h = 0; h < pwidth; h++) {
            unsigned char k = ((src[(h + marg_l) >> 5] >> ((h + marg_l) & 31)) & 1) ? 255 : 0;
            *dst++ = k;
            *dst++ = k;
        }
        for (int i = 0; i < dgap; i++)
            *dst++ = 255;
        memcpy(dst, dst - dstride, dstride);
        dst += dstride;
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CFDataRef d = CFDataCreateWithBytesNoCopy(NULL, data, pheight * dstride * 2, kCFAllocatorMalloc);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(d);
    CGImageRef cgImg = CGImageCreate(pwidth * 2, pheight * 2, 8, 8, dstride, colorSpace, kCGImageAlphaNone, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *img = [UIImage imageWithCGImage:cgImg];
    [[UIPasteboard generalPasteboard] setImage:img];
    CGImageRelease(cgImg);
    CGDataProviderRelease(provider);
    CFRelease(d);
    CGColorSpaceRelease(colorSpace);
}

- (IBAction) pastePressed {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    UIImage *image = [pb image];
    if (image == nil)
        return;

    CGImageRef imageRef = [image CGImage];
    int iwidth = (int) CGImageGetWidth(imageRef);
    int iheight = (int) CGImageGetHeight(imageRef);
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    NSUInteger istride = (iwidth + 3) & ~3;
    unsigned char *rawData = (unsigned char *) malloc(iheight * istride + 4);
    CGContextRef context = CGBitmapContextCreate(rawData, iwidth, iheight,
                    8, istride, gray, kCGImageAlphaNone);
    CGColorSpaceRelease(gray);

    bool reverse = false;
    again:
    memset(rawData, reverse ? 0 : 255, iheight * istride);
    CGContextDrawImage(context, CGRectMake(0, 0, iwidth, iheight), imageRef);

    /* Now we have an 8-bit grayscale pixmap. We'll turn this into monochrome
     * using simple thresholding, but before we do that, first we'll try to
     * find out if the image contains enlarged pixels, and if it does, we'll
     * reduce it as well.
     */

    int b = 0, w = 0;
    int blocksize = -1;
    int marg_l = iwidth, marg_r = -1;
    int marg_t = iheight, marg_b = -1;

    /* First, find the dominant color. */

    for (int y = 0; y < iheight; y++)
        for (int x = 0; x < iwidth; x++)
            if ((rawData[y * istride + x] < 128) ^ reverse)
                b++;
            else
                w++;
    if (w == 0 || b == 0)
        goto scan_done;
    if (w < b) {
        reverse = true;
        goto again;
    }

    /* Next, find the margins. */

    for (int y = 0; y < iheight; y++) {
        for (int x = 0; x < iwidth; x++)
            if ((rawData[y * istride + x] < 128) ^ reverse) {
                if (x < marg_l)
                    marg_l = x;
                break;
            }
        for (int x = iwidth - 1; x >= 0; x--)
            if ((rawData[y * istride + x] < 128) ^ reverse) {
                if (x > marg_r)
                    marg_r = x;
                break;
            }
    }
    marg_r++;
    for (int x = 0; x < iwidth; x++) {
        for (int y = 0; y < iheight; y++)
            if ((rawData[y * istride + x] < 128) ^ reverse) {
                if (y < marg_t)
                    marg_t = y;
                break;
            }
        for (int y = iheight - 1; y >= 0; y--)
            if ((rawData[y * istride + x] < 128) ^ reverse) {
                if (y > marg_b)
                    marg_b = y;
                break;
            }
    }
    marg_b++;

    /* Lastly, find the scale. */

    for (int y = marg_t; y <= marg_b; y++) {
        bool lc = false;
        int len = 0;
        for (int x = marg_l; x <= marg_r; x++) {
            bool c = x == marg_r ? false : (rawData[y * istride + x] < 128) ^ reverse;
            if (c == lc) {
                len++;
            } else {
                if (len > 0)
                    if (blocksize == -1)
                        blocksize = len;
                    else
                        blocksize = gcd(blocksize, len);
                lc = c;
                len = 1;
            }
        }
    }
    for (int x = marg_l; x <= marg_r; x++) {
        bool lc = false;
        int len = 0;
        for (int y = marg_t; y <= marg_b; y++) {
            bool c = y == marg_b ? false : (rawData[y * istride + x] < 128) ^ reverse;
            if (c == lc) {
                len++;
            } else {
                if (len > 0)
                    if (blocksize == -1)
                        blocksize = len;
                    else
                        blocksize = gcd(blocksize, len);
                lc = c;
                len = 1;
            }
        }
    }

    scan_done:

    CGContextRelease(context);

    if (blocksize == -1) {
        // Image is all white; no action
        free(rawData);
        return;
    }

    free(pbits);
    pwidth = (marg_r - marg_l) / blocksize;
    pheight = (marg_b - marg_t) / blocksize;
    pstride = (pwidth + 7) >> 3;
    pbits = (unsigned char *) malloc(pstride * pheight + 4);
    memset(pbits, 0, pstride * pheight);

    for (int y = 0; y < pheight; y++) {
        int yy = y * blocksize + marg_t;
        for (int x = 0; x < pwidth; x++) {
            int xx = x * blocksize + marg_l;
            unsigned char c = rawData[yy * istride + xx];
            if ((c < 128) ^ reverse)
                pbits[y * pstride + (x >> 3)] |= 1 << (x & 7);
        }
    }

    free(rawData);

    px = (width - pwidth) / 2;
    py = (height - pheight) / 2;
    [self setNeedsDisplay];
}

static int paintMode;

- (void) handleTouchAt:(NSSet<UITouch *> *)touches first:(BOOL)first {
    UITouch *touch = (UITouch *) [touches anyObject];
    CGPoint p = [touch locationInView:self];
    int h = (int) ((p.x - self.bounds.size.width / 2) / zoom / pixelScale + offset_x);
    int v = (int) ((p.y - self.bounds.size.height / 2) / zoom / pixelScale + offset_y);
    if (h < 0 || h >= width || v < 0 || v >= height) {
        if (first)
            paintMode = -1;
        return;
    }
    rememberDot(h, v);
    if (first)
        paintMode = !((bits1[v * stride + (h >> 5)] >> (h & 31)) & 1);
    if (paintMode)
        bits1[v * stride + (h >> 5)] |= 1 << (h & 31);
    else
        bits1[v * stride + (h >> 5)] &= ~(1 << (h & 31));
    [self setNeedsDisplay];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (painting && pbits == NULL && !gesturing)
        [self handleTouchAt:touches first:YES];
    else
        [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (painting && pbits == NULL && !gesturing)
        [self handleTouchAt:touches first:NO];
    else
        [super touchesBegan:touches withEvent:event];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    while (undoableDraw != NULL) {
        struct dot *d = undoableDraw->next;
        free(undoableDraw);
        undoableDraw = d;
    }
    undoableDraw = lastDraw;
    lastDraw = NULL;
    gesturing = false;
}

- (void) drawRect:(CGRect)rect {
    int x1 = floor(-self.bounds.size.width / 2 / zoom / pixelScale + offset_x);
    if (x1 < 0)
        x1 = 0;
    int x2 = ceil(self.bounds.size.width / 2 / zoom / pixelScale + offset_x);
    if (x2 > width)
        x2 = width;
    int y1 = floor(-self.bounds.size.height / 2 / zoom / pixelScale + offset_y);
    if (y1 < 0)
        y1 = 0;
    int y2 = ceil(self.bounds.size.height / 2 / zoom / pixelScale + offset_y);
    if (y2 > height)
        y2 = height;

    bool dark = false;
    if (@available(iOS 12.0, *)) {
        if (UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
            dark = true;
    }

    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(myContext, self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGContextScaleCTM(myContext, zoom * pixelScale, zoom * pixelScale);
    CGContextTranslateCTM(myContext, -offset_x, -offset_y);
    CGContextSetRGBFillColor(myContext, !dark, !dark, !dark, 1.0);
    CGContextFillRect(myContext, [self bounds]);
    CGContextSetRGBFillColor(myContext, dark, dark, dark, 1.0);
    CGRect r;
    r.size.width = r.size.height = 1;

    uint32_t *p = bits1 + y1 * stride + (x1 >> 5);
    int x1w = x1 >> 5;
    int x2w = x2 >> 5;
    int gap = stride - x2w + x1w - 2;
    for (int v = y1; v < y2; v++) {
        uint32_t w = *p++;
        int hh = x1 & 31;
        w >>= hh;
        for (int h = x1w; h <= x2w; h++) {
            for (; hh < 32; hh++) {
                if (w & 1) {
                    r.origin.x = (h << 5) | hh;
                    r.origin.y = v;
                    CGContextFillRect(myContext, r);
                }
                w >>= 1;
            }
            w = *p++;
            hh = 0;
        }
        p += gap;
    }

    if (pbits != NULL) {
        CGContextSetRGBFillColor(myContext, 1.0, 0.0, 0.0, 1.0);
        for (int v = 0; v < pheight; v++)
            for (int h = 0; h < pwidth; h++)
                if ((pbits[v * pstride + (h >> 3)] >> (h & 7)) & 1) {
                    r.origin.x = h + px;
                    r.origin.y = v + py;
                    CGContextFillRect(myContext, r);
                }
    }

    if (painting && zoom * pixelScale >= 4) {
        CGMutablePathRef path = CGPathCreateMutable();
        for (int v = y1; v <= y2; v++) {
            CGPathMoveToPoint(path, NULL, x1, v);
            CGPathAddLineToPoint(path, NULL, x2, v);
        }
        for (int h = x1; h <= x2; h++) {
            CGPathMoveToPoint(path, NULL, h, y1);
            CGPathAddLineToPoint(path, NULL, h, y2);
        }
        CGPathCloseSubpath(path);

        CGContextSetLineWidth(myContext, 1.0 / zoom / pixelScale);
        CGContextSetRGBFillColor(myContext, !dark, !dark, !dark, 1.0);
        CGContextAddPath(myContext, path);
        CGContextDrawPath(myContext, kCGPathStroke);
        CGContextSetRGBStrokeColor(myContext, dark, dark, dark, 1.0);
        CGFloat dash[] = { 1.0 / zoom / pixelScale, 1.0 / zoom / pixelScale };
        CGContextSetLineDash(myContext, 0, dash, 2);
        CGContextAddPath(myContext, path);
        CGContextDrawPath(myContext, kCGPathStroke);
        CGPathRelease(path);
    }
}

- (void) work {
    int index = 0;
    int aboveindex = -stride;
    int belowindex = stride;
    uint32_t rightedgemask = 0xffffffff >> (31 - (width - 1 & 31));
    int crc = 0;

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

}

- (void) worker {
    moar:;
    if (ui_hide_time != 0 && time(NULL) > ui_hide_time && !painting) {
        ui_hide_time = 0;
        [self performSelectorOnMainThread:@selector(hideUI) withObject:NULL waitUntilDone:NO];
    }

    if (repeats == 0 || resized) {
        [self performSelectorOnMainThread:@selector(restart) withObject:nil waitUntilDone:YES];
        goto done;
    }

    if (paused)
        goto no_paint;
    [self work];

    done:
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    no_paint:;
    int64_t d = 1000000000 * pow(2, -delay);
    struct timespec ts = { d / 1000000000, d % 1000000000 };
    nanosleep(&ts, NULL);
    goto moar;
}

+ (void) enterBackground {
    FILE *f = fopen(stateFileName, "wb");
    if (f == NULL)
        return;
    write_w(f, width);
    write_w(f, height);
    size_t sz = height * stride;
    for (int i = 0; i < sz; i++)
        write_w(f, bits1[i]);
    fclose(f);
}

@end
