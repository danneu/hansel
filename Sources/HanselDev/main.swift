
import Hansel

let middleware: Middleware = compose(
  Batteries.logger,
  Batteries.removeTrailingSlash,
  Batteries.notModified(etag: false)
)

func demoTemplate (ip: String) -> HtmlConvertible {
  return d.div(
    d.h1("Welcome!"),
    d.p(["style": ["color": "red"]],
        "Your IP address is: ", d.strong(ip)))
}

let router: Router = .Node("/", [
  // curl http://localhost:4000
  .Route(.Get, { req in
    return Response().text("Welcome to the homepage")
  }),
  // curl http://localhost:4000/html
  .Node("/html", [
    .Route(.Get, { req in
      return Response().html(demoTemplate(req.ip))
    })
  ]),
  // curl http://localhost:4000/json-encode
  .Node("/json-encode", [
    .Route(.Get, { req in
     return try Response().json(["hello": 42])
    })
  ]),
  // curl -H 'Content-Type: application/json' -d '{"uname":"chuck","password":"secret"}' http://localhost:4000/json-decode
  .Node("/json-decode", [
    .Route(.Post, { req in
      // decodes json {"uname": String, "password": String} => (String, String)
      let decoder = JD.object2({ ($0, $1) }, "uname" => JD.string, "password" => JD.string)
      let (uname, password) = try req.json(decoder)
      // TODO: look up credentials...
      return Response().text("You logged in as \(uname)")
    })
  ]),
  // curl -H 'Content-Type: application/json' -d '[1, 2, 3]' http://localhost:4000/json-sum
  .Node("/json-sum", [
    .Route(.Post, { req in
      let nums = try req.json(JD.array(JD.int))
      let sum = nums.reduce(0, combine: +)
      return try Response().json(["sum": sum])
    })
  ])
])

let rootHandler: Handler = middleware(router.handler())

Server(rootHandler).listen(4000)

