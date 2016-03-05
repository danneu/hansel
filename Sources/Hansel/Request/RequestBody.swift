
import Foundation
import Jay

// It's a class so that we aren't copying potentially large bodies
public class RequestBody: CustomStringConvertible {
  let bytes: [UInt8]

  init (_ bytes: [UInt8] = []) {
    self.bytes = bytes
  }

  func utf8 () throws -> String {
    if let str = NSString(bytes: self.bytes, length: self.bytes.count, encoding: NSUTF8StringEncoding) as? String {
      return str
    } else {
      throw RequestError.BadBody
    }
  }

  func json () throws -> JsonValue {
    do {
      return try Jay().typesafeJsonFromData(self.bytes)
    } catch {
      throw RequestError.BadBody
    }
  }

  func json <T> (decoder: Decoder<T>) throws -> T {
    switch JD.decode(decoder, try json()) {
    case .Err (_): throw RequestError.BadBody
    case .Ok (let v): return v
    }
  }

//  func form () throws -> FormData {
//  }
//
//  func multipart () throws -> MultipartData {
//  }

  public var description: String {
    return self.bytes.description
  }
}