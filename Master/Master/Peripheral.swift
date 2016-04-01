import CocoaAsyncSocket
import CocoaLumberjack

class Peripheral: NSObject {
    enum Status: String {
        case Connecting
        case Connected
        case Disconnected
    }

    static let pingTimeout = 5.0

    var socket: GCDAsyncUdpSocket

    /// The peripheral's identifier
    var id = -1

    /// The peripheral's IP address
    var address: String

    /// Whether a hanshake was received
    var status = Status.Connecting

    var lastPingResponse: NSDate?

    var lag: NSTimeInterval {
        guard let date = lastPingResponse else {
            return -1
        }
        return NSDate().timeIntervalSinceDate(date)
    }

    /// Buffer for reading data
    var readBuffer = NSMutableData()

    /// The action to invoke when a packet is received
    var didReceivePacketAction: ((Packet, Peripheral) -> Void)?

    init(address: String, socket: GCDAsyncUdpSocket) {
        self.socket = socket
        self.address = address
        super.init()
    }

    func sendHandshake() {
        let p = Packet(type: .Handshake, id: SocketManager.masterID)
        socket.sendData(p.serialize(), toHost: SocketManager.broadcastHost, port: SocketManager.portNumber, withTimeout: -1, tag: 0)
    }

    func processData(data: NSData) {
        readBuffer.appendData(data)

        var readOffset = 0
        while readBuffer.length >= sizeof(UInt32) {
            let packetSize = Int(UnsafePointer<UInt32>(readBuffer.bytes + readOffset).memory)
            if packetSize > 0 && readBuffer.length - readOffset >= packetSize {
                // We have all the data necessary for the packet
                let packetData = NSData(bytes: readBuffer.bytes + readOffset, length: packetSize)
                processPacketWithData(packetData)
                readOffset += packetSize
            } else {
                break
            }
        }

        // Move remaining data to the beginning of the buffer
        let remainingSize = readBuffer.length - readOffset
        readBuffer.replaceBytesInRange(NSRange(location: 0, length: remainingSize), withBytes: readBuffer.bytes + readOffset)
        readBuffer.length -= readOffset
    }

    func processPacketWithData(data: NSData) {
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
            status = .Connected
            DDLogVerbose("Got handshake from \(id)")

        case .Ping:
            lastPingResponse = NSDate()

        default:
            break
        }

        didReceivePacketAction?(packet, self)
    }
}
