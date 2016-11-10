
import Foundation

class SocketParser {
  enum Error: Error {
    case invalidRequest
  }

  class RequestLine {
    let method: Method
    let path: String
    let version: String

    init (str: String) throws {
      // e.g. ["GET", "/index.html", "HTTP/1.1"]
      let parts = str.characters.split(separator: " ").map(String.init)
      if parts.count < 3 {
        self.method = .Unknown
        self.path = ""
        self.version = ""
        throw Error.invalidRequest
      }

      self.method = Method(rawValue: parts[0]) ?? .Unknown
      self.path = parts[1]
      self.version = parts[2]
    }
  }

  func readHttpRequest(_ socket: Socket) throws -> Request {
    let requestLine = try RequestLine(str: socket.readLine())
    let headers = try self.readHeaders(socket)
    let address = try? socket.peername()

    var bodyBytes: [UInt8] = []
    if
      let lengthStr = (headers.filter { $0.0.lowercased() == "content-length" }.first?.1),
      // ensure no spaces in val since Int(" 40") is nil
      let length = Int(lengthStr.trim()) {
        bodyBytes = try readBody(socket, size: length)
    }

    return try Request(
      method: requestLine.method,
      url: requestLine.path,
      body: bodyBytes,
      headers: headers,
      address: address ?? "" // TODO: Can address be unset?
    )
  }

  fileprivate func readBody (_ socket: Socket, size: Int) throws -> [UInt8] {
    var body = [UInt8]()
    var counter = 0

    while counter < size {
      body.append(try socket.read())
      counter += 1
    }
    return body
  }

  fileprivate func readHeaders(_ socket: Socket) throws -> [(String, String)] {
    var headers: [(String, String)] = []

    while true {
      let headerLine = try socket.readLine()
      if headerLine.isEmpty {
        return headers
      }
      let tokens = headerLine
        .characters
        .split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        .map(String.init)

      if let key = tokens.first, let val = tokens.last {
        headers.append((key, Belt.trim(val)))
      }
    }
  }
}
