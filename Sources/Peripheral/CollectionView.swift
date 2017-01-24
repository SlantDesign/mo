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

open class Parallax: UniverseController, CollectionViewDelegate, GCDAsyncSocketDelegate {
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func awakeFromNib() {
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        let fileName = random(below: 2) == 0 ? "chop" : "rockies"
        let image = Image(fileName)
        add(image)
        clipsToBounds = true
    }
}
