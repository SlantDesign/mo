import C4
import Foundation
import CocoaAsyncSocket
import CocoaLumberjack

open class SocketManager: NSObject, GCDAsyncUdpSocketDelegate {
    static let masterPort = UInt16(10101)
    static let peripheralPort = UInt16(11111)
    static let masterHost = "10.0.0.1"
    static let broadcastHost = "10.0.255.255"

    //255.255.0.0 (DHCP subnet mask)
    //10.0.0.2 (router network)

    static let sharedManager = SocketManager()

    var workspace: WorkSpace?
    
    let maxDeviceID = 28

    //the socket that will be used to connect to the core app
    var socket: GCDAsyncUdpSocket!

    open lazy var deviceID: Int = {
        var deviceName = UIDevice.current.name
        deviceName = deviceName.replacingOccurrences(of: "MO", with: "")
        if let deviceID = Int(deviceName) {
            return deviceID
        }
        return 0
    }()

    public override init() {
        super.init()

        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        try! socket.enableBroadcast(true)
        try! socket.bind(toPort: SocketManager.peripheralPort)
        try! socket.beginReceiving()

        let packet = Packet(type: .handshake, id: deviceID)
        socket.send(packet.serialize() as Data, toHost: SocketManager.masterHost, port: SocketManager.masterPort, withTimeout: -1, tag: 0)
    }

    open func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        var packet: Packet!
        do {
            packet = try Packet((data as NSData) as Data)
        } catch {
            DDLogVerbose("Could not initialize packet from data: \(error)")
            return
        }

        switch packet.packetType {
        case .handshake:
            DDLogVerbose("\(deviceID) shook hands with \(sock)")

        case .ping:
            let packet = Packet(type: .ping, id: deviceID)
            socket.send(packet.serialize() as Data, toHost: SocketManager.masterHost, port: SocketManager.masterPort, withTimeout: -1, tag: 0)

        default:
            workspace?.receivePacket(packet)
        }
    }

    open func broadcastPacket(_ packet: Packet) {
        socket.send(packet.serialize() as Data, toHost: SocketManager.broadcastHost, port: SocketManager.peripheralPort, withTimeout: -1, tag: 0)
    }
}
