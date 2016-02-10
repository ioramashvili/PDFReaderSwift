#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PDFLinkAnnotation.h"
#import "TiledPDFView.h"




@implementation TiledPDFView

- (NSMutableArray*)loadPageLinks:(CGPDFPageRef)page {
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(page);
    CGPDFArrayRef annotsArray = NULL;
    
    // PDF links are link annotations stored in the page's Annots array.
    CGPDFDictionaryGetArray(pageDictionary, "Annots", &annotsArray);
    if (annotsArray != NULL) {
        long annotsCount = CGPDFArrayGetCount(annotsArray);
        NSMutableArray *pageLinks = [[NSMutableArray alloc] init];
        for (int j = 0; j < annotsCount; j++) {
            CGPDFDictionaryRef annotationDictionary = NULL;
            if (CGPDFArrayGetDictionary(annotsArray, j, &annotationDictionary)) {
                const char *annotationType;
                CGPDFDictionaryGetName(annotationDictionary, "Subtype", &annotationType);
                
                // Link annotations are identified by Link name stored in Subtype key in annotation dictionary.
                if (strcmp(annotationType, "Link") == 0) {
                    NSLog(@"Link");
                    PDFLinkAnnotation *linkAnnotation = [[PDFLinkAnnotation alloc] initWithPDFDictionary: annotationDictionary];
                    
                    [pageLinks addObject: linkAnnotation];
                }
            }
        }
        return pageLinks;
    }
    
    return NULL;
}

@end