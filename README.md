
![Hansel](hansel.png)

# Hansel

Swift web-servers, so hot right now.

Manually tested on OSX 10.11 and Ubuntu 14.04.

## Features

- [x] Streaming responses
- [x] `div("HTML templating", span("as Swift functions"))`
- [x] JSON support with declarative decoding
- [x] Cookies
- [x] Static-file serving
- [x] ETag, Last-Modified, `304 Not Modified` support
- [x] Linux support
- [ ] Tests

## Quickstart

Install the latest snapshot of [Swift 3.0-DEVELOPMENT](https://swift.org/download)
and try this locally or on a Ubuntu VPS.

    mkdir HelloWorld
    cd HelloWorld

``` swift
// HelloWorld/Sources/main.swift
import Hansel

let handler: Handler = { request in 
  return Response().text("Hello world!")
}

Server(handler).listen()
```

``` swift
// HelloWorld/Package.swift
import PackageDescription
let package = Package(
  name: "HelloWorld",
  dependencies: [
    .Package(url: "https://github.com/danneu/hansel.git", majorVersion: 0)
  ]
)
```

    swift build; rm -rf Packages/*/Tests && swift build
    .build/debug/HelloWorld --port 3000

Server listening on 3000.

## Another Example

``` swift
import Hansel

// middleware example
let logger: Middleware = { handler in
  return { request in
    print("Request coming in")
    let response = try handler(request)
    print("Response going out")
    return response
  }
}

// built-in templating
func demoTemplate (ip: String) -> HtmlConvertible {
  return d.div(
    d.h1("Welcome!"),
    d.p(["style": ["color": "red"]], 
        "Your IP address is: ", d.strong(ip)))
}

// basic router
let router: Router = Node("/", [
  .Route(.Get, { req in
    return Response().text("Welcome to the homepage")
  }),
  .Node("/html", [
    .Route(.Get, { req in
      return Response().html(demoTemplate(req.ip))
    })
  ]),
  .Node("/json-encode", [
    .Route(.Get, { req in
     return try Response().json(["hello": 42])
    })
  ]),
  .Node("/json-decode", [
    .Route(.Post, { req in
      // decodes json {"uname": String, "password": String}} => (String, String)
      let decoder = JD.object2({ ($0, $1) },
        "uname" => JD.string, 
        "password" => JD.string)
      let (uname, password) = try request.json(decoder)
      // look up credentials ...
      return Response().text("You logged in as: \(uname)")
    })
  ])
])

// initialize a server by passing it a handler
Server(logger(router.handler())).listen()
```

----

Hansel is an experimental Swift web-server that focuses on:

- **Simplicity**
- **Immutability**
- **Middleware**

Your entire application is expressed as a function that
takes a `Request` and returns a `Response`, i.e. a `Handler`.

Inspired by Clojure's [ring](https://github.com/ring-clojure/ring), hansel
aims to make systems slower and easier to reason about by modeling
the request/response cycle as a succession of immutable transformations.

## Concepts

Hansel boils down to these concepts:

1. `Request` and `Response` are immutable structs
2. `Handler`s are functions `Request -> Response`
3. `Middleware` are higher-order functions `Handler -> Handler`

It's just functions.

``` swift
typealias Header = (String, String)

struct Request {
  let url: String
  let headers: [Header]
  let method: Method
  let body: [UInt8]
  // ...
}

struct Response {
  let status: Status
  let headers: [Header]
  let body: Payload // i.e. Streamable, ETaggable
  // ...
}

typealias Handler = (Request) throws -> Response
typealias Middleware = Handler -> Handler
```

Everything else in hansel is just convenience functions on top of that.

## Request & Response

The `Request` and `Response` are immutable structs. Their API lets you
chain together transformations.

Some random quick-start examples:

``` swift
Response()  //=> skeleton 200 response with empty body to build on top of
Response(status: .Ok, headers: [])
Response().text("Hello")                     //=> text/plain
Response().html("<h1>Hello</h1>")            //=> text/html
try Response().json(["favoriteNumber": 42])  //=> application/json
Response().stream(FileStream("./video.mp4"), "video/mp4")
Response(.NotFound)
Response(.NotFound).text("File not found :(")
```

``` swift
// GET http://example.com/users?sort=created {"foo": "bar"}
request.url                     //  "http://example.com/users?sort=created"
request.query                   // ["sort": "created"]
request.path                    // "/users"
request.method                  // Method.Get
try request.body.json()         // ["foo": "bar"]
try request.body.json(decoder)  //
try request.body.utf8()         // "{\"foo\":\"bar\"}"
request.headers                 // [("host", "example.com"), ...]
request.getHeader("host")       // "example.com"
request.getHeader("xxxxx")      // nil
request.setHeader("key", "val") //=> Request
```

``` swift
// these are all non-destructive transformations
let handler: Handler = { request in
  return Response()
    .text("Test")
    .setHeader("X-Example", "initial")
    .setHeader("X-Example", "overwritten")
    .appendHeader("Fruit", "apples")
    .appendHeader("Fruit", "oranges")
    .redirect("/users/hansel")
    .setCookie("lang", "es")
    .setCookie("session_id", { 
      value: "e08c5eff-96bf-4b97-b30b-c81335da563d",
      maxAge: 86400, // expires in 24 hours
    })
    // store data for downstream middleware/handlers to access
    .setStore("current_user", User(id: 42, uname: "hansel"))
    .tap { response in 
      // tap lets you chain together arbitrary transformations
      return conditon ? change(response) : response
    }
}
```

## Handler (Request → Response)

Your application is a function that takes a `Request` and returns a `Response`.

Because `Handler` is a typealias, these are equivalent:

``` swift
func handler (request: Request) -> Response {
  return Response().text("Hello world")
}

// Preferred
let handler: Handler { request in 
  return Response().text("Hello world")
}
```

## Middleware (Handler → Handler)

Middleware functions let you run logic before the request hits the handler
and after the response leaves the handler.

Because `Middleware` is a typealias, these are equivalent:

``` swift
func middleware (handler: (Request -> Response)) throws -> (Request -> Response) {
  return { request in
    let response = try handler(request)
    return response
  }
}

func middleware (handler: Handler) -> Handler {
  return { request in
    let response = try handler(request)
    return response
  }
}

// Preferred
let middleware: Middleware = { handler in
  return { request in
    let response = try handler(request)
    return response
  }
}
```

Since middleware are just functions, it's trivial to compose them:

``` swift
// `logger` will touch the request first and the response last
let middleware = compose(logger, cookieParser, loadCurrentUser)
// or use my composition operator (<<)
let middleware = logger << cookieParser << loadCurrentUser
Server(middleware(handler)).listen(3000)
```

## Batteries Included

I've started stubbing out some basic middleware and tools.

### JSON Decoder

- Implementation: [Sources/JD.swift](https://github.com/danneu/hansel/blob/master/Sources/JD.swift)
- Elm's [Json.Decode docs](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Json-Decode)

I really like @evancz's declarative decoder abstraction in [Elm][elm],
so I threw together a Swift impl thanks to @czechboy0's work on [Jay][jay],
the parser.

Hansel's `Decoder<T>` either decodes json into Swift value `T`
or it throws an error which gets converted into a `400 Bad Request` by
default.

It's all in Hansel's `JD` namespace.

``` swift
JD.decode(Decoder<T>, JsonValue) -> Result<ErrorString, T>
```

Some examples:

| JSON                                | Decoder             |     Result         
| ----------------------------------- |--------------------| ----------------------------------------|
| `"foo"`                           | `JD.string`                                                   |  `.Ok("foo")`   
| `42`                              | `JD.int`                                                      |  `.Ok(42)`     
| `[1, 2, 3, 4]`                    | `JD.array(JD.int)`                                            |  `.Ok([1, 2, 3])`   
| `["a", 2, "c", 4]`                | `JD.oneOf([JD.string, JD.int])`                               |  `.Ok(["a", 2, "c", 4])`
| <pre>{<br>  "status": 200,<br>  "headers": []<br>}</pre>  | `("status" => JD.int)`                                        |  `.Ok(200)`             
| `{"a": { "b": { "c": 42 }}}`      | `["a", "b", "c"] => JD.int`                                   |  `.Ok(42)`    
| `{"id": 42, "name": "amy"}`       | <pre>JD.object2(User.init,<br>  "id" => JD.int,<br>  "name" => JD.string)</pre>      |  `.Ok(User(42, "amy"))`
| `[null, "x", null]`               | `JD.array(JD.oneOf([JD.string, JD.null("x")]))`               |  `.Ok(["x", "x", "x"])`  

When reading the request json (`try request.json()`), you can pass in a `Decoder`.
If the decode fails, an error is thrown. If it's successful, the decoded
Swift value returns.

``` swift
let handler: Handler = { request in
  // decodes {"uname": String, "pass": String} into tuple (String, String)
  let decoder = JD.object2({ ($0, $1) }, "uname" => JD.string, "pass" => JD.string)
  let (uname, pass) = try req.json(decoder)
  // authenticate user ...
}
```

Here's a hansel application that expects you to send it a JSON array
of numbers (e.g. `[50, 25, 1]`) and it will respond with the sum
(e.g. `{ "sum": 76 }`):

``` swift
let handler: Handler = { request in 
  let nums = try request.json(JD.array(JD.int))
  let sum = nums.reduce(0, combine: +)
  return try Response().json(["sum": sum])
}
```

```
$ curl -H 'Content-Type: application/json' -d '[1, 2, 3]' http://localhost:3000
HTTP/1.1 200 OK
content-type: application/json
content-length: 9

{
  "sum": 6
}
```

### Templating

Hansel comes with a minimal templating library that lets you build
HTML views with Swift code:

``` swift
func demoTemplate (ip: String) -> HtmlConvertible {
  let attrs =
    ["style": ["background-color": "#3498db",
               "color": "white",
               "width": "600px",
               "margin": "20px auto",
               "border": "5px solid black",
               "padding": "10px",
               "font-family": "Menlo"],
     "class": "demo-box"]
  // pass a dictionary as the first argument to any
  // element to set its attributes
  return d.div(attrs,
    d.h1("quick hansel templating demo"),
    d.hr(),
    "hello, ",
    "world",
    d.p("your ip address is: \(ip)"),
    // you can pass in child elements as an array
    d.ol(["apples", "bananas", "oranges"].map { d.li($0) }),
    // or as variadic args (up to 20 elements)
    d.ul(
      d.li("item a"),
      d.li("item b"),
      d.li("item c")
    ),
    d.p("everything is <script>alert('escaped')</script> by default"),
    d.p(SafeString.Safe("but you can <u><b>bypass</b></u> it")),
    d.node("whatever", ["and you can create arbitrary html nodes"])
  )
}
```

![templating demo screenshot](http://i.imgur.com/3cXptdG.png)

### Development Logger (Middleware)

The logger middleware prints basic info about the request and response
to stdout. Good for development.

``` swift
let middleware = compose(
  Batteries.logger
)

Server(middleware(handler)).listen()
```

![logger screenshot](https://dl.dropboxusercontent.com/spa/quq37nq1583x0lf/_5c9x02w.png)

### Routing

I cobbled together a basic router that turns a tree into a handler.

The routing tree is implemented as a simple recursive enum:

``` swift
enum Router {
  case .Route (Method, Handler)
  case .Node (String, [Router])
  // The "M" (middleware) versions let you pass in an array of
  // middleware that will get applied if a downstream route matches
  case .RouteM (Method, [Middleware], Handler)
  case .NodeM (String, [Middleware], [Router])
}
```

Example:

``` swift
let router: Router = .Node("/", [
  .Route(.Get, homepageHandler),
  .NodeM("/admin", [ensureAdmin], [
    .Route(.Get, adminPanelHandler)
  ])
  .Node("/users", [
    .Route(.Get, listUsersHandler)
    .RouteM(.Post, [validateUser], createUserHandler)
    .NodeM("/:user", [loadUser], [
      .Route(.Get, showUserHandler)
    ])
  ])
])

Server(router.handler()).listen(3000)
```

I'd like to eventually develop a less string-heavy router.

#### URL Route Params

If a node has a parameter segment (Ex: `"/:username"`), then the param
appears in the `request.params` dictionary (`[String: String]`) which
you can access in downstream middleware and handlers.

``` swift
let router: Router = .Node("/", [
  .Node("/:a", [
    .Node("/:b", [
      .Node("/:c", [
        .Route(.Get, { try Response().json($0.params) })
      ])
    ])
  ])
])

Server(router.handler()).listen(3000)
```

Demo:

```
$ curl http://localhost:3000/apples/bananas/oranges
HTTP/1.1 200 OK
content-length: 42
content-type: application/json

{
    "a": "apples",
    "b": "bananas",
    "c": "oranges"
}
```

### Static File Serving (Middleware)

The `serveStatic` middleware checks the `request.path` against the directory
that you initialize the middleware with.

If the file does not exist, then the request continues downstream.

If the file does exist, then it returns a response that will stream
the file to the client.

``` swift
let middleware = compose(
  Batteries.serveStatic("Public")
)

let handler: Handler = { request in 
  return Response("No file was found")
}

Server(middleware(handler)).listen()
```

If we have a `Public` folder in our root with a file `Public/message.txt`,
then the responses would look like this:

```
$ http localhost:3000/foo
HTTP/1.1 404 Not Found

$ http localhost:3000/message.txt
HTTP/1.1 200 OK
content-length: 38
content-type: text/plain

This is a message from the file system

$ http localhost:3000/../passwords.txt
HTTP/1.1 403 Forbidden
```

### Cookies (Middleware)

Using this middleware will assoc `.cookies` (dictionary) and 
`.setCookie(k, v)` methods to the request and response.

- On the request, the cookie dictionary is just `[String: String]`
- On the response, the dictionary is `[String: ResponseCookie]` which is
a record that lets you configure response cookie settings like expiration
and http-only.

``` swift
let middleware = compose(
  Batteries.cookies
)

let handler: Handler = { request in 
  var count: Int

  if let viewsStr = request.cookies["views"], let views = Int(viewsStr) {
    return Response().text("Message: \(message)")
    count = views + 1
  } else {
    count = 1
  }

  return Response()
    .text("You have viewed this page \(count) times")
    .setCookie("views", String(count))

  // Or

  return Response()
    .text("You have viewed this page \(count) times")
    .setCookie("views", { 
      value: String(count),
      maxAge: 86400, // Expire in 24 hours
      // ... more options
    })
}

Server(middleware(handler)).listen()
```

### Content-Type Parser

**OSX-only:** Since the parser is regexp-heavy, NSRegularExpression is not
implemented on Linux, and I can't find an alternative impl that works with 
moderately-complex regexps, the content-type parser is disabled on Linux.

`ContentType.swift` implements a Content-Type header parser according to
RFC 7231.

``` swift
try! ContentType.parse("image/svg+xml; charset=utf-8; foo=\"bar\"")
//=> ContentType( type: "image/svg+xml", params: ["charset": "utf-8", "foo": "bar"])
```

`ContentType` structs can serialize back into strings for use in the
Content-Type header:

``` swift
let type = try! ContentType.parse("image/svg+xml; charset=utf-8; foo=\"bar\"")
type.format() //=> "image/svg+xml; charset=utf-8; foo=bar"
```

### ETag

**Note**: ETagging will not work until the stable version of CryptoSwift
works with the lastest Swift ([issue](https://github.com/krzyzanowskim/CryptoSwift/issues/217)). For now, md5 hashes always return `"aaaaaaaaaaaaaaaa"`.

`ETag.swift` contains an ETag generator that can be called on anything
that conforms to the `ETaggable` protocol.

``` swift
// Strings
ETag.generate(bytes) //=> "\"3-rL0Y20zC+Fzt72VPzMSk2A\""

// Bytes
let bytes: [UInt8] = Array("foo".utf8)
ETag.generate("foo") //=> "\"3-rL0Y20zC+Fzt72VPzMSk2A\""

// Streams
ETag.generate(FileStream("./video.mp4", ...))
```

ETags are generated for streams are based on data gathered from `stat`'ing
the filesystem.

## Custom Response Body

A `response.body` conforms to the `Payload` protocol which involves 
implementing just a few methods from a couple protocols:

``` swift
protocol Streamable {
  mutating func next () -> [UInt8]?
  func open () -> Void
  func close () -> Void
  var length: Int? { get }
}

protocol ETaggable {
  func etag () -> String
}
```

Hansel comes with these `Payload` implementations:

- `String`
- `ByteArray` (struct wrapper around `[UInt8]` so that it can conform)
- Hansel's `FileStream` struct that represents a file path that will
get streamed to the client.

## Seconds & Milliseconds Utility

In HTTP, some things are expressed in seconds (cookie max-age) and
some things are expressed in milliseconds (cache-control max-age).
It's easy to get this wrong, and it's hard to notice it when you do.

Hansel uses type-safety to prevent these errors with these structs:

- `Milliseconds(Int)`
- `Seconds(Int)`

Functions that need to distinguish between them (like the cookie and
serve-static middleware) just require you to provide an instance of one
or the other.

They also offer far more readable conversions over the
ol `1000 * 60 * 60 * 24 * 7 * 2` chain:

``` swift
Seconds(days: 365)      // Seconds(31536000)
Milliseconds(weeks: 2)  // Milliseconds(1209600000)
```

Full list: `init(ms: Int)`, `secs:`, `mins:`, `hrs:`, `days:`, `weeks:`, `months:`

## Development (OSX)

Figuring out how to use Xcode and package my project has been a 
steep challenge. 

This is sheepishly the closest I've got to a clue:

    git clone git@github.com:danneu/hansel.git
    cd hansel
    swift build

Edit `Sources/HanselDev/main.swift`:

``` swift
// Sources/HanselDev/main.swift
let handler: Handler = { _ in Response().text("Hello world") }
Server(handler).listen(3000)
```

Run the development `main.swift`:

```
swift build
.build/debug/HanselDev
```

Navigate to <http://localhost:3000>.

## Thanks

- Socket implementation from [glock45/swifter][swifter]
- Some socket glue code from [qutheory/vapor][vapor]
- Linux fixes from [qutheory/vapor][vapor] and [johnno1962/NSLinux][nslinux]
- Some HTTP/RFC implementation ported from [jshttp]
- @czechboy0's [blog post](https://honzadvorsky.com/articles/2016-02-25-14-00-3_steps_to_marry_xcode_with_swift_package_manager/) on how to use SPM + Xcode

[swifter]: https://github.com/glock45/swifter
[vapor]: https://github.com/qutheory/vapor
[jshttp]: https://github.com/jshttp
[elm]: http://elm-lang.org/
[evancz]: https://github.com/evancz
[jay]: https://github.com/czechboy0/Jay
[nslinux]: https://github.com/johnno1962/NSLinux

## Disclaimer

I'm new to Swift and XCode
