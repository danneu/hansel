
*Disclaimer: I started building this yesterday to learn Swift.*

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
  return Response("Hello world")
}

Server(logger(handler)).listen(3000)
```

Hansel is an experimental Swift web-server that focuses on:

- Simplicity
- Immutability
- Middleware

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

struct Request {
  let url: String
  let headers: [String: String]
  let method: Method
  // ...
}

struct Response {
  let status: Status
  let headers: [String: String]
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
Response(status: .Ok, headers: [String: String](), body: "Hello")
Response("Hello")           //=> text/plain
Response("<h1>Hello</h1>")  //=> text/html
Response(.NotFound)
Response(status: .NotFound, body: "File not found :(")
```

``` swift
Response()
  .setBody("Hello world")
  .setHeader("X-Hello", "World")
```

## Handler (Request -> Response)

Because `Handler` is a typealias, these are equivalent:

``` swift
func handler (request: Request) -> Response {
  return Response("Hello world")
}

// Preferred
let handler: Handler { request in 
  Response("Hello world")
}
```

## Middleware (Handler -> Handler)

Middleware functions let you run logic before the request hits the handler
and after the response leaves the handler.

For example, a cookie-parsing middleware function would parse a request's
"Cookie" header and attach it as a `.cookies` map on the request for
downstream middleware/handlers to access.

And once the response is coming back upstream, it would convert the
response's `.cookies` map to zero or more "Set-Cookie" headers.

All of this logic would be contained in a single function.

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

## Default Middleware

When you give hansel your final handler function, it wraps it with 
some of its own outer middleware.

- HEAD request handling

## Thanks

- Socket implementation from [glock45/swifter][swifter]
- Some socket glue code from [tannernelson/vapor][vapor]

[swifter]: https://github.com/glock45/swifter
[vapor]: https://github.com/tannernelson/vapor
