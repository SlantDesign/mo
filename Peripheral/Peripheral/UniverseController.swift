//  Copyright © 2015 C4. All rights reserved.

import UIKit

let frameGap = 229.0
let frameCanvasWidth = 997.0

public class UniverseController : CanvasController {
    public override func viewDidLoad() {
        canvas.bounds.origin.x = dx
        canvas.backgroundColor = clear
        super.viewDidLoad()
    }
    
    var physicalFrame : Rect {
        get {
            return Rect(dx-frameGap/2.0,0,frameCanvasWidth,1024)
        }
    }

    var accesPoints : Int {
        get {
            return 5
        }
    }
    
    var dx : Double {
        get {
            return Double(id-1) * frameCanvasWidth - frameGap/2.0
        }
    }
    
    var id : Int {
        get {
           return NSUserDefaults.standardUserDefaults().integerForKey("deviceID")
        }
    }
    
    public func handleGesture(gesture: Gesture) {
        
    }
    
    public func unload() {
        
    }
}
