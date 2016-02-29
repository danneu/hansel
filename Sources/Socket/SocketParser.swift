
import Foundation

class SocketParser {
  enum Error: ErrorType {
    case InvalidRequest
  }

  class RequestLine {
    let method: Method
    let path: String
    let version: String

    init (str: String) throws {
      // e.g. ["GET", "/index.html", "HTTP/1.1"]
      let parts = str.characters.split(" ").map(String.init)
      if parts.count < 3 {
        self.method = .Unknown
        self.path = ""
        self.version = ""
        throw Error.InvalidRequest
      }

      self.method = Method(rawValue: parts[0]) ?? .Unknown
      self.path = parts[1]
      self.version = parts[2]
    }
  }

  func readHttpRequest(socket: Socket) throws -> Request {
    let requestLine = try RequestLine(str: socket.readLine())
    let headers = try self.readHeaders(socket)
    let address = try? socket.peername()

    var bodyBytes: [UInt8] = []
    if
      let lengthStr = (headers.filter { $0.0.lowercaseString == "content-length" }.first?.1),
      let length = Int(lengthStr) {
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

  private func readBody (socket: Socket, size: Int) throws -> [UInt8] {
    var body = [UInt8]()
    var counter = 0

    while counter < size {
      body.append(try socket.read())
      counter += 1
    }
    return body
  }

  private func readHeaders(socket: Socket) throws -> [(String, String)] {
    var headers: [(String, String)] = []

    while true {
      let headerLine = try socket.readLine()
      if headerLine.isEmpty {
        return headers
      }
      let tokens = headerLine
        .characters
        .split(":", maxSplit: 1, allowEmptySlices: true)
        .map(String.init)

      if let key = tokens.first, val = tokens.last {
        headers.append((key, val))
      }
    }
  }
}