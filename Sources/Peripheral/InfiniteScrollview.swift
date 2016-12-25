// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import UIKit
import Foundation

open class InfiniteScrollView: UIScrollView {
    open override func layoutSubviews() {
        super.layoutSubviews()

        //grab the current content offset (top-left corner)
        var curr = contentOffset
        //if the x value is less than zero
        if curr.x < 0 {
            //update x to the end of the scrollview
            curr.x = contentSize.width - frame.width
            //set the content offset for the view
            contentOffset = curr
        }
            //if the x value is greater than the width - frame width
            //(i.e. when the top-right point goes beyond contentSize.width)
        else if curr.x >= contentSize.width - frame.width {
            //update x to the beginning of the scrollview
            curr.x = 0
            //set the content offset for the view
            contentOffset = curr
        }
    }
}
