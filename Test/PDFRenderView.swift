import UIKit

class PDFRenderView: UIView {
    var currentPage: Int = 1
    var pdfPage: CGPDFPageRef!
    var pageRect: CGRect!
    var pageLinks: NSMutableArray!
    
    override func drawRect(rect: CGRect) {
        if currentPage != 0 {
            let ctx = UIGraphicsGetCurrentContext()
            let page = PDFReaderHelper.sharedInstance().getPage(atIndex: currentPage)
            pdfPage = page
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
                    
                    print(linkAnnotation.pdfRectangle)
                    print(linkRectangle)
                    print("width \(linkAnnotation.pdfRectangle.size.width)")
                    print("height \(linkAnnotation.pdfRectangle.size.height)")
                    
                    CGContextStrokePath(ctx);
                }
            }
            
            let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleUserTap:")
            singleFingerTap.numberOfTapsRequired = 1;
            self.addGestureRecognizer(singleFingerTap)
        }
    }
    
    func handleUserTap(sender: UIGestureRecognizer) {
        NSNotificationCenter.defaultCenter().postNotificationName("tapedOnPDFView", object: nil)
//        let tapPosition = sender.locationInView(sender.view!.superview)
        let tapPosition = sender.locationInView(self)
        let pdfPosition = PDFPageRenderer.convertViewPointToPDFPoint(tapPosition, pdfPage: pdfPage, pageRenderRect: pageRect)
        
        print("scrollview bounds: \(self.superview!.bounds)")
        print("pdf MediaBox: \(CGPDFPageGetBoxRect(pdfPage, CGPDFBox.CropBox))")
        print("self bounds: \(self.bounds): pageRect: \(pageRect)")
        print("tapposition x-y: \(tapPosition)")
        print("pdf position x-y: \(pdfPosition)")
        
        if pageLinks != nil {
            for var i = pageLinks.count - 1; i >= 0; i-- {
                let link: PDFLinkAnnotation = pageLinks.objectAtIndex(i) as! PDFLinkAnnotation
                
                if link.hitTest(pdfPosition) {
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
                            //UIApplication.sharedApplication().openURL(url!)
                            
                            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let mapViewControllerObejct = storyboard.instantiateViewControllerWithIdentifier("ImageSliderRoot") as! ImageSliderRootViewController
                            self.window?.rootViewController!.presentViewController(mapViewControllerObejct, animated: true, completion: nil)
                        }
                    }
                }
                
            }
        }
    }
}
