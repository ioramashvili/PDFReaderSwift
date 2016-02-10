#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TiledPDFView : NSObject  {
    
}
    -(NSMutableArray*)loadPageLinks:(CGPDFPageRef)page;
@end
