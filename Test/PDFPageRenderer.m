#import "PDFPageRenderer.h"

@implementation PDFPageRenderer

+ (CGSize) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context{
	return [PDFPageRenderer renderPage:page inContext:context atPoint:CGPointMake(0, 0)];
}
	 
+ (CGSize) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint:(CGPoint) point{
	return [PDFPageRenderer renderPage:page inContext:context atPoint:point withZoom:100];
}

+ (CGSize) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint: (CGPoint) point withZoom: (float) zoom{
	CGSize renderingSize = CGSizeMake(0, 0);
    
	CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	int rotate = CGPDFPageGetRotationAngle(page);
	
	CGContextSaveGState(context);
	
	// Setup the coordinate system.
	// Top left corner of the displayed page must be located at the point specified by the 'point' parameter.
	CGContextTranslateCTM(context, point.x, point.y);
	
	// Scale the page to desired zoom level.
	CGContextScaleCTM(context, zoom / 100, zoom / 100);
	
	// The coordinate system must be set to match the PDF coordinate system.
	switch (rotate) {
		case 0:
            renderingSize.width = cropBox.size.width * zoom / 100;
            renderingSize.height = cropBox.size.height * zoom / 100;
			CGContextTranslateCTM(context, 0, cropBox.size.height);
			CGContextScaleCTM(context, 1, -1);
			break;
		case 90:
            renderingSize.width = cropBox.size.height * zoom / 100;
            renderingSize.height = cropBox.size.width * zoom / 100;
			CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, -M_PI / 2);
			break;
		case 180:
		case -180:
            renderingSize.width = cropBox.size.width * zoom / 100;
            renderingSize.height = cropBox.size.height * zoom / 100;
			CGContextScaleCTM(context, 1, -1);
			CGContextTranslateCTM(context, cropBox.size.width, 0);
			CGContextRotateCTM(context, M_PI);
			break;
		case 270:
		case -90:
            renderingSize.width = cropBox.size.height * zoom / 100;
            renderingSize.height = cropBox.size.width * zoom / 100;
			CGContextTranslateCTM(context, cropBox.size.height, cropBox.size.width);
			CGContextRotateCTM(context, M_PI / 2);
			CGContextScaleCTM(context, -1, 1);
			break;
	}
	
	// The CropBox defines the page visible area, clip everything outside it.
	CGRect clipRect = CGRectMake(0, 0, cropBox.size.width, cropBox.size.height);
	CGContextAddRect(context, clipRect);
	CGContextClip(context);
	
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(context, clipRect);
	
	CGContextTranslateCTM(context, -cropBox.origin.x, -cropBox.origin.y);
	
	CGContextDrawPDFPage(context, page);
	
	CGContextRestoreGState(context);
    
    return renderingSize;
}

+ (CGRect) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context inRectangle: (CGRect) displayRectangle {
    CGRect renderingRectangle = CGRectMake(0, 0, 0, 0);
    if ((displayRectangle.size.width == 0) || (displayRectangle.size.height == 0)) {
        return renderingRectangle;
    }
    
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	int pageRotation = CGPDFPageGetRotationAngle(page);
	
	CGSize pageVisibleSize = CGSizeMake(cropBox.size.width, cropBox.size.height);
	if ((pageRotation == 90) || (pageRotation == 270) ||(pageRotation == -90)) {
		pageVisibleSize = CGSizeMake(cropBox.size.height, cropBox.size.width);
	}
    
    float scaleX = displayRectangle.size.width / pageVisibleSize.width;
    float scaleY = displayRectangle.size.height / pageVisibleSize.height;
    float scale = scaleX < scaleY ? scaleX : scaleY;
    
    // Offset relative to top left corner of rectangle where the page will be displayed
    float offsetX = 0;
    float offsetY = 0;
    
    float rectangleAspectRatio = displayRectangle.size.width / displayRectangle.size.height;
    float pageAspectRatio = pageVisibleSize.width / pageVisibleSize.height;
    
    if (pageAspectRatio < rectangleAspectRatio) {
        // The page is narrower than the rectangle, we place it at center on the horizontal
        offsetX = (displayRectangle.size.width - pageVisibleSize.width * scale) / 2;
    }
    else { 
        // The page is wider than the rectangle, we place it at center on the vertical
        offsetY = (displayRectangle.size.height - pageVisibleSize.height * scale) / 2;
    }
    
    renderingRectangle.origin = CGPointMake(displayRectangle.origin.x + offsetX, displayRectangle.origin.y + offsetY);
    
    renderingRectangle.size = [PDFPageRenderer renderPage:page 
                                                inContext:context 
                                                  atPoint:renderingRectangle.origin 
                                                 withZoom:scale * 100];
    
    return renderingRectangle;
}


