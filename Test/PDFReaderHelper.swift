import UIKit

class PDFReaderHelper {
    private static var _sharedInstance = PDFReaderHelper()
    private var pdf: CGPDFDocument!
    private var _pageCount: Int
    
    static func sharedInstance() -> PDFReaderHelper {
        return _sharedInstance
    }
    
    private init() {
        let path = NSBundle.mainBundle().pathForResource("Document", ofType: "pdf")!
        let url = NSURL(fileURLWithPath: path) as CFURLRef
        pdf = CGPDFDocumentCreateWithURL(url)
        _pageCount = CGPDFDocumentGetNumberOfPages(pdf)
    }
    
    func getPage(atIndex index: Int) -> CGPDFPage {
        return CGPDFDocumentGetPage(pdf, index)!
    }
    
    func isValidPage(atIndex index: Int) -> Bool {
        return index == 0 || index < pageCount
    }
    
    var pageCount: Int {
        return _pageCount
    }
}