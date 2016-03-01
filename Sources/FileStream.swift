
import Foundation

public struct FileStream {
  var mtime: Int
  var size: Int
  var stream: NSInputStream

  // TODO: Throw on fail
  init (_ path: String, size: Int, mtime: Int) {
    let stream: NSInputStream = NSInputStream(fileAtPath: path)!
    self.stream = stream
    self.size = size
    self.mtime = mtime
  }
}

extension FileStream: Streamable {
  public func next () -> [UInt8]? {
    let bytes = stream.next()
    return bytes
  }

  public func open () -> Void {
    self.stream.open()
  }

  public func close () -> Void {
    self.stream.close()
  }

  public var length: Int? {
    return size
  }
}