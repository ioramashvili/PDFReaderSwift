import UIKit

class ImageSliderModelViewController: NSObject, UIPageViewControllerDataSource {
    
    override init() {
        super.init()
    }
    
    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> ImageSliderDataViewController? {
        if !PDFReaderHelper.sharedInstance().isValidPage(atIndex: index) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("ImageSliderData") as! ImageSliderDataViewController
        dataViewController.currentIndex = index
        return dataViewController
    }
    
    func indexOfViewController(viewController: ImageSliderDataViewController) -> Int {
        return viewController.currentIndex
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ImageSliderDataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ImageSliderDataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == PDFReaderHelper.sharedInstance().pageCount {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}
