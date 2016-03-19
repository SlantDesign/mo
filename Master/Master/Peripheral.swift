import CocoaAsyncSocket
import CocoaLumberjackSwift

class Peripheral: NSObject, GCDAsyncSocketDelegate {
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

    init(socket: GCDAsyncSocket) {
        self.socket = socket
        super.init()
        socket.delegate = self
    }

    deinit {
        socket.delegate = nil
    }

    func sendHandshake(deviceID: Int) {
        let p = Packet(type: .Handshake, id: deviceID)
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

        if packet.packetType == .Handshake {
            id = packet.id
            handshaked = true
            DDLogVerbose("Got handshake from \(id)")
        }

        didReceivePacketAction?(packet, self)
    }

    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLogVerbose("Disconnected from: \(id)")
        didDisconnectAction?(self)
    }
}
