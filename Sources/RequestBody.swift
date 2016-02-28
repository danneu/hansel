
import Foundation
import Jay

enum RequestBodyError: ErrorType {
  // doesn't convert from byte array into the attempted format
  case Unconvertible
}

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
      throw RequestBodyError.Unconvertible
    }
  }

  // Ex: request.body.json() as! [Int]
  //     request.body.json() as! [String: Any]
  func json () throws -> Any {
    do {
      return try Jay().jsonFromData(self.bytes)
    } catch {
      throw RequestBodyError.Unconvertible
    }
  }

  public var description: String {
    return self.bytes.description
  }
}