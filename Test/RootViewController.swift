import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    var pageViewController: UIPageViewController?
    @IBOutlet weak var pagerViewWrapper: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pagerModel = [PagerView]()

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }
    
    var _modelController: ModelController? = nil
    let pdf = PDFReaderHelper.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        self.pageViewController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self

        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })

        self.pageViewController!.dataSource = self.modelController

        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.view.sendSubviewToBack(self.pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        let pageViewRect = self.view.bounds
//        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//            pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0)
//        }
        self.pageViewController!.view.frame = pageViewRect
        self.pageViewController!.didMoveToParentViewController(self)
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
        
        // change pagerViewWrapper state based on tap
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tapedOnPDFView:", name: "tapedOnPDFView", object: nil)
        
        // scrollView setup
        let scrollView = UIScrollView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: pagerViewWrapper.frame.size))
        let size = pagerModel.reduce(0.0, combine: { $0 + $1.frame.size.width })
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = CGSize(width: size, height: pagerViewWrapper.frame.height)
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        
        // add pdf pages to scrollView
        for item in 1...pdf.pageCount {
            let data = PagerView(frame: CGRect(x: (CGFloat(item) - 1.0) * 120.0, y: 0.0, width: collectionView.frame.height, height: collectionView.frame.height))
            data.pageNumber = item
            data.setNeedsDisplay()
            
            // handle pager item tap for pdf navigation
            let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handlePagerItemTap:"))
            data.addGestureRecognizer(tapGesture)
            scrollView.addSubview(data)
        }
        
        // pagerViewWrapper default position(out of view bounds)
        pagerViewWrapper.alpha = 0
        pagerViewWrapper.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        
        // remove collection view because it's sloooooow
        collectionView.removeFromSuperview()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        pagerViewWrapper.addGestureRecognizer(swipeDown)
        
        pagerViewWrapper.addSubview(scrollView)
    }
    
    override func viewDidAppear(animated: Bool) {
        togglePager(0.3, delay: 0.5)
    }
    
    // this method is called when a tap is recognized
    func handlePagerItemTap(sender: UITapGestureRecognizer) {
        let currentView = sender.view as! PagerView
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(currentView.pageNumber - 1, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }
    
    private func togglePager(duration: NSTimeInterval, delay: NSTimeInterval = 0.0) {
        if pagerViewWrapper.alpha == 1 {
            animatePagerViewWrapper(duration, delay: delay) { () -> Void in
                self.pagerViewWrapper.alpha = 0
                self.pagerViewWrapper.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
            }
        }
        else {
            animatePagerViewWrapper(duration, delay: delay) { () -> Void in
                let frame = self.pagerViewWrapper.frame
                self.pagerViewWrapper.alpha = 1
                self.pagerViewWrapper.frame.origin = CGPoint(x: 0, y: self.view.frame.height - frame.height)
            }
        }
    }
    
    private func animatePagerViewWrapper(duration: NSTimeInterval, delay: NSTimeInterval, completion: () -> ()) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                completion()
            }, completion: nil)
    }
    
    func tapedOnPDFView(notification: NSNotification){
        togglePager(0.3)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        animatePagerViewWrapper(0.3, delay: 0.0) { () -> Void in
            self.pagerViewWrapper.alpha = 0
            self.pagerViewWrapper.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        }
    }

    private func loadData() {
        for item in 1...pdf.pageCount {
            let data = PagerView(frame: CGRect(x: 0, y: 0, width: collectionView.frame.height, height: collectionView.frame.height))
            data.pageNumber = item
            data.setNeedsDisplay()
            pagerModel.append(data)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdf.pageCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
            as! CollectionViewCell
        cell.pdfViewWrapper = pagerModel[indexPath.row]
        cell.addSubview(pagerModel[indexPath.row])
        print(indexPath.row)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(indexPath.row, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }

    // MARK: - UIPageViewController delegate methods

    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .Portrait) || (orientation == .PortraitUpsideDown) || (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })

            self.pageViewController!.doubleSided = false
            return .Min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfterViewController: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBeforeViewController: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })

        return .Mid
    }
}

