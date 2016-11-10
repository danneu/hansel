//
// Based on HttpSocket from Swifter (https://github.com/glock45/swifter) by Damian Kołakowski.
//

#if os(Linux)
  import Glibc
#else
  import Foundation
#endif

public enum SocketError: Error {
  case socketCreationFailed(String)
  case socketSettingReUseAddrFailed(String)
  case bindFailed(String)
  case listenFailed(String)
  case writeFailed(String)
  case getPeerNameFailed(String)
  case convertingPeerNameFailed
  case getNameInfoFailed(String)
  case acceptFailed(String)
  case recvFailed(String)
}

open class Socket: Hashable, Equatable {

  open class func tcpSocketForListen(_ port: in_port_t, maxPendingConnection: Int32 = SOMAXCONN) throws -> Socket {
    #if os(Linux)
      let socketFileDescriptor = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
    #else
      let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
    #endif

    if socketFileDescriptor == -1 {
      throw SocketError.socketCreationFailed(Socket.descriptionOfLastError())
    }

    var value: Int32 = 1
    if setsockopt(socketFileDescriptor, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size)) == -1 {
      let details = Socket.descriptionOfLastError()
      Socket.release(socketFileDescriptor)
      throw SocketError.socketSettingReUseAddrFailed(details)
    }
    Socket.setNoSigPipe(socketFileDescriptor)

    #if os(Linux)
      var addr = sockaddr_in()
      addr.sin_family = sa_family_t(AF_INET)
      addr.sin_port = Socket.htonsPort(port)
      addr.sin_addr = in_addr(s_addr: in_addr_t(0))
      addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
    #else
      var addr = sockaddr_in()
      addr.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)
      addr.sin_family = sa_family_t(AF_INET)
      addr.sin_port = Socket.htonsPort(port)
      addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
      addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
    #endif

    var bind_addr = sockaddr()
    memcpy(&bind_addr, &addr, Int(MemoryLayout<sockaddr_in>.size))

    if bind(socketFileDescriptor, &bind_addr, socklen_t(MemoryLayout<sockaddr_in>.size)) == -1 {
      let details = Socket.descriptionOfLastError()
      Socket.release(socketFileDescriptor)
      throw SocketError.bindFailed(details)
    }

    if listen(socketFileDescriptor, maxPendingConnection ) == -1 {
      let details = Socket.descriptionOfLastError()
      Socket.release(socketFileDescriptor)
      throw SocketError.listenFailed(details)
    }

    return Socket(socketFileDescriptor: socketFileDescriptor)
  }

  fileprivate let socketFileDescriptor: Int32

  init(socketFileDescriptor: Int32) {
    self.socketFileDescriptor = socketFileDescriptor
  }

  open var hashValue: Int { return Int(self.socketFileDescriptor) }

  open func release() {
    Socket.release(self.socketFileDescriptor)
  }

  open func shutdwn() {
    Socket.shutdwn(self.socketFileDescriptor)
  }

  func acceptClientSocket() throws -> Socket {
    var addr = sockaddr()
    var len: socklen_t = 0
    let clientSocket = accept(self.socketFileDescriptor, &addr, &len)
    if clientSocket == -1 {
      throw SocketError.acceptFailed(Socket.descriptionOfLastError())
    }
    Socket.setNoSigPipe(clientSocket)
    return Socket(socketFileDescriptor: clientSocket)
  }

  open func writeUTF8(_ string: String) throws {
    try writeUInt8([UInt8](string.utf8))
  }

  open func writeUInt8(_ data: [UInt8]) throws {
    try data.withUnsafeBufferPointer {
      var sent = 0
      while sent < data.count {
        #if os(Linux)
          let s = send(self.socketFileDescriptor, $0.baseAddress + sent, Int(data.count - sent), Int32(MSG_NOSIGNAL))
        #else
          let s = write(self.socketFileDescriptor, $0.baseAddress! + sent, Int(data.count - sent))
        #endif
        if s <= 0 {
          throw SocketError.writeFailed(Socket.descriptionOfLastError())
        }
        sent += s
      }
    }
  }

  open func read() throws -> UInt8 {
    var buffer = [UInt8](repeating: 0, count: 1)
    let next = recv(self.socketFileDescriptor as Int32, &buffer, Int(buffer.count), 0)
    if next <= 0 {
      throw SocketError.recvFailed(Socket.descriptionOfLastError())
    }
    return buffer[0]
  }

  fileprivate static let CR = UInt8(13)
  fileprivate static let NL = UInt8(10)

  open func readLine() throws -> String {
    var characters: String = ""
    var n: UInt8 = 0
    repeat {
      n = try self.read()
      if n > Socket.CR { characters.append(Character(UnicodeScalar(n))) }
    } while n != Socket.NL
    return characters
  }

  var cachedPeerName: String?

  open func peername() throws -> String {
    if let name = self.cachedPeerName {
      return name
    }


    var addr = sockaddr(), len: socklen_t = socklen_t(MemoryLayout<sockaddr>.size)
    if getpeername(self.socketFileDescriptor, &addr, &len) != 0 {
      throw SocketError.getPeerNameFailed(Socket.descriptionOfLastError())
    }
    var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    if getnameinfo(&addr, len, &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NUMERICHOST) != 0 {
      throw SocketError.getNameInfoFailed(Socket.descriptionOfLastError())
    }
    guard let name = String(validatingUTF8: hostBuffer) else {
      throw SocketError.convertingPeerNameFailed
    }

    self.cachedPeerName = name
    return name
  }

  fileprivate class func descriptionOfLastError() -> String {
    return String(cString: UnsafePointer(strerror(errno))) ?? "Error: \(errno)"
  }

  fileprivate class func setNoSigPipe(_ socket: Int32) {
    #if os(Linux)
      // There is no SO_NOSIGPIPE in Linux (nor some other systems). You can instead use the MSG_NOSIGNAL flag when calling send(),
      // or use signal(SIGPIPE, SIG_IGN) to make your entire application ignore SIGPIPE.
    #else
      // Prevents crashes when blocking calls are pending and the app is paused ( via Home button ).
      var no_sig_pipe: Int32 = 1
      setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
    #endif
  }

  fileprivate class func shutdwn(_ socket: Int32) {
    #if os(Linux)
      shutdown(socket, Int32(SHUT_RDWR))
    #else
      Darwin.shutdown(socket, SHUT_RDWR)
    #endif
  }

  open class func release(_ socket: Int32) {
    #if os(Linux)
      shutdown(socket, Int32(SHUT_RDWR))
    #else
      Darwin.shutdown(socket, SHUT_RDWR)
    #endif
    close(socket)
  }

  fileprivate class func htonsPort(_ port: in_port_t) -> in_port_t {
    #if os(Linux)
      return port.bigEndian //use htons() when llvm stops crashing
    #else
      let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
      return isLittleEndian ? _OSSwapInt16(port) : port
    #endif
  }
}

public func ==(socket1: Socket, socket2: Socket) -> Bool {
  return socket1.socketFileDescriptor == socket2.socketFileDescriptor
}
