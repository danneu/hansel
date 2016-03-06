
import Foundation

// Logger
//
// This is stubbed out for experimentation

let stderr = NSFileHandle.fileHandleWithStandardError()

public struct Log {
  // write to stderr
  //
  // e.g. Log.error("uh oh", [1,2,3], User.init(42, "Murphy"))
  public static func error (xs: CustomStringConvertible...) {
    let msg = (["ERROR"] + xs + ["\n"])
      .map { $0.description }
      .joinWithSeparator(" ")
      .dataUsingEncoding(NSUTF8StringEncoding)!
    stderr.writeData(msg)
  }
}