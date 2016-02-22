
import Foundation

public enum RequestBody {
  case None
  case Text (String)
  case Json (String)
  case Bytes ([UInt8])
}