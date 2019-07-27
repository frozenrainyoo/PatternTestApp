//
//  MyDrawView.m
//  PatternTestApp
//
//  Created by 유동우 on 27/07/2019.
//  Copyright © 2019 유동우. All rights reserved.
//

#import "MyDrawView.h"


static CGRect createFlipRect(CGFloat x, CGFloat y, CGFloat w, CGFloat h, CGFloat parentHeight) {
    return CGRectMake(x, parentHeight - h - y, w, h);
}

static void drawImage(CGContextRef context, CGRect rect) {
    CGContextSaveGState(context);

    UIImage* image = [UIImage imageNamed:@"test.png"];
    CGImageRef cgImage = image.CGImage;
    CGFloat imageWidth = CGImageGetWidth(cgImage);
    CGFloat imageHeight = CGImageGetHeight(cgImage);

    CGRect destRect = createFlipRect(20, 30, imageWidth, imageHeight, rect.size.height);
    CGContextDrawImage(context, destRect, cgImage);

    CGContextRestoreGState(context);
}

typedef struct {
    CGImageRef image;
} PatternInfo;

static void drawPattern(void *info, CGContextRef context)
{
    PatternInfo *pattern = (PatternInfo *)info;
    CGFloat width = CGImageGetWidth(pattern->image);
    CGFloat height = CGImageGetHeight(pattern->image);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), pattern->image);
}

static void releasePattern(void *info)
{
    PatternInfo *pattern = (PatternInfo *)info;
    delete pattern;
}

static void drawImageInRectUsingPattern(CGContextRef context, CGAffineTransform invertCtm, CGRect parentRect) {
    CGContextSaveGState(context);

    // load Bundle Image (96 x 96)
    UIImage* image = [UIImage imageNamed:@"test.png"];
    CGImageRef cgImage = image.CGImage;
    CGFloat imageWidth = CGImageGetWidth(cgImage);
    CGFloat imageHeight = CGImageGetHeight(cgImage);

    CGRect destRect = createFlipRect(20, 30, 200, 200, parentRect.size.height);

    // Using CGPattern, clip to rect.
    CGRect clipRect = CGRectMake(32, 32, 32, 32);
    CGAffineTransform inCtm = CGAffineTransformIdentity;
    inCtm = CGAffineTransformScale(inCtm, 1, 1);
    inCtm = CGAffineTransformInvert(inCtm);

    if (1) {
        // Apply xform
        clipRect = CGRectMake(16, 16, 16, 16);
        inCtm = CGAffineTransformIdentity;
        inCtm = CGAffineTransformScale(inCtm, 2, 2);
        //  inCtm = CGAffineTransformRotate(inCtm, 90);
        inCtm = CGAffineTransformInvert(inCtm);
    }
    
    CGPatternRef pattern;
    CGColorSpaceRef baseSpace;
    CGColorSpaceRef patternSpace;
    static CGFloat color[4] = { 0, 0, 0, 1 };
    static CGPatternCallbacks callbacks = {0, &drawPattern, &releasePattern};

    PatternInfo* patternInfo = new PatternInfo;
    patternInfo->image = cgImage;
    baseSpace = CGColorSpaceCreateDeviceRGB();
    patternSpace = CGColorSpaceCreatePattern(baseSpace);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);
    CGColorSpaceRelease(baseSpace);

    // Pattern space is separate from user space
    // https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_patterns/dq_patterns.html#//apple_ref/doc/uid/TP30001066-CH206-TPXREF101
    CGAffineTransform ctm = CGContextGetCTM(context);
    ctm = CGAffineTransformConcat(ctm, invertCtm);
    ctm = CGAffineTransformTranslate(ctm, destRect.origin.x, destRect.origin.y);
    ctm = CGAffineTransformScale(ctm, (destRect.size.width / clipRect.size.width),
                                 (destRect.size.height / clipRect.size.height));
    ctm = CGAffineTransformTranslate(ctm, -clipRect.origin.x, clipRect.origin.y + clipRect.size.height);
    ctm = CGAffineTransformConcat(inCtm, ctm);

    pattern = CGPatternCreate(patternInfo, CGRectMake(0, 0, imageWidth, imageHeight),
                              ctm, imageWidth, imageHeight,
                              kCGPatternTilingConstantSpacing,
                              false, &callbacks);
    CGContextSetFillPattern(context, pattern, color);
    CGPatternRelease(pattern);
    CGContextFillRect(context, destRect);

    CGContextRestoreGState(context);
}

static void drawBasicPattern(CGContextRef context, CGAffineTransform invertCtm, CGRect parentRect) {
    CGContextSaveGState(context);
    
    // load Bundle Image (96 x 96)
    UIImage* image = [UIImage imageNamed:@"test.png"];
    CGImageRef cgImage = image.CGImage;
    CGFloat imageWidth = CGImageGetWidth(cgImage);
    CGFloat imageHeight = CGImageGetHeight(cgImage);

    CGRect destRect = createFlipRect(20, 30, 200, 200, parentRect.size.height);

    CGPatternRef pattern;
    CGColorSpaceRef baseSpace;
    CGColorSpaceRef patternSpace;
    static CGFloat color[4] = { 0, 0, 0, 1 };
    static CGPatternCallbacks callbacks = {0, &drawPattern, &releasePattern};

    PatternInfo* patternInfo = new PatternInfo;
    patternInfo->image = cgImage;
    baseSpace = CGColorSpaceCreateDeviceRGB();
    patternSpace = CGColorSpaceCreatePattern(baseSpace);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);
    CGColorSpaceRelease(baseSpace);

    CGAffineTransform ctm = CGContextGetCTM(context);
    ctm = CGAffineTransformConcat(ctm, invertCtm);
    ctm = CGAffineTransformTranslate(ctm, destRect.origin.x, destRect.origin.y);

    pattern = CGPatternCreate(patternInfo, CGRectMake(0, 0, imageWidth, imageHeight),
                              ctm, imageWidth, imageHeight,
                              kCGPatternTilingConstantSpacing,
                              false, &callbacks);
    CGContextSetFillPattern(context, pattern, color);
    CGPatternRelease(pattern);
    CGContextFillRect(context, destRect);

    CGContextRestoreGState(context);
}

@implementation MyDrawView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGAffineTransform ctm = CGContextGetCTM(context);
    CGAffineTransform invertCtm = CGAffineTransformInvert(ctm);

    CGContextSaveGState(context);

    // flip
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1, -1);

    CGContextFillRect(context, CGRectMake(0, 0, 20, rect.size.height));
    CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, 30));
    CGContextFillRect(context, CGRectMake(0, rect.size.height - 30, rect.size.width, 30));

    drawImage(context, rect);

    CGContextTranslateCTM(context, 96, 0);

    drawImageInRectUsingPattern(context, invertCtm, rect);

    CGContextTranslateCTM(context, -96, -200);

    drawBasicPattern(context, invertCtm, rect);

    CGContextRestoreGState(context);
}

@end
