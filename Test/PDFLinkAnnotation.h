#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDFLinkAnnotation : NSObject {
    CGPDFDictionaryRef annotationDictionary;
    CGRect pdfRectangle;
}

@property (readonly, assign) CGRect pdfRectangle;

- (id)initWithPDFDictionary:(CGPDFDictionaryRef)newAnnotationDictionary;
- (BOOL)hitTest:(CGPoint)point;
- (NSObject*)getLinkTarget:(CGPDFDocumentRef)document;
- (CGPDFArrayRef)findDestinationByName:(const char *)destinationName inDestsTree:(CGPDFDictionaryRef)node;

@end
