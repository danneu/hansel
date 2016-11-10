
import Foundation

// Logger
//
// This is stubbed out for experimentation

let stderr = FileHandle.withStandardError

public struct Log {
  // write to stderr
  //
  // e.g. Log.error("uh oh", [1,2,3], User.init(42, "Murphy"))
  public static func error (_ xs: CustomStringConvertible...) {
    let msg = (["ERROR"] + xs + ["\n"])
      .map { $0.description }
      .joined(separator: " ")
      .data(using: String.Encoding.utf8)!
    stderr.write(msg)
  }
}
