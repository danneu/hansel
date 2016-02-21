
import Foundation

public enum ResponseBody {
  case None
  case Text (String)
  case Html (String)
  case Json (String)
  case Bytes ([UInt8], String?)

  public func length () -> Int {
    switch self {
    case .None: return 0
    case .Text (let str): return str.utf8.count
    case .Html (let str): return str.utf8.count
    case .Json (let str): return str.utf8.count
    case .Bytes (let arr, _): return arr.count
    }
  }

  // when nil, content-type should not be set
  public func contentType () -> String? {
    switch self {
    case .None: return nil
    case .Text (_): return "text/plain"
    case .Html (_): return "text/html"
    case .Json (_): return "application/json"
    case .Bytes (_, let type): return type ?? "application/octet-stream"
    }
  }
}