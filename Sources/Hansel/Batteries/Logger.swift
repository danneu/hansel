
import Foundation

extension Batteries {
  static let logger: Middleware = { handler in
    return { request in
      logRequest(request)
      let start = getMillis()
      let response = try handler(request)
      logResponse(request, response: response, start: start)
      return response
    }
  }
}

func logRequest (request: Request) -> Void {
  print("\(Color.Gray.wrap("-->")) \(String(request.method).uppercaseString) \(Color.Gray.wrap(request.url))")
}

func logResponse (request: Request, response: Response, start: Int) -> Void {
  var color: Color
  switch response.status.rawValue {
  case 500..<600: color = .Red
  case 400..<500: color = .Yellow
  case 300..<400: color = .Cyan
  case 200..<300: color = .Green
  case 100..<200: color = .Green
  default: color = .Red
  }

  let upstream = Color.Gray.wrap("<--")
  print("\(upstream) \(String(request.method).uppercaseString) \(Color.Gray.wrap(request.url)) \(color.wrap(String(response.status.rawValue))) \(time(start))")
}

func time (start: Int) -> String {
  return String(getMillis() - start) + "ms"
}

func getMillis () -> Int {
  return Int(NSDate().timeIntervalSince1970 * 1000)
}

enum Color: String {
  case None = "0m"
  case Red = "0;31m"
  case Green = "0;32m"
  case Yellow = "0;33m"
  case Blue = "0;34m"
  case Magenta = "0;35m"
  case Cyan = "0;36m"
  case White = "0;37m"
  case Gray = "0;90m"

  func wrap (str: String) -> String {
    let escape = "\u{001B}["
    return "\(escape)\(self.rawValue)\(str)\(escape)\(Color.None.rawValue)"
  }
}
