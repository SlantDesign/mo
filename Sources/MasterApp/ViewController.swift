// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import Cocoa
import CocoaAsyncSocket
import CocoaLumberjack
import MOHub

let config = NetworkConfiguration()

extension PacketType {
    static let scroll = PacketType(rawValue: 10)
    static let resonateShape = PacketType(rawValue: 11)
    static let cease = PacketType(rawValue: 12)
    static let sync = PacketType(rawValue: 13)
    static let switchUniverse = PacketType(rawValue: 14)
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, SocketManagerDelegate {
    let socketManager = SocketManager(networkConfiguration: config)

    @IBOutlet weak var tableView: NSTableView!

    var sortedNodes = [Node]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func reload() {
        let array = Array(socketManager.nodes.values)
        let sorted = (array as NSArray).sortedArray(using: tableView.sortDescriptors)
        sortedNodes = sorted as! [Node]
        tableView.reloadData()
    }

    @IBAction func syncAnimations(_ sender: NSButton) {
        let p = Packet(type: PacketType.sync, id: -1)
        socketManager.sendPacket(p)
    }

    // MARK: - NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return sortedNodes.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let column = tableColumn else {
            return nil
        }
        let peripheral = sortedNodes[row]

        switch column.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "id"):
            return peripheral.id

        case NSUserInterfaceItemIdentifier(rawValue: "status"):
            return peripheral.status.rawValue

        case NSUserInterfaceItemIdentifier(rawValue: "lag"):
            return peripheral.lag

        default:
            return nil
        }
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        reload()
    }

    // MARK: - NSTableViewDelegate

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
        guard let view = tableView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        let peripheral = sortedNodes[row]

        switch column.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "id"):
            view.textField?.integerValue = peripheral.id

        case NSUserInterfaceItemIdentifier(rawValue: "status"):
            view.textField?.stringValue = peripheral.status.rawValue

        case NSUserInterfaceItemIdentifier(rawValue: "lag"):
            view.textField?.stringValue = String(format: "%.2fms", arguments: [peripheral.lag * 1000.0])

        default:
            break
        }

        return view
    }

    // MARK: SocketManagerDelegate

    func handleError(_ message: String) {
        DDLogError(message)
    }

    func handlePacket(_ packet: Packet, node: Node) {
        reload()
    }

    func handleStatus(_ status: Node.Status, node: Node) {
        reload()
    }
}
