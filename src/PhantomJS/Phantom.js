exports.isCookiesEnabled = function() {
  return phantom.cookiesEnabled;
}

exports.setCookiesEnabled = function(enabled) {
  return function() {
    phantom.cookiesEnabled = enabled;
    return {};
  }
}

exports._cookies = function() {
  return phantom.cookies;
}

exports.getLibraryPath = function() {
  return phantom.libraryPath;
}

exports.setLibraryPath = function(path) {
  return function() {
    phantom.libraryPath = path;
    return {};
  }
}

exports._version = function() {
  return phantom.version;
}

exports._addCookie = function(cookie) {
  return function() {
    return phantom.addCookie(cookie);
  }
}

exports.clearCookies = function() {
  phantom.clearCookies();
  return {};
}

exports.deleteCookie = function(cookieName) {
  return function() {
    return phantom.deleteCookie(cookieName);
  }
}

exports.exit = function(exitCode) {
  return function() {
    phantom.exit(exitCode);
    return {};
  }
}

exports.injectJs = function(filepath) {
  return function() {
    return phantom.injectJs(filepath);
  }
}
