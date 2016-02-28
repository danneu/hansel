
*Disclaimer: I'm new to Swift and XCode*

# Hansel

Swift web-servers, so hot right now.

``` swift
import Hansel

let logger: Middleware = { handler in
  return { request in
    print("Request coming in")
    let response = handler(request)
    print("Response going out")
    return response
  }
}

let handler: Handler = { request in
  return Response().text("Hello world")
}

Server(logger(handler)).listen(3000)
```

Hansel is an experimental Swift web-server that focuses on:

- **Simplicity**
- **Immutability**
- **Middleware as higher-order functions**

Your entire application is expressed as a function that
takes a `Request` and returns a `Response`, i.e. a `Handler`.

Inspired by Clojure's [ring](https://github.com/ring-clojure/ring), hansel
aims to make systems slower and easier to reason about by modeling
the request/response cycle as a succession of immutable transformations.

What makes Ring so pleasant is (1) Clojure's immutable-by-default API for
transforming maps and (2) middleware aren't special constructs, just
functions.

``` clojure
(require '[[ring.util.response :refer [response status header]]])

(defn handler [request]
  (-> response
      (assoc :body "<h1>Hello world</h1>")
      (header "X-Test", "foo")
      (status 418)))

(def app (-> handler logger (serve-static "./public")))
```

In Swift, I find that chainable, non-destructive methods recreate most
of the pleasure. And it's statically-typed.

``` swift
import Hansel

let handler: Handler = { request in
  return Response()
    .html('<h1>Hello world</h1>')
    .setHeader('X-Test', 'foo')
    .setStatus(.ImATeapot)
}

let app: Handler = handler |> logger << serveStatic("./Public")
```

## Concepts

Hansel boils down to these concepts:

1. `Request` and `Response` are immutable structs
2. `Handler`s are functions `Request -> Response`
3. `Middleware` are higher-order functions `Handler -> Handler`

It's just functions.

In fact, here are the type signatures:

``` swift
enum Status: Int {
  case Ok = 200
  case NotFound = 404
  case Error = 500
  // ...
}

enum Method: String {
  case Get = "GET"
  case Post = "POST"
  // ...
}

typealias Header = (String, String)

struct Request {
  let url: String
  let headers: [Header]
  let method: Method
  // ...
}

struct Response {
  let status: Status
  let headers: [Header]
  let body: String
  // ...
}

typealias Handler = Request -> Response
typealias Middleware = Handler -> Handler
```

Everything else in hansel is just convenience functions on top of that.

## Request & Response

The `Request` and `Response` are immutable structs. Their API lets you
chain together transformations.

Some initializer examples:

``` swift
Response()  //=> skeleton 200 response with empty body to build on top of
Response(status: .Ok, headers: [], body: .Text("Hello"))
Response().text("Hello")           //=> text/plain
Response().html("<h1>Hello</h1>")  //=> text/html
Response(.NotFound)
Response(.NotFound).text("File not found :(")
```

Pretty scatterbrained.

### Reading/Writing Headers

``` swift
public typealias Header = (String, String)
```

Headers are represented as string tuples to model the fact that
duplicate headers can exist (like when setting multiple cookies) and
for eventual integration with the [Nest protocol][nest].

The Request and Response conform to my [HeaderList protocol][headerlist]
which implements methods for reading and updating headers:

``` swift
public typealias Header = (String, String)

protocol HeaderList {
  var headers: [Header] { get set }
  func getHeader (key: String) -> String?
  func setHeader (key: String, val: String?) -> Self
  func deleteHeader (key: String) -> Self
  func appendHeader (key: String, val: String) -> Self
  func updateHeader (key: String, fn: String? -> String?) -> Self
}
```

- `getHeader(key)` returns the first matching header.
- `deleteHeader(key)` deletes all headers with that key.
- `setHeader(key, val)` deletes all the headers of that key and then sets the
header.
- `updateHeader(key, fn(val -> val))` updates the first matching header and
deletes the rest.
- `appendHeader(key, val)` appends a header to the array.

[headerlist]: https://github.com/danneu/hansel/blob/19a2012d109ab05eebc4f9362d9d18276b038210/Sources/Protocol.swift#L10-L19
[nest]: https://github.com/nestproject/Nest/blob/master/Specification.md

Example:

``` swift
let handler: Handler = { request in
  return Response()
    .text("Test")
    .setHeader("X-Example", "initial")
    .setHeader("X-Example", "overwritten")
    .appendHeader("Set-Cookie", "hello=world")
    .appendHeader("Set-Cookie", "goodbye=world")
}
```

Produces this Response:

```
HTTP/1.1 200 OK
X-Example: overwritten
Set-Cookie: hello=world
Set-Cookie: goodbye=world
Content-Length: 4

Test
```

### Storage

Request and Response also implement my [Storable protocol][storable] which
gives handlers and middleware a dictionary to store arbitrary data.

``` swift
typealias Store = [String: Any]

protocol Storable {
  var store: Store { get set }
  func getStore (key: String) -> Any?
  func setStore (key: String, val: Any) -> Self
  func updateStore (key: String, fn: Any -> Any) -> Self
}
```

My idea so far is that middleware can use `request.store` and `response.store`
as generic data slots, and then extend Request and Respond with helper 
methods that read/manipulate data in those slots.

For example, this is how the Cookie.swift middleware is implemented:

