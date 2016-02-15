import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pdfViewWrapper: PDFRenderView!
}


class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pdfViewWrapper: PagerView!
}

class PagerView: UIView {
    var pageNumber: Int!
    var pageRect: CGRect!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        if let pageNumber = pageNumber {
            let ctx = UIGraphicsGetCurrentContext()
            let page = PDFReaderHelper.sharedInstance().getPage(atIndex: pageNumber)
            pageRect = PDFPageRenderer.renderPage(page, inContext: ctx, inRectangle: self.bounds)
        }
    }
}