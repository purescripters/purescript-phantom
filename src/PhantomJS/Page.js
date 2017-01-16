'use strict';

exports.createPage_ = function(callback) {
  var webpage = require('webpage').create();
  return function() {
    callback(webpage)();
  }
}

exports.open_ = function(callback) {
  return function(page) {
    return function(url) {
      return function() {
        page.open(url, function(status) {
          // http://phantomjs.org/api/webpage/method/open.html
          // 'success' or 'fail'
          if (status == "success") {
            callback(page)();
          }
        });
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
  return function(page) {
    return function(filename) {
      return function() {
        // http://phantomjs.org/api/webpage/method/inject-js.html
        if (page.injectJs(filename)) {
          callback(page)();
        }
      }
    }
  }
}

exports.evaluate_ = function(callback) {
  return function(page) {
    return function(fnName) {
      return function() {
        // http://phantomjs.org/api/webpage/method/inject-js.html
        var r = page.evaluate(function(fnName) {
          return window[fnName]();
        }, fnName);

        callback(r)();
      }
    }
  }
}
