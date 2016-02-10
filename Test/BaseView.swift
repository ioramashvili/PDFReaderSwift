import UIKit

class BaseView: UIView {
    var currentPage = 1
    var pdfPage: CGPDFPageRef!
    var pageRect: CGRect!
    var pageLinks: NSMutableArray!
    
//    CGPDFPageRef pdfPage;
//    CGRect pageRenderRect;
//    NSMutableArray *pageLinks;
    
    override func drawRect(rect: CGRect) {
        if currentPage != 0 {
            let ctx = UIGraphicsGetCurrentContext()
            let page = PDFReaderHelper.sharedInstance().getPage(atIndex: currentPage)
            pdfPage = page
//            // PDF might be transparent, assume white paper
//            UIColor.whiteColor().set()
//            CGContextFillRect(ctx, rect);
//            
//            // Flip coordinates
//            CGContextGetCTM(ctx);
//            CGContextScaleCTM(ctx, 1, -1);
//            CGContextTranslateCTM(ctx, 0, -rect.size.height);
//
//            let t = TiledPDFView()
//            let arr = t.loadPageLinks(page)
//            
//            // get the rectangle of the cropped inside
//            let mediaRect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)
//            let wScale = rect.size.width / mediaRect.size.width
//            let hScale = rect.size.height / mediaRect.size.height
//            let minScale = min(wScale, hScale)
//            
////            let cropBoxRect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)
////            let mediaBoxRect = CGPDFPageGetBoxRect(page, CGPDFBox.MediaBox)
////            let effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect)
//
//            CGContextScaleCTM(ctx, minScale, minScale)
//            CGContextTranslateCTM(ctx, -mediaRect.origin.x, -mediaRect.origin.y)
//            // draw it
//            CGContextDrawPDFPage(ctx, page)
            
            pageRect = PDFPageRenderer.renderPage(page, inContext: ctx, inRectangle: self.bounds)
            let yellowComponents: [CGFloat] = [1, 1, 0, 1]
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextSetStrokeColorSpace(ctx, rgbColorSpace);
            let yellow = CGColorCreate(rgbColorSpace, yellowComponents);
            CGContextSetStrokeColorWithColor(ctx, yellow);
            
            let t = TiledPDFView()
            pageLinks = t.loadPageLinks(page)
            if pageLinks != nil {
                for var i = 0; i < pageLinks.count; i++ {
                    let linkAnnotation = pageLinks.objectAtIndex(i)
                    
                    let pt1 = PDFPageRenderer.convertPDFPointToViewPoint(linkAnnotation.pdfRectangle.origin, pdfPage: page, pageRenderRect: pageRect)
                    var pt2 = CGPointMake(
                        linkAnnotation.pdfRectangle.origin.x + linkAnnotation.pdfRectangle.size.width,
                        linkAnnotation.pdfRectangle.origin.y + linkAnnotation.pdfRectangle.size.height);
                    
                    pt2 = PDFPageRenderer.convertPDFPointToViewPoint(pt2, pdfPage: page, pageRenderRect: pageRect)
                    
                    let linkRectangle = CGRectMake(pt1.x, pt1.y, pt2.x - pt1.x, pt2.y - pt1.y);
                    CGContextAddRect(ctx, linkRectangle);
                    
                    CGContextStrokePath(ctx);
                }
            }
            
            let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleUserTap:")
            singleFingerTap.numberOfTapsRequired = 1;
            self.addGestureRecognizer(singleFingerTap)
        }
    }
    
    func handleUserTap(sender: UIGestureRecognizer) {
        let tapPosition = sender.locationInView(sender.view!.superview)
        print(tapPosition)
        
        let pdfPosition = PDFPageRenderer.convertViewPointToPDFPoint(tapPosition, pdfPage: pdfPage, pageRenderRect: pageRect)
        if pageLinks != nil {
            for var i = pageLinks.count - 1; i >= 0; i-- {
                let link: PDFLinkAnnotation = pageLinks.objectAtIndex(i) as! PDFLinkAnnotation
                if hitTest(pdfPosition) {
                    let document = CGPDFPageGetDocument(pdfPage)
                    let linkTarget = link.getLinkTarget(document)
                    
                    if linkTarget != nil {
                        if linkTarget.isKindOfClass(NSNumber) {
                            print("No idea")
                        }
                        else if linkTarget.isKindOfClass(NSString) {
                            let linkUri = linkTarget as! String
                            let url = NSURL(string: linkUri)
                            print(url!)
                            UIApplication.sharedApplication().openURL(url!)
//                            [[UIApplication sharedApplication] openURL: url];
                        }
                    }
                }
                
            }
        }
    }
    
    func hitTest(point: CGPoint) -> Bool {
        if ((pageRect.origin.x <= point.x) &&
            (pageRect.origin.y <= point.y) &&
            (point.x <= pageRect.origin.x + pageRect.size.width) &&
            (point.y <= pageRect.origin.y + pageRect.size.height)) {
                return true;
        } else {
            return false;
        }
    }
}
