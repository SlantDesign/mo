import CocoaAsyncSocket
import CocoaLumberjack

class Peripheral: NSObject, GCDAsyncSocketDelegate {
    static let pingInterval = 0.5
    static let pingTimeout = 5.0

    /// The peripheral's identifier
    var id = -1

    /// The socket connected to the peripheral
    var socket: GCDAsyncSocket

    /// Whether a hanshake was received
    var handshaked = false

    /// Buffer for reading data
    var readBuffer = NSMutableData()

    /// The action to invoke when a packet is received
    var didReceivePacketAction: ((Packet, Peripheral) -> Void)?

    /// The action to invoke when the connection is lost
    var didDisconnectAction: ((Peripheral) -> Void)?

    var status: String {
        if socket.isDisconnected {
            return "Disconnected"
        } else if handshaked {
            return "Connected"
        } else {
            return "Waiting"
        }
    }

    var pingDate: NSDate?
    var lastLag: NSTimeInterval = 0
    weak var pingTimer: NSTimer?

    var lag: NSTimeInterval {
        if let date = pingDate {
            return NSDate().timeIntervalSinceDate(date)
        }
        return lastLag
    }

    init(socket: GCDAsyncSocket) {
        self.socket = socket
        super.init()
        socket.delegate = self
    }

    deinit {
        pingTimer?.invalidate()
        socket.delegate = nil
    }

    func sendHandshake() {
        let p = Packet(type: .Handshake, id: SocketManager.masterID)
        socket.writeData(p.serialize(), withTimeout: -1, tag: 0)
        socket.readDataWithTimeout(-1, tag: 0)

        pingTimer = NSTimer.scheduledTimerWithTimeInterval(Peripheral.pingInterval, target: self, selector: #selector(Peripheral.ping), userInfo: nil, repeats: true)
    }

    func ping() {
        if !socket.isConnected {
            return
        }

        if let date = pingDate {
            // Disconnect if we don't get a ping for a while
            if NSDate().timeIntervalSinceDate(date) > Peripheral.pingTimeout {
                socket.disconnect()
            }
            return
        }

        pingDate = NSDate()
        let p = Packet(type: .Ping, id: SocketManager.masterID)
        socket.writeData(p.serialize(), withTimeout: -1, tag: 0)
        socket.readDataWithTimeout(-1, tag: 0)
    }

    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        readBuffer.appendData(data)

        var readOffset = 0
        while readBuffer.length >= sizeof(UInt32) {
            let packetSize = Int(UnsafePointer<UInt32>(readBuffer.bytes + readOffset).memory)
            if packetSize > 0 && readBuffer.length - readOffset >= packetSize {
                // We have all the data necessary for the packet
                let packetData = NSData(bytes: readBuffer.bytes + readOffset, length: packetSize)
                processPacketWithData(packetData, fromSocket: sock)
                readOffset += packetSize
            } else {
                break
            }
        }

        // Move remaining data to the beginning of the buffer
        let remainingSize = readBuffer.length - readOffset
        readBuffer.replaceBytesInRange(NSRange(location: 0, length: remainingSize), withBytes: readBuffer.bytes + readOffset)
        readBuffer.length -= readOffset

        sock.readDataWithTimeout(-1, tag: 0)
    }

    func processPacketWithData(data: NSData, fromSocket sock: GCDAsyncSocket) {
        var packet: Packet
        do {
            packet = try Packet(data)
        } catch {
            DDLogWarn("Invalid packet received from \(id): \(error)")
            return
        }

        switch packet.packetType {
        case .Handshake:
            id = packet.id
            handshaked = true
            DDLogVerbose("Got handshake from \(id)")

        case .Ping:
            if let sentDate = pingDate {
                lastLag = NSDate().timeIntervalSinceDate(sentDate)
                pingDate = nil
            }

        default:
            break
        }

        didReceivePacketAction?(packet, self)
    }

    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLogVerbose("Disconnected from: \(id)")
        pingDate = nil
        lastLag = 0
        pingTimer?.invalidate()
        didDisconnectAction?(self)
    }
}
