
import Foundation
import Jay

typealias Bytes = [UInt8]

enum RequestBodyError: ErrorType {
  case Unconvertible
}

// It's a class so that we aren't copying potentially large bodies
public class RequestBody: CustomStringConvertible {
  let bytes: Bytes

  init (_ bytes: Bytes = []) {
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