``` swift
extension Response {
  var cookies: [String: ResponseCookie] {
    if let value = self.getStore("cookies") as? [String: ResponseCookie] {
      return value
    } else {
      return [:]
    }
  }

  func setCookie (key: String, value: String) -> Response {
    return self.setCookie(key, opts: ResponseCookie(key, value: value))
  }

  func setCookie (key: String, opts: ResponseCookie) -> Response {
    return self.updateStore("cookies") { cookies in
      if var dict = cookies as? [String: ResponseCookie] {
        dict[key] = opts
        return dict
      } else {
        return [key: opts]
      }
    }
  }
}
```

That way, cookie middleware exposes cookie features as just
wrappers around the store:

- response.cookies: [String: String]
- response.setCookie: (String, ResponseCookie) -> Response

Without the end-user having to manipulate the store directly.

Another example is authentication middleware that
attaches `request.currentUser: User?` to every request so that downstream
middleware and handlers can access the current logged-in user:

``` swift
struct User {
  var id: Int
  var uname: String
}

protocol HasCurrentUser {
  var currentUser: User? { get set }
}

extension Request: HasCurrentUser {
  var currentUser: User? {
    get { 
      return self.store["current_user"] as! User
    }
    set (user) {
      self.setStore("current_user", user)
    }
  }
}

let wrapCurrentUser: Middleware = { handler in
  return { request in
    let sessionId: String? = request.cookies["session_id"]
    if sessionId == nil { return handler(request) }
    let user: User? = database.getUserBySessionId(sessionId!)
    if user == nil { return handler(request) }
    return handler(request.setCurrentUser(user))
  }
}
```

[storable]: https://github.com/danneu/hansel/blob/19a2012d109ab05eebc4f9362d9d18276b038210/Sources/Protocol.swift#L57-L64

## Handler (Request -> Response)

Because `Handler` is a typealias, these are equivalent:

``` swift
func handler (request: Request) -> Response {
  return Response().text("Hello world")
}

// Preferred
let handler: Handler { request in 
  Response().text("Hello world")
}
```

## Middleware (Handler -> Handler)

Middleware functions let you run logic before the request hits the handler
and after the response leaves the handler.

Because `Middleware` is a typealias, these are equivalent:

``` swift
func middleware (handler: (Request -> Response)) -> (Request -> Response) {
  return { request in
    let response = handler(request)
    return response
  }
}

func middleware (handler: Handler) -> Handler {
  return { request in
    let response = handler(request)
    return response
  }
}

// Preferred
let middleware: Middleware = { handler in
  return { request in
    let response = handler(request)
    return response
  }
}
```

Since middleware are just functions, it's trivial to compose them:

``` swift
// f << g :: f(g(x))
infix operator << { associativity left }
public func << <A, B, C>(f: B -> C, g: A -> B) -> A -> C {
  return { x in f(g(x)) }
}

// `logger` will touch the request first and the response last
let middleware = logger << cookieParser << loadCurrentUser
Server(middleware(handler)).listen(3000)
```

Though hansel exposes a global `compose` function:

``` swift
let middleware = compose(logger, cookieParser, loadCurrentUser)
Server(middleware(handler)).listen(3000)
```

## Batteries Included

I've started stubbing out some basic middleware and tools.

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
  case .Node (String, [Middleware], [Router])
}
```

Example:

``` swift
let router: Router = .Node("/", [logger, cookieParser], [
  .Route(.Get, homepageHandler),
  .Node("/admin", [ensureAdmin], [
    .Route(.Get, adminPanelHandler)
  ])
  .Node("/users", [], [
    .Route(.Get, listUsersHandler)
    .Route(.Post, createUserHandler)
    .Node("/:user", [loadUser], [ // doesn't actually parse params yet
      .Route(.Get, showUserHandler)
    ])
  ])
])

Server(router.handler()).listen(3000)
```

### Static File Serving (Middleware)

Stubbed out some basic static asset serving middleware that stats the
file system and serves the file if there is one. Else the request continues
down the chain.

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

I have a basic ETag generator in `ETag.swift` that works on byte arrays.

``` swift
let bytes: [UInt8] = Array("foo".utf8)

ETag.generate(bytes) //=> "\"3-rL0Y20zC+Fzt72VPzMSk2A\""
```

**TODO:** Once I figure out a streaming abstraction, the ETag generator
will be extended to create weak ETags based on fs `stat`
data (mtime and size).

## Default Middleware

When you give hansel your final handler function, it wraps it with 
some of its own outer middleware:

- **HEAD request handling**

## Thanks

- Socket implementation from [glock45/swifter][swifter]
- Some socket glue code from [tannernelson/vapor][vapor]
- Some HTTP/RFC implementation ported from [jshttp]

[swifter]: https://github.com/glock45/swifter
[vapor]: https://github.com/tannernelson/vapor
[jshttp]: https://github.com/jshttp

## TODO

- Lock PathKit to minorVersion 6 in Package.swift
- `swift build` works with PathKit in Package.swift, but even when launching
XCode with latest-swift (3.0-DEV), it can resolve `import PathKit`. However
cocoapods PathKit works in XCode, but not with `swift build`.
So that's why I have both. Sheesh.
- Some libs to look at:
    - https://github.com/krzyzanowskim/CryptoSwift
    - https://github.com/czechboy0/Jay
- Figure out how to add protocol constraints to types so that middleware
can ensure that Request/Response implement dependency protocols. For example,
session middleware ensuring that the Request implements cookies.
