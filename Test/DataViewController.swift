import UIKit

class DataViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var testView: BaseView!
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testView = BaseView(frame: CGRect(x: 0, y: 0, width: 651.96799999999996, height: 841.88999999999999))
//        testView = BaseView(frame: self.view.bounds)
        testView.currentPage = currentIndex + 1
        testView.setNeedsDisplay()
        
//        testView.backgroundColor = UIColor.greenColor()
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = testView.bounds.size
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        scrollView.addSubview(testView)
        view.addSubview(scrollView)
        
        setZoomScale()
        scrollViewDidZoom(scrollView)
        setupGestureRecognizer()
        
//        let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleUserTap:")
//        singleFingerTap.numberOfTapsRequired = 1;
//        self.view.addGestureRecognizer(singleFingerTap)
    }
    
    func handleUserTap(sender: UIGestureRecognizer) {
        print("##############################")
//        let tapPosition = sender.locationInView(sender.view!.superview)
//        print("ScrollView: \(scrollView.bounds)")
//        print("PDFView: \(testView.bounds)")
//        print(tapPosition)
        
//        let tapPosition = sender.locationInView(sender.view!.superview)
//        print(tapPosition)
//        
//        let pdfPosition = PDFPageRenderer.convertViewPointToPDFPoint(tapPosition, pdfPage: testView.pdfPage, pageRenderRect: testView.pageRect)
//        if testView.pageLinks != nil {
//            for var i = testView.pageLinks.count - 1; i >= 0; i-- {
//                let link: PDFLinkAnnotation = testView.pageLinks.objectAtIndex(i) as! PDFLinkAnnotation
//                if testView.hitTest(pdfPosition) {
//                    let document = CGPDFPageGetDocument(testView.pdfPage)
//                    let linkTarget = link.getLinkTarget(document)
//                    
//                    if linkTarget != nil {
//                        if linkTarget.isKindOfClass(NSNumber) {
//                            print("No idea")
//                        }
//                        else if linkTarget.isKindOfClass(NSString) {
//                            let linkUri = linkTarget as! String
//                            let url = NSURL(string: linkUri)
//                            print(url!)
//
//                            let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("ImageSliderRoot") as! ImageSliderRootViewController
//                            self.presentViewController(mapViewControllerObejct, animated: true, completion: nil)
//                        }
//                    }
//                }
//                
//            }
//        }
    }
    
    // Use layoutSubviews to center the PDF page in the view.
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return testView
    }
    
    func setZoomScale() {
        let testViewSize = testView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / testViewSize.width
        let heightScale = scrollViewSize.height / testViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.maximumZoomScale = 5.0
        scrollView.zoomScale = min(widthScale, heightScale)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let testViewSize = testView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = testViewSize.height < scrollViewSize.height ? (scrollViewSize.height - testViewSize.height) / 2 : 0
        let horizontalPadding = testViewSize.width < scrollViewSize.width ? (scrollViewSize.width - testViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollViewDidZoom(scrollView)
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

