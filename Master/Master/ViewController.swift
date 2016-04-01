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
        let sorted = (socketManager.peripherals as NSArray).sortedArrayUsingDescriptors(tableView.sortDescriptors)
        sortedPeripherals = sorted as! [Peripheral]
        tableView.reloadData()
    }

    // MARK: - NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return sortedPeripherals.count
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        guard let column = tableColumn else {
            return nil
        }
        let peripheral = sortedPeripherals[row]

        switch column.identifier {
        case "id":
            return peripheral.id

        case "status":
            return peripheral.status

        case "lag":
            return peripheral.lag

        default:
            return nil
        }
    }

    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        reload()
    }


    // MARK: - NSTableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
        guard let view = tableView.makeViewWithIdentifier(column.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        let peripheral = sortedPeripherals[row]

        switch column.identifier {
        case "id":
            view.textField?.integerValue = peripheral.id

        case "status":
            view.textField?.stringValue = peripheral.status

        case "lag":
            view.textField?.stringValue = String(format: "%.2fms", arguments: [peripheral.lag * 1000.0])

        default:
            break
        }

        return view
    }
}

