
import Foundation

// Stub out CryptoSwift's md5 interface until its stable
// version works with Swift Package Manager.
// 
// Hash.md5(bytes).calculate()

public struct Hash {
  struct md5 {
    let bytes: [UInt8]

    init (_ bytes: [UInt8]) {
      self.bytes = bytes
    }

    func calculate () -> [UInt8] {
      return cc_md5(bytes)
    }
  }
}

// does nothing for now. returns 16 bytes of 'a'
private func cc_md5 (_ input: [UInt8]) -> [UInt8] {
  return [UInt8](repeating: 97, count: 16)
}

//  private func cc_md5 (input: [UInt8]) -> [UInt8] {
//    var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
//    let data = NSData(bytes: input, length: input.count)
//    CC_MD5(data.bytes, CC_LONG(data.length), &digest)
//    return digest
//  }
