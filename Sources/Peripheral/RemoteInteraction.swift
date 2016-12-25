// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import C4

public struct RemoteInteraction {
    /// The interaction point in universe coordinates
    public var point: CGPoint

    /// The ID of the source device
    public var deviceID: Int

    /// The timestamp, from the local clock
    public var timestamp: TimeInterval
}
