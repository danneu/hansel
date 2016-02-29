
import Foundation

public enum Method: String {
  // Common
  case Get = "GET"
  case Post = "POST"
  case Put = "PUT"
  case Head = "HEAD"
  case Delete = "DELETE"
  case Options = "OPTIONS"
  case Patch = "PATCH"

  // Uncommon
  case Trace = "TRACE"
  case Copy = "COPY"
  case Lock = "LOCK"
  case Mkcol = "MKCOL"
  case Move = "MOVE"
  case Purge = "PURGE"
  case Propfind = "PROPFIND"
  case Proppatch = "PROPPATCH"
  case Unlock = "UNLOCK"
  case Report = "REPORT"
  case Mkactivity = "MKACTIVITY"
  case Checkout = "CHECKOUT"
  case Merge = "MERGE"
  case Msearch = "M-SEARCH"
  case Notify = "NOTIFY"
  case Subscribe = "SUBSCRIBE"
  case Unsubscribe = "UNSUBSCRIBE"
  case Search = "SEARCH"
  case Connect = "CONNECT"

  // Internal
  case Unknown = "_"
}