
import Hansel
import Jay

let middleware: Middleware = compose(
  Batteries.logger,
  Batteries.removeTrailingSlash,
  Batteries.notModified(etag: true),
  Batteries.serveStatic("/Users/danneu/Code/Swift/Hansel/Public")
)

struct Message: JsonEncodable {
  let id: Int
  let uname: String
  let text: String

  init (_ id: Int, _ uname: String, _ text: String) {
    self.id = id
    self.uname = uname
    self.text = text
  }

  static let decoder: Decoder<Message> =
    JD.object3(
      Message.init,
      "id" => JD.int,
      ["user", "uname"] => JD.string,
      "text" => JD.string
    )

  func json () -> JsonValue {
    return .Object(
      ["id": .Number(.JsonInt(id)),
       "user": .Object(["uname": .String(uname)]),
       "text": .String(text)])
  }
}

//let handler: Handler = { req in
//  let msg = try req.json(Message.decoder)
//  print("msg", msg)
//  return try Response().json(msg)
//}

//let handler: Handler = { req in
//  let nums = try req.json(JD.array(JD.int))
//  let sum = nums.reduce(0, combine: +)
//  return try Response().json(["sum": sum])
//}

let handler: Handler = { req in
  return Response().text("ok")
  //Response().html(d.p("Hello world"))
  //let charset = req.charset ?? "--"
  //return Response().html(p("charset: \(charset)"))
}

let root: Handler = middleware(handler)

Server(root).listen(4001)
