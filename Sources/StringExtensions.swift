//
// Based on NSLinux (https://github.com/johnno1962/NSLinux) by johnno1962.
//

import Foundation

extension String {

    func split(_ separator: Character) -> [String] {
        return self.characters.split { $0 == separator }.map(String.init)
    }
    
    func split(_ maxSplit: Int = Int.max, separator: Character) -> [String] {
        return self.characters.split(maxSplits: maxSplit) { $0 == separator }.map(String.init)
    }
    
    func replace(_ old: Character, new: Character) -> String {
        var buffer = [Character]()
        self.characters.forEach { buffer.append($0 == old ? new : $0) }
        return String(buffer)
    }
    
    func unquote() -> String {
        var scalars = self.unicodeScalars;
        if scalars.first == "\"" && scalars.last == "\"" && scalars.count >= 2 {
            scalars.removeFirst();
            scalars.removeLast();
            return String(scalars)
        }
        return self
    }

    func trim() -> String {
        var scalars = self.unicodeScalars
        while let _ = unicodeScalarToUInt32Whitespace(scalars.first) { scalars.removeFirst() }
        while let _ = unicodeScalarToUInt32Whitespace(scalars.last) { scalars.removeLast() }
        return String(scalars)
    }
    
    static func fromUInt8(_ array: [UInt8]) -> String {
        return String(data: Data(bytes: array), encoding: String.Encoding.utf8) ?? ""
    }
    
    fileprivate func unicodeScalarToUInt32Whitespace(_ x: UnicodeScalar?) -> UInt8? {
        if let x = x {
            if x.value >= 9 && x.value <= 13 {
                return UInt8(x.value)
            }
            if x.value == 32 {
                return UInt8(x.value)
            }
        }
        return nil
    }
    
    fileprivate func unicodeScalarToUInt32Hex(_ x: UnicodeScalar?) -> UInt8? {
        if let x = x {
            if x.value >= 48 && x.value <= 57 {
                return UInt8(x.value) - 48
            }
            if x.value >= 97 && x.value <= 102 {
                return UInt8(x.value) - 87
            }
            if x.value >= 65 && x.value <= 70 {
                return UInt8(x.value) - 55
            }
        }
        return nil
    }
}
