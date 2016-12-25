//  Copyright © 2016 Slant. All rights reserved.

import Foundation

extension Data {
    public func extract<T>(_ type: T.Type, at offset: Int) -> T {
        return self.withUnsafeBytes{ (pointer: UnsafePointer<UInt8>) -> T in
            pointer.advanced(by: offset).withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
    }
    
    public mutating func append<T>(_ value: T) {
        var varValue = value
        withUnsafePointer(to: &varValue) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
                append($0, count: MemoryLayout<T>.size)
            }
        }
    }
}
