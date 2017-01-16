'use strict';

exports.createPage_ = function(callback) {
  var webpage = require('webpage').create();
  return function() {
    callback(webpage)();
  }
}

exports.open_ = function(callback) {
  return function(errorCallback) {
    return function(page) {
      return function(url) {
        return function(a,b,c,d) {
          page.open(url, function(status) {
            // http://phantomjs.org/api/webpage/method/open.html
            // 'success' or 'fail'
            if (status == "success") {
              callback(page)();
            } else {
              errorCallback("open '" + url + "' failed with phantom status '" + status + "'")();
            }
          });
        }
      }
    }
  }
}

exports.render_ = function(callback) {
  return function(page) {
    return function(filename) {
      return function(format) {
        return function() {
          // http://phantomjs.org/api/webpage/method/render.html
          page.render(filename, format)
          callback(page)();
        }
      }
    }
  }
}

exports.injectJs_ = function(callback) {
  return function(errorCallback) {
    return function(page) {
      return function(filename) {
        return function() {
          // http://phantomjs.org/api/webpage/method/inject-js.html
          if (page.injectJs(filename)) {
            callback(page)();
          } else {
            errorCallback("'" + filename + "' could not be injected into page.  Maybe the filepath is misspelled or does not exist?")();
          }
        }
      }
    }
  }
}

exports.evaluate_ = function(callback) {
  return function(errorCallback) {
    return function(page) {
      return function(fnName) {
        return function() {
          // http://phantomjs.org/api/webpage/method/inject-js.html
          var r = page.evaluate(function(fnName) {
              try {
                return window[fnName]();
              } catch (e) {
                return "!!!ERROR!!!(" + e.message + "";
              }
          }, fnName);

          if (r.slice(0,11) == "!!!ERROR!!!") {
            errorCallback("Evaluation error while running function '" + fnName + "' in page. Message: " + r.slice(11))();
          } else {
            callback(r)();
          }
        }
      }
    }
  }
}
