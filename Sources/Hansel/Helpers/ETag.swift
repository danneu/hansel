
import Foundation
// import CryptoSwift

//
// Generate ETags
//
// Currently only generates them from byte arrays.
//
// TODO: Support weak ETags

public struct ETag {
  static func generate (_ entity: ETaggable) -> String {
    return entity.etag()
  }
}

// PROTOCOL

public protocol ETaggable {
  func etag () -> String
}

// EXTENSIONS

extension FileStream: ETaggable {
  public func etag () -> String {
    return "\"\(Base16.encode(fileSize))-\(Base16.encode(mtime))\""
  }
}

extension ByteArray: ETaggable {
  public func etag () -> String {
    if bytes.isEmpty {
      return "\"0-1B2M2Y8AsgTpgAmY7PhCfg\""
    }

    let hash64 = bytes
      |> { Hash.md5($0).calculate() }
      |> { Base64.encode($0, padding: false) }
    let len = bytes.count

    return "\"\(Base16.encode(len))-\(hash64)\""
  }
}

extension String: ETaggable {
  public func etag () -> String {
    return ByteArray(self).etag()
  }
}
