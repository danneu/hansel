

import Foundation
//import BrightFutures
//import Result


let wrapLogger: Middleware = { handler in
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
  func logRequest (request: Request) -> Void {
    print("\(Color.Gray.wrap("-->")) \(String(request.method).uppercaseString) \(Color.Gray.wrap(request.url))")
  }
  func time (start: Int) -> String {
    return String(getMillis() - start) + "ms"
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
  func getMillis () -> Int {
    return Int(NSDate().timeIntervalSince1970 * 1000)
  }
  return { request in
    logRequest(request)
    let start = getMillis()
    let response = handler(request)
    logResponse(request, response: response, start: start)
    return response
  }
}




func mw (name: String) -> Middleware {
  return { handler in
    return { request in
      print("[\(name)] enter")
      let response = handler(request)
      print("[\(name)] exit")
      return response
    }
  }
}

func handle (body: String) -> Handler {
  return { request in
    Response(body: body)
  }
}

let ensureAdmin: Middleware = { handler in
  return { request in
    print("[ensureAdmin]")
    return Response(status: .Forbidden)
  }
}

let router: Router = .Node("/", [], [
  .Route(.Get, handle("1homepage")),
  .Node("/users", [mw("B1"), mw("B2")], [
    .Route(.Get, handle("listUsers")),
    .Route(.Post, handle("createUser")),
    .Node("/admin", [ensureAdmin], [
      .Route(.Get, handle("admin panel"))
      ]),
    .Node("/test", [mw("C")], [
      .Route(.Get, handle("nested"))
      ])
    ])
  ])


//let handler: Handler = { request in
//  return Response()
//    .setBody("<!doctype html><h1>Test</h1>")
//}
//
let middleware = compose(
  //  wrapLogger,
  //  mw("AAA"),
  //  mw("BBBBB")
)

//let rootHandler = middleware(router.handler())
let rootHandler = middleware(router.handler())

Server(rootHandler).listen()


//
//let fut = Future<Int, NoError>(value: 42)
//fut.onComplete(Queue.main.context, callback: { n in
//  print("[fut] n:", n)
//})
//
//
//
//func asyncCalculation () -> Future<Int, NoError> {
//  print("A")
//  let promise = Promise<Int, NoError>()
//  print("B")
//  Queue.global.async {
//    print("C")
//    sleep(1)
//    print("C2")
//    promise.success(42)
//  }
//  print("D")
//  //return promise.future
//  return promise.future
//}
//
//
//
//
//
//var lol = "nope"
//
//let f = asyncCalculation().onComplete(callback: { result in
//  print("OMG")
//  lol = "OMG"
//})
//
//print(f)
//
//
//f.andThen(callback: { result in
//  print("XXXXXXXXXXXX")
//})
//
//f.onComplete(callback: { result in
//  print("FFFFFFFFF", result)
//  print("completed")
//})
//
//
////f.onSuccess(callback: { n in
////  print("n:", n)
////})
////f.onFailure(callback: { _ in
////  print("wtf")
////})
//
//while (true) {
//  print("X, lol=", lol)
//  print("f.result:", f.result)
//  sleep(1)
//}


//let wrapLogger: Middleware = { handler in
//  return { request in
//    print("Request coming in")
//    let response = handler(request: request)
//    print("Response going out")
//    return response
//  }
//}
//
//let wrapCurrUser: Middleware = { handler in
//  return { request in
//    return handler(request: request)
//  }
//}
//
//let handler: Handler = { request in
//  return Response.ok().setBody("Hello")
//}
//
//let server = Server(handler: handler)
//
//server.listen(3000)
