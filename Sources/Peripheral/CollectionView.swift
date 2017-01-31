//
//  Parallax.swift
//  MO
//
//  Created by travis on 2017-01-24.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket
import CocoaLumberjack
import UIKit

enum ScrollSource {
    case local
    case remote
}

public protocol CollectionViewDelegate: class {
    func shouldSendScrollData()
}

open class Collection: UniverseController, CollectionViewDelegate, GCDAsyncSocketDelegate {
    var collectionViewController: CollectionViewController?

    func initializeCollectionView() {
        let storyboard = UIStoryboard(name: "CollectionViewController", bundle: nil)
        collectionViewController = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController
        guard collectionViewController != nil else {
            print("Collection view could not be instantiated from storyboard.")
            return
        }
        collectionViewController?.collectionView?.dataSource = LayoutDataSource.shared

        canvas.add(collectionViewController?.collectionView)
        collectionViewController?.collectionViewDelegate = self
    }

    open override func receivePacket(_ packet: Packet) {
        //do stuff here
    }

    public func shouldSendScrollData() {
        //do stuff here
    }
}

open class CollectionViewController: UICollectionViewController {
    var dx: CGFloat = 0.0
    var scrollSource = ScrollSource.local
    weak var collectionViewDelegate: CollectionViewDelegate?

    override open func viewDidLoad() {
        collectionView?.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        let id = SocketManager.sharedManager.deviceID
        dx = CGFloat(id) * CGFloat(frameCanvasWidth) - CGFloat(frameGap/2.0)
        collectionView?.contentOffset = CGPoint(x: dx, y: 0)
        collectionView?.dataSource = LayoutDataSource.shared
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var newOffset = scrollView.contentOffset
        let dx = CGFloat(4.0 * frameCanvasWidth)
        if newOffset.x < 0 {
            newOffset.x = dx
        } else if newOffset.x > dx {
            newOffset.x = 0
        }
        scrollView.contentOffset = newOffset
    }

    func remoteScrollTo(_ point: CGPoint) {
        if collectionView?.contentOffset == point {
            return
        }
        scrollSource = .remote
        collectionView?.setContentOffset(point, animated: false)
    }
}

//You need to create a customizable / repeatable object that represents
//the kinds of elements you want to see in your collection view
class Cell: UICollectionViewCell {
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    var image: Image? {
        willSet {
            image?.removeFromSuperview()
        } didSet {
            add(image)
            sendToBack(image)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        add(label)
    }

    override func awakeFromNib() {
        clipsToBounds = true
        add(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
