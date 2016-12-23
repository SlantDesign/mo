import Cocoa
import CocoaAsyncSocket

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!

    var socketManager = SocketManager.sharedManager
    var sortedPeripherals = [Peripheral]()

    override func viewDidLoad() {
        super.viewDidLoad()
        socketManager.changeAction = {
            self.reload()
        }
    }

    func reload() {
        let array = Array(socketManager.peripherals.values)
        let sorted = (array as NSArray).sortedArray(using: tableView.sortDescriptors)
        sortedPeripherals = sorted as! [Peripheral]
        tableView.reloadData()
    }

    @IBAction func syncAnimations(_ sender: NSButton) {
        let p = Packet(type: .sync, id: SocketManager.masterID)
        socketManager.socket.send(p.serialize(), toHost: SocketManager.broadcastHost, port: SocketManager.peripheralPort, withTimeout: -1, tag: 0)
    }


    // MARK: - NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return sortedPeripherals.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let column = tableColumn else {
            return nil
        }
        let peripheral = sortedPeripherals[row]

        switch column.identifier {
        case "id":
            return peripheral.id

        case "status":
            return peripheral.status.rawValue

        case "lag":
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
        guard let view = tableView.make(withIdentifier: column.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        let peripheral = sortedPeripherals[row]

        switch column.identifier {
        case "id":
            view.textField?.integerValue = peripheral.id

        case "status":
            view.textField?.stringValue = peripheral.status.rawValue

        case "lag":
            view.textField?.stringValue = String(format: "%.2fms", arguments: [peripheral.lag * 1000.0])

        default:
            break
        }

        return view
    }
}

