import UIKit

class DataViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var testView: BaseView!
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testView = BaseView(frame: CGRect(x: 0, y: 0, width: 651, height: 841))
        testView.currentPage = currentIndex + 1
        testView.setNeedsDisplay()
        
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
    }
    
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

