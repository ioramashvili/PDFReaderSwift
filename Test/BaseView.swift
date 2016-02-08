import UIKit

class BaseView: UIView {
    var currentPage = 1
    override func drawRect(rect: CGRect) {
        if currentPage != 0 {
            let ctx = UIGraphicsGetCurrentContext()
            // PDF might be transparent, assume white paper
            UIColor.whiteColor().set()
            CGContextFillRect(ctx, rect);
            
            // Flip coordinates
            CGContextGetCTM(ctx);
            CGContextScaleCTM(ctx, 1, -1);
            CGContextTranslateCTM(ctx, 0, -rect.size.height);
            
            let page = PDFReaderHelper.sharedInstance().getPage(atIndex: currentPage)
            
            // get the rectangle of the cropped inside
            let mediaRect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)
            let wScale = rect.size.width / mediaRect.size.width
            let hScale = rect.size.height / mediaRect.size.height
            let minScale = min(wScale, hScale)
            
            let cropBoxRect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)
            let mediaBoxRect = CGPDFPageGetBoxRect(page, CGPDFBox.MediaBox)
            let effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect)
            print(cropBoxRect)
            print(mediaBoxRect)
            print(effectiveRect)
//            CGContextScaleCTM(ctx, rect.size.width / mediaRect.size.width,
//                rect.size.height / mediaRect.size.height);
            CGContextScaleCTM(ctx, minScale, minScale)
            CGContextTranslateCTM(ctx, -mediaRect.origin.x, -mediaRect.origin.y)
            // draw it
            CGContextDrawPDFPage(ctx, page)
        }
    }
}
