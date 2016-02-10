//
//  PDFPageRenderer.h
//
//  Created by Sorin Nistor on 3/21/11.
//  Copyright 2011 iPDFdev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface PDFPageRenderer : NSObject {

}

+ (CGSize) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context;
+ (CGSize) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint: (CGPoint) point;
+ (CGSize) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint: (CGPoint) point withZoom: (float) zoom;
+ (CGRect) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context inRectangle: (CGRect) rectangle;

+ (CGPoint)convertViewPointToPDFPoint:(CGPoint)viewPoint pdfPage: (CGPDFPageRef) page pageRenderRect: (CGRect) pageRenderRect;
+ (CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint pdfPage: (CGPDFPageRef) page pageRenderRect: (CGRect) pageRenderRect;
@end
