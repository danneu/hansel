
![Hansel](hansel.png)

# Hansel [![Build Status](https://travis-ci.org/danneu/hansel.svg?branch=master)](https://travis-ci.org/danneu/hansel) ![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20OS%20X-blue.svg) ![Package Managers](https://img.shields.io/badge/package%20managers-swiftpm-yellow.svg) 

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

Install the latest snapshot of [Swift 3.0](https://swift.org/download)
and try this locally or on a Ubuntu VPS.

I had to install these deps on Ubuntu:

    sudo apt-get install clang libicu-dev binutils git libcurl4-openssl-dev libpython2.7

Then make a folder for the application:

    mkdir HelloWorld
    cd HelloWorld

It'll look like this:

    .
    ├── Package.swift
    └── Sources
        └── main.swift

Here's the contents of those two files:

``` swift
// HelloWorld/Sources/main.swift
import Hansel

let handler: Handler = { request in 
  return Response().html(
    d.div(
      d.h1("Hello world"),
      d.p("Your IP address is: \(request.ip)")))
}

Server(Batteries.logger(handler)).listen()
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

    swift build
    .build/debug/HelloWorld --port 3000

Server listening on 3000.

## Why?

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

## Request & Response

The `Request` and `Response` are immutable structs. Their API lets you
chain together transformations.

Example usage junkdrawer:

``` swift
Response()  //=> skeleton 200 response with empty body to build on top of
Response(status: .ok, headers: [])
Response().text("Hello")                     //=> text/plain
Response().html("<h1>Hello</h1>")            //=> text/html
try Response().json(["favoriteNumber": 42])  //=> application/json
Response().stream(FileStream("./video.mp4"), "video/mp4")
Response(.notFound)
Response(.notFound).text("File not found :(")
```

``` swift
// GET http://example.com/users?sort=created {"foo": "bar"}
request.url                     //  "http://example.com/users?sort=created"
request.query                   // ["sort": "created"]
request.path                    // "/users"
request.method                  // Method.get
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

``` swift
typealias Handler = (Request) throws -> Response
```

Your application is a function that takes a `Request` and returns a `Response`.

``` swift
let handler: Handler { request in 
  return Response().text("Hello world")
}

Server(handler).listen()
```

## Middleware (Handler → Handler)

``` swift
typealias Middleware = Handler -> Handler
```

Middleware functions let you run logic before the request hits the handler
and after the response leaves the handler.

``` swift
let logger: Middleware = { handler in
  return { request in
    print("Request coming in")
    let response = try handler(request)
    print("Response going out")
    return response
  }
}

Server(logger(handler)).listen()
```

Since middleware are just functions, it's trivial to compose them:

``` swift
// `logger` will touch the request first and the response last
let middleware = compose(logger, cookieParser, loadCurrentUser)
// or use my composition operator (<<)
let middleware = logger << cookieParser << loadCurrentUser
Server(middleware(handler)).listen(3000)
```

## JSON

### Sending JSON

Just pass a dictionary into `response.json()`:

``` swift
let handler: Handler = { request in
  return Response().json([
    "id": 42,
    "uname": "Murphy"
  ])
}
```

### JSON Decoder

- More: https://github.com/danneu/hansel/wiki/JSON-Decoder

Hansel comes with a declarative JSON decoder built on top of
**@czechboy0**'s [Jay][jay] JSON parser.

This handler parses the request's JSON body as an array of integers
and responds with the sum:

``` swift
// example request payload: [1, 2, 3]
let handler: Handler = { request in
  let nums = try request.json(JD.array(JD.int))
  let sum = nums.reduce(0, combine: +)
  return Response().json(["sum": sum])
}
```

This authentication handler parses the username/password combo from
the request's JSON body:

``` swift
// example request payload: {"user": {"uname": "chuck"}, "password": "secret"}
let handler: Handler = { request in
  let decoder = JD.tuple2(
    ["user", "uname"] => JD.string, // easy nested access
    "password" => JD.string
  )
  let (uname, password) = try request.json(decoder)
  // authenticate user ...
  return Response().json(["success": ["uname": uname]])
}
```

## HTML Templating

Hansel comes with a minimal templating library that lets you build
HTML views with Swift code:

``` swift
func demoTemplate (ip: String) -> HtmlConvertible {
  // pass a dictionary as the first argument to any
  // element to set its attributes
  return d.div(["class": "demo-box",
                "style": ["border": "5px solid black"]],
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

## Routing

I cobbled together a basic router that turns a tree into a handler.

The routing tree is implemented as a simple recursive enum:

``` swift
enum Router {
  case .route (Method, Handler)
  case .node (String, [Router])
  // The "M" (middleware) versions let you pass in an array of
  // middleware that will get applied if a downstream route matches
  case .routeM (Method, [Middleware], Handler)
  case .nodeM (String, [Middleware], [Router])
}
```

Example:

``` swift
let router: Router = .node("/", [
  .route(.Get, homepageHandler),
  .nodeM("/admin", [ensureAdmin], [
    .route(.Get, adminPanelHandler)
  ])
  .node("/users", [
    .route(.Get, listUsersHandler)
    .routeM(.Post, [validateUser], createUserHandler)
    .nodeM("/:user", [loadUser], [
      .route(.Get, showUserHandler)
    ])
  ])
])

Server(router.handler()).listen(3000)
```

Yeah, it's pretty lame but I quickly hacked it together since there's
so much else to be working on.

I'd like to eventually develop a less string-heavy router.

### URL Route Params

If a node has a parameter segment (Ex: `"/:username"`), then the param
appears in the `request.params` dictionary (`[String: String]`) which
you can access in downstream middleware and handlers.

``` swift
let router: Router = .node("/", [
  .node("/:a", [
    .node("/:b", [
      .node("/:c", [
        .route(.Get, { try Response().json($0.params) })
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

## Development Logger (Middleware)

The logger middleware prints basic info about the request and response
to stdout. Good for development.

``` swift
let middleware = compose(
  Batteries.logger
)

Server(middleware(handler)).listen()
```

![logger screenshot](https://dl.dropboxusercontent.com/spa/quq37nq1583x0lf/_5c9x02w.png)

## Static File Serving (Middleware)

The `serveStatic` middleware checks the `request.path` against the directory
that you initialize the middleware with.

``` swift
let middleware = compose(
  Batteries.serveStatic("./Public")
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

## Cookies (Middleware)

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
    count = views + 1
  } else {
    count = 1
  }

  return Response()
    .text("You have viewed this page \(count) times")
    .setCookie("views", String(count))
}

Server(middleware(handler)).listen()
```

### Content-Type Parser

**Temporarily disableld:** Since the parser is regexp-heavy, NSRegularExpression is not
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

**Temporarily disabled**: ETagging will not work until the stable version of CryptoSwift
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

A `response.body` conforms to the `ResponseBody` protocol which involves 
implementing just a few methods from a couple protocols:

``` swift
protocol ResponseBody: Streamable, ETaggable {}

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

Hansel comes with these `ResponseBody` implementations:

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
steep challenge, but I think I've finally arrived at some sanity.
Update: Especially since the recent improvements in Swift's package
manager since I started working on this project.

    git clone git@github.com:danneu/hansel.git
    cd hansel
    swift build

`Sources/HanselDev/main.swift` is a coding sandbox (Note: currently
missing while I try to rearrange the files without Xcode throwing errors).
It comes populated with a small application.
Just edit it, rebuild, and relaunch:

```
swift build && .build/debug/HanselDev --port 3000
```

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
