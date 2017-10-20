// Copyright © 2017 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

extension Node {
    /// Node status.
    public enum Status: String {
        case connecting
        case connected
        case disconnected
    }
}
