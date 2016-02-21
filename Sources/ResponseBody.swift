
import Foundation

public enum ResponseBody {
  case None
  case Text (String)
  case Html (String)
  case Json (String)
  case Bytes ([UInt8])

  public func length () -> Int {
    switch self {
    case .None: return 0
    case .Text (let str): return str.utf8.count
    case .Html (let str): return str.utf8.count
    case .Json (let str): return str.utf8.count
    case .Bytes (let arr): return arr.count
    }
  }
}