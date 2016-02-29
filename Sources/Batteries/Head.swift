
import Foundation

//
// Middleware that handles HEAD requests
//
// Hansel wraps the rootHandler with this already
//

internal let wrapHead: Middleware = { handler in
  return { request in
    let response = handler(headRequest(request))
    return headResponse(request, response: response)
  }
}

func headRequest (request: Request) -> Request {
  // Turn HEAD request into GET request
  if request.method == .Head {
    return request.setMethod(.Get)
  }
  return request
}

func headResponse (request: Request, response: Response) -> Response {
  if request.method == .Head {
    return response.none()
  } else {
    return response
  }
}