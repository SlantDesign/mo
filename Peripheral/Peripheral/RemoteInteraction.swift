import C4

public struct RemoteInteraction {
    /// The interaction point in universe coordinates
    public var point: CGPoint

    /// The timestamp
    public var timestamp: NSTimeInterval

    /// The ID of the source device
    public var deviceID: Int
}
