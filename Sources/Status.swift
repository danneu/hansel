
import Foundation

// TODO: Flesh the statuses out

public enum Status: Int {
  case Ok = 200

  case PermRedirect = 301
  case TempRedirect = 302

  case BadRequest = 400
  case Forbidden = 403
  case NotFound = 404

  case Error = 500

  public var phrase: String {
    switch self {
    case .Ok: return "OK"

    case .PermRedirect: return "Permanent Redirect"
    case .TempRedirect: return "Found"

    case .BadRequest: return "Bad Request"
    case .Forbidden: return "Forbidden"
    case .NotFound: return "Not Found"
      
    case .Error: return "Internal Server Error"
    }
  }

  // Does response of this status expect an empty body
  public func emptyBody () -> Bool {
    switch self.rawValue {
    case 204: return true
    case 205: return true
    case 304: return true
    default: return false
    }
  }
}