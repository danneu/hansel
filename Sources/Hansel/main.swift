
import Foundation
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







//let n: JsonValue = .Number(.JsonInt(42))
//let strDecoder: Decoder<String> = JD.string
//let intDecoder: Decoder<Int> = JD.int
//let intArrayDecoder = JD.array(JD.int)
//let dictDecoder = JD.dict(JD.int)
////print(decodeValue(dictDecoder, value: .Object(["a": n, "b": n, "c": n])))
//
//struct User {
//  var uname: String
//  var age: Int?
//  init (_ uname: String, _ age: Int?) { self.uname = uname; self.age = age}
//}
//let objVal: JsonValue = .Object(["uname": .String("dan"), "age": .Number(.JsonInt(27))])
//let objDecoder =
//  JD.object2(
//    { (uname: String, age: Int) -> User in User(uname, age) },
//    ("uname" => JD.string),
//    ("age" => JD.int))
//print(decodeValue(objDecoder,value: objVal))
//
//print("=== JD.at ====")
//let nestObjVal: JsonValue = .Object(
//  ["a": .Object(
//    ["b": .Object(
//      ["c": .Null])])])
//let nestObjDecoder =
//  JD.at(["a", "b", "c"], JD.null(":D"))
//print(decodeValue(nestObjDecoder,value: nestObjVal))
//
//let optObjVal: JsonValue = .Object(["uname": .String("dan"), "age": .Null])
//let optObjDecoder =
//  JD.object2(
//    { User($0, $1) },
//    ("uname" => JD.string),
//    JD.optional("age" => JD.int)
//  )
//print(decodeValue(optObjDecoder,value: optObjVal))
//
//// oneOf
//let oneOfV: JsonValue = .Array([.String("one"), .Number(.JsonInt(2)), .String("three")])
//let oneOfD =
//  JD.array(JD.oneOf([JD.string, JD.object1(String.init, JD.int)]))
//print(decodeValue(oneOfD,value: oneOfV))
//
//let mapV: JsonValue = .Array([.String("one"), .Number(.JsonInt(2)), .String("three")])
//let mapD =
//  JD.array(JD.oneOf([JD.string, JD.map(String.init, JD.int)]))
//print(decodeValue(mapD,value: mapV))
//
//let mapVErr: JsonValue = .Array([.String("one"), .Number(.JsonInt(2)), .Array([])])
//let mapDErr =
//  JD.array(JD.oneOf([JD.string, JD.map(String.init, JD.int)]))
//print(decodeValue(mapDErr,value: mapVErr))
//
//// fail
//let failV: JsonValue = .String("foo")
//let failD = JD.fail("this was destined to fail")
//print(decodeValue(failD,value: failV))
//
//// succeed
//let succeedV: JsonValue = .String("foo")
//let succeedD = JD.succeed(42)
//print(decodeValue(succeedD ,value: succeedV))
//
////andThen
//let andThenV: JsonValue = .Object(["tag": .String("int"), "val": .Number(.JsonInt(42))])
//let andThenD = JD.andThen(
//  "tag" => JD.string,
//  { $0 == "int" ? JD.succeed("INTTTT") : JD.succeed("NVM") }
//)
//print(decodeValue(andThenD ,value: andThenV))
//
//
//// tuple1
//print(decodeValue(JD.tuple1(String.init, JD.int),
//                  value: .Array([.Number(.JsonInt(99))])))
//print(decodeValue(JD.tuple1({ $0 }, JD.string),
//                  value: .Array([.Number(.JsonInt(99))])))
//print(decodeValue(JD.tuple1({ $0 }, JD.string),
//                  value: .Array([.Null, .Null])))


///////////////////////////////////////////////

// print(decodeValue(intArrayDecoder, value: .Array([v, v, v])))

//
//HttpClient.get("http://localhost:3333") { result in
//  guard case let .Ok(response) = result else {
//    return print("Err")
//  }
//  print(response)
////  var response: Response?
////  switch result {
////  case .Err (let msg):
////    print("Err: \(msg)")
////    return
////  case .Ok (let res):
////    response = res
////    print("Ok: \(res)")
////  }
////  print("[cb] response:", response!)
//}


//////////////////////////////////////////////////////////////////