// converting points page-view
+ (CGPoint)convertViewPointToPDFPoint:(CGPoint)viewPoint pdfPage: (CGPDFPageRef) page pageRenderRect: (CGRect) pageRenderRect {
    CGPoint pdfPoint = CGPointMake(0, 0);
    
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    
    int rotation = CGPDFPageGetRotationAngle(page);
//    int rotation = 90;
    switch (rotation) {
        case 90:
        case -270:
            pdfPoint.x = cropBox.size.width * (viewPoint.y - pageRenderRect.origin.y) / pageRenderRect.size.height;
            pdfPoint.y = cropBox.size.height * (viewPoint.x - pageRenderRect.origin.x) / pageRenderRect.size.width;
            break;
        case 180:
        case -180:
            pdfPoint.x = cropBox.size.width * (pageRenderRect.size.width - (viewPoint.x - pageRenderRect.origin.x)) / pageRenderRect.size.width;
            pdfPoint.y = cropBox.size.height * (viewPoint.y - pageRenderRect.origin.y) / pageRenderRect.size.height;
            break;
        case -90:
        case 270:
            pdfPoint.x = cropBox.size.width * (pageRenderRect.size.height - (viewPoint.y - pageRenderRect.origin.y)) / pageRenderRect.size.height;
            pdfPoint.y = cropBox.size.height * (pageRenderRect.size.width - (viewPoint.x - pageRenderRect.origin.x)) / pageRenderRect.size.width;
            break;
        case 0:
        default:
            pdfPoint.x = cropBox.size.width * (viewPoint.x - pageRenderRect.origin.x) / pageRenderRect.size.width;
            pdfPoint.y = cropBox.size.height * (pageRenderRect.size.height - (viewPoint.y - pageRenderRect.origin.y)) / pageRenderRect.size.height;
            break;
    }
    
    pdfPoint.x = (pdfPoint.x + cropBox.origin.x) * 2;
    pdfPoint.y = pdfPoint.y + cropBox.origin.y;
    
    return pdfPoint;
}

+ (CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint pdfPage: (CGPDFPageRef) page pageRenderRect: (CGRect) pageRenderRect{
    CGPoint viewPoint = CGPointMake(0, 0);
    
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    
    int rotation = CGPDFPageGetRotationAngle(page);
    
    switch (rotation) {
        case 90:
        case -270:
            viewPoint.x = pageRenderRect.size.width * (pdfPoint.y - cropBox.origin.y) / cropBox.size.height;
            viewPoint.y = pageRenderRect.size.height * (pdfPoint.x - cropBox.origin.x) / cropBox.size.width;
            break;
        case 180:
        case -180:
            viewPoint.x = pageRenderRect.size.width * (cropBox.size.width - (pdfPoint.x - cropBox.origin.x)) / cropBox.size.width;
            viewPoint.y = pageRenderRect.size.height * (pdfPoint.y - cropBox.origin.y) / cropBox.size.height;
            break;
        case -90:
        case 270:
            viewPoint.x = pageRenderRect.size.width * (cropBox.size.height - (pdfPoint.y - cropBox.origin.y)) / cropBox.size.height;
            viewPoint.y = pageRenderRect.size.height * (cropBox.size.width - (pdfPoint.x - cropBox.origin.x)) / cropBox.size.width;
            break;
        case 0:
        default:
            viewPoint.x = pageRenderRect.size.width * (pdfPoint.x - cropBox.origin.x) / cropBox.size.width;
            viewPoint.y = pageRenderRect.size.height * (cropBox.size.height - (pdfPoint.y - cropBox.origin.y)) / cropBox.size.height;
            break;
    }
    
    viewPoint.x = viewPoint.x + pageRenderRect.origin.x;
    viewPoint.y = viewPoint.y + pageRenderRect.origin.y;
    
    return viewPoint;
}

@end
