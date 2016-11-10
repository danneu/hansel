
import Foundation

public struct FileStream: Payload {
  var modifiedAt: Date
  var fileSize: Int
  var stream: InputStream

  // seconds since epoch
  var mtime: Int {
    return Int(modifiedAt.timeIntervalSince1970)
  }

  // TODO: Throw on fail
  public init (_ path: String, fileSize: Int, modifiedAt: Date) {
    let stream: InputStream = InputStream(fileAtPath: path)!
    self.stream = stream
    self.fileSize = fileSize
    self.modifiedAt = modifiedAt
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
    return fileSize
  }
}