//
//
//
//func mw (name: String) -> Middleware {
//  return { handler in
//    return { request in
//      print("[\(name)] enter")
//      let response = handler(request)
//      print("[\(name)] exit")
//      return response
//    }
//  }
//}
//
//func handle (body: String) -> Handler {
//  return { request in
//    return Response().text(":)")
//  }
//}
//
//let ensureAdmin: Middleware = { handler in
//  return { request in
//    print("[ensureAdmin]")
//    return Response(.Forbidden)
//  }
//}
//
//let router: Router = .Node("/", [], [
//  .Route(.Get, handle("1homepage")),
//  .Node("/users", [mw("B1"), mw("B2")], [
//    .Route(.Get, handle("listUsers")),
//    .Route(.Post, handle("createUser")),
//    .Node("/admin", [ensureAdmin], [
//      .Route(.Get, handle("admin panel"))
//      ]),
//    .Node("/test", [mw("C")], [
//      .Route(.Get, handle("nested"))
//      ])
//    ])
//  ])
//
//
//
////let etag: Middleware = { handler in
////  return { request in
////    let response = handler(request)
////    var tag: String?
////    switch response.body {
////    case .Text(let str): tag = ETag.generate(str)
////    default: break
////    }
////
////    return response
////      .setHeader("ETag", tag)
////  }
////}
//
//let middleware = compose(
//  Batteries.logger,
//  Batteries.head,
//  Batteries.serveStatic("Public"),
//  Batteries.cookies,
//  mw("1"),
//  mw("2"),
//  mw("3")
//)
//
//var rootHandler = middleware(router.handler())
//
//let handler: Handler = { request in
//  return Response()
//    .html("<h1>Hello world</h1>")
//    .setHeader("X-Test", "foo")
//}
//
//
//
//rootHandler = { request in
//  switch (request.method, request.path) {
//  case (.Get, "/"):
//    return Response().html("<h1>Homepage</h1>")
//  case (.Get, "/uploads"):
//    return Response().html("TODO: List uploads")
//  case (.Post, "/uploads"):
//    // middleware composition
//    return Batteries.logger << Batteries.head
//      <| { _ in Response().redirect("/uploads") }
//      <| request
//  default:
//    return Response(.NotFound)
//  }
//}
//
//
//
//rootHandler = { request in
//  return Response()
//    .text("ip: \(request.ip), query: \(request.query.description)")
//    .json(["Hello": "World"])
//}
//
//func demoTemplate (ip: String) -> HtmlConvertible {
//  return div(
//    // pass a dictionary as the first argument to any
//    // element to set its attributes
//    ["style": ["background-color": "#3498db",
//               "color": "white",
//               "width": "600px",
//               "margin": "20px auto",
//               "border": "5px solid black",
//               "padding": "10px",
//               "font-family": "Menlo"],
//     "class": "demo-box"],
//    h1(["style": ["text-align": "center"]],
//       "quick hansel templating demo"),
//    hr(),
//    "hello, ",
//    "world",
//    p("your ip address is: \(ip)"),
//    // you can pass in child elements as an array
//    ol(["apples", "bananas", "oranges"].map { li($0) }),
//    // or not (up to 10 elements)
//    ul(
//      li("item a"),
//      li("item b"),
//      li("item c")
//    ),
//    p("everything is <script>alert('escaped')</script> by default"),
//    p(.Safe("but you can <u><b>bypass</b></u> it") as SafeString)
//    ,node("whatever", ["and you can create arbitrary nodes"])
//  )
//}
//
//rootHandler = { request in
//  return Response().html(demoTemplate(request.ip))
//}
//
//
////Server(rootHandler).listen(4001)
////
////class Element {
////  var tagName: String { get }
////  init () {
////
////  }
////}
//
//
////struct H1: Element { var tagName: String { return "h1" }  }
//
//
//





// LAYMAN'S TEMPLATING TESTS
// https://github.com/weavejester/hiccup/blob/master/test/hiccup/test/core.clj)
//

// TAG CONTENTS 

//print(div().html() == "<div></div>")
//print(video().html() == "<video></video>")
//// void elements
//print(br().html() == "<br>")
//print(br(["id": "foo"]).html() == "<br id=\"foo\">")
//// containing text
//print(textarea("lorem ipsum").html() == "<textarea>lorem ipsum</textarea>")
//// contents are concatenated
//print(body("foo", "bar").html() == "<body>foobar</body>")
//// tags can contain tags
//print(body(p(), br()).html() == "<body><p></p><br></body>")
//print(p(span(a("foo"))).html() == "<p><span><a>foo</a></span></p>")
//// handles arrays
//print(body([br(), br()]).html() == "<body><br><br></body>")
//
//// TAG ATTRIBUTES
//
//// empty attrs
//print(div([:]).html() == "<div></div>")
//// populated attrs
//print(div(["a": "1", "b": "2"]).html() == "<div b=\"2\" a=\"1\"></div>")
//// attr values are escaped
//print(div(["id": "\""]).html())

