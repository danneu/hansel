
import Foundation
import Jay

// It's a class so that we aren't copying potentially large bodies
open class RequestBody: CustomStringConvertible {
  let bytes: [UInt8]

  public init (_ bytes: [UInt8] = []) {
    self.bytes = bytes
  }

  open func utf8 () throws -> String {
    if let str = String(bytes: self.bytes, encoding: String.Encoding.utf8) {
      return str
    } else {
      throw RequestError.badBody
    }
  }

  open func json () throws -> JsonValue {
    do {
      return try Jay().typesafeJsonFromData(self.bytes)
    } catch {
      throw RequestError.badBody
    }
  }

  open func json <T> (_ decoder: Decoder<T>) throws -> T {
    switch JD.decode(decoder, try json()) {
    case .Err (_): throw RequestError.badBody
    case .Ok (let v): return v
    }
  }

//  func form () throws -> FormData {
//  }
//
//  func multipart () throws -> MultipartData {
//  }

  open var description: String {
    return self.bytes.description
  }
}
