import Foundation

let LEVELS_OF_DETAIL = 16;

class ReaderContentTile: CATiledLayer {
    
    override static func fadeDuration() -> CFTimeInterval {
        return 0.001
    }
    
    override init() {
        super.init()
        
        self.levelsOfDetail = LEVELS_OF_DETAIL; // Zoom levels
        
        self.levelsOfDetailBias = (LEVELS_OF_DETAIL - 1); // Bias
        
        let mainScreen = UIScreen.mainScreen() // Main screen
        
        let screenScale = mainScreen.scale // Main screen scale
        
        let screenBounds = mainScreen.bounds // Main screen bounds
        
        let w_pixels = (screenBounds.size.width * screenScale);
        
        let h_pixels = (screenBounds.size.height * screenScale);
        
        let max = ((w_pixels < h_pixels) ? h_pixels : w_pixels);
        
        let sizeOfTiles: CGFloat = (max < 512.0) ? 512.0 : 1024.0
        
        self.tileSize = CGSizeMake(sizeOfTiles, sizeOfTiles);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
}