function handler(event) {
  let request = event.request;
  let uri = request.uri;

  // Redirect URLs ending in .html (except index.html) to their directory equivalent
  if (uri.endsWith('.html') && !uri.endsWith('/index.html')) {
      return {
          statusCode: 301,
          statusDescription: 'Moved Permanently',
          headers: {
              "location": { "value": uri.replace(/\.html$/, "/") }
          }
      };
  }

  // Append index.html if the request URI ends with a slash
  if (uri.endsWith('/')) {
      request.uri += 'index.html';
  } 
  // Append /index.html if there's no file extension
  else if (!uri.includes('.')) {
      request.uri += '/index.html';
  }

  return request;
}
