
*Disclaimer: I started building this yesterday to learn Swift. 
I don't have much experience with statically-typed languages.*

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
- **Middleware**

Your entire application is expressed as a function that
takes a `Request` and returns a `Response`, i.e. a `Handler`.

Inspired by Clojure's [ring](https://github.com/ring-clojure/ring), hansel
aims to make systems slower and easier to reason about by modeling
the request/response cycle as a succession of transformations.

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
// f << g :: g(f(x))
infix operator << { associativity left }
public func << <A, B, C>(f: A -> B, g: B -> C) -> A -> C {
  return { x in g(f(x)) }
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

## Default Middleware

When you give hansel your final handler function, it wraps it with 
some of its own outer middleware:

- **HEAD request handling**

## Thanks

- Socket implementation from [glock45/swifter][swifter]
- Some socket glue code from [tannernelson/vapor][vapor]

[swifter]: https://github.com/glock45/swifter
[vapor]: https://github.com/tannernelson/vapor

## TODO

- Lock PathKit to minorVersion 6 in Package.swift
- `swift build` works with PathKit in Package.swift, but even when launching
XCode with latest-swift (3.0-DEV), it can resolve `import PathKit`. However
cocoapods PathKit works in XCode, but not with `swift build`.
So that's why I have both. Sheesh.
