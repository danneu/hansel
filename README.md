
![Hansel](hansel.png)

# Hansel

[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)

Swift web-servers, so hot right now.

## Features

- [x] Streaming responses
- [x] `div("HTML templating", span("as Swift functions"))`
- [x] JSON support
- [x] Cookies
- [x] Static-file streaming
- [x] ETag and `304 Not Modified`
- [ ] Tests

## Example

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

// built-in templating example
func demoTemplate (ip: String) -> HtmlConvertible =
  div(
    h1("Welcome!"),
    p(["style": ["color": "red"]], 
      "Your IP address is: ", strong(ip)))

// a silly router for demonstration
let resource: Handler = { request in
  switch (request.method, request.path) {
  case (.Get, "/"): 
    return Response().html("<h1>Homepage</h1>")
  case (.Get, "/json"): 
    return try Response().json(["Hello": "world"])
  case (.Get, "/text"): 
    return Response().text("How are you?")
  case (.Get, "/html"):
    return Response().html(demoTemplate(request.ip))
  default: 
    return Response(.NotFound)
  }
}

Server(logger(handler)).listen(3000)
```

----

Hansel is an experimental Swift web-server that focuses on:

- **Simplicity**
- **Immutability**
- **Middleware as higher-order functions**

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

### Templating

Hansel comes with a minimal templating library that lets you build
HTML views with Swift code:

``` swift
func demoTemplate (ip: String) -> HtmlConvertible {
  div(
    // pass a dictionary as the first argument to any
    // element to set its attributes
    ["style": ["background-color": "#3498db",
               "color": "white",
               "width": "600px",
               "margin": "20px auto",
               "border": "5px solid black",
               "padding": "10px",
               "font-family": "Menlo"],
     "class": "demo-box"],
    h1("quick hansel templating demo"),
    hr(),
    "hello, ",
    "world",
    p("your ip address is: \(ip)"),
    // you can pass in child elements as an array
    ol(["apples", "bananas", "oranges"].map { li($0) }),
    // or not (up to 20 elements)
    ul(
      li("item a"),
      li("item b"),
      li("item c")
    ),
    p("everything is <script>alert('escaped')</script> by default"),
    p(.Safe("but you can <u><b>bypass</b></u> it") as SafeString),
    node("whatever", ["and you can create arbitrary html nodes"])
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
steep challenge. This is sheepishly the closest I've got to a clue:

    git clone git@github.com:danneu/hansel.git
    cd hansel
    pod install

Open `Hansel.xcworkspace` since apparently it's the file that CocoaPods makes,
so it's configured to load the installed pod dependencies.

Create `Sources/main.swift`:

``` swift
let handler: Handler = { _ in Response().text("Hello world") }
Server(handler).listen(3000)
```

Click Xcode's Run button:

![xcode controls](http://i.imgur.com/07ANAsO.png)

When the project builds successfully, you should see
"Listening on 3000" printing to Xcode's output console (bottom pane).

Navigate to <http://localhost:3000>.

----

I used to have `swift build && .build/debug/Hansel` working, but
then I added the CryptoSwift dependency which can't compile in its
latest version on latest Swift. ([issue](https://github.com/krzyzanowskim/CryptoSwift/issues/218)).

Fortunately CocoaPods lets you choose a git branch instead of just a 
repository, so I was able to pick a patched branch.

## Thanks

- Socket implementation from [glock45/swifter][swifter]
- Some socket glue code from [tannernelson/vapor][vapor]
- Some Linux fixes from [tannernelson/vapor][vapor]
- Some HTTP/RFC implementation ported from [jshttp]

[swifter]: https://github.com/glock45/swifter
[vapor]: https://github.com/tannernelson/vapor
[jshttp]: https://github.com/jshttp

## Disclaimer

I'm new to Swift and XCode

## TODO

- `swift build` works with PathKit in Package.swift, but even when launching
XCode with latest-swift (3.0-DEV), it can resolve `import PathKit`. However
cocoapods PathKit works in XCode, but not with `swift build`.
So that's why I have both. Sheesh.
- Figure out how to add protocol constraints to types so that middleware
can ensure that Request/Response implement dependency protocols. For example,
session middleware ensuring that the Request implements cookies.
