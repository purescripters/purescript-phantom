'use strict';

function alwaysCancel(cancelError, onCancelerError, onCancelerSuccess) {
  onCancelerSuccess();
}

function PhantomPageError(message, stack) {
  this.name = 'PhantomPageError';
  this.message = message;
  this.stack = stack || (new Error()).stack;
}
PhantomPageError.prototype = Object.create(Error.prototype);
PhantomPageError.prototype.constructor = PhantomPageError;

exports.createPage_ = function(error, success) {
  var webpage = require('webpage').create();
  success(webpage);
  return alwaysCancel;
}

exports.open_ = function(page) {
  return function(url) {
    return function(error, success) {
      page.open(url, function(status) {
        // http://phantomjs.org/api/webpage/method/open.html
        // 'success' or 'fail'
        if (status == "success") {
          success(page);
        } else {
          error(new PhantomPageError("open '" + url + "' failed with phantom status '" + status + "'"));
        }
      });

      return alwaysCancel;
    }
  }
}


exports.render_ = function(page) {
  return function(filename) {
    return function(settings) {
      return function(error, success) {
        try {
          // http://phantomjs.org/api/webpage/method/render.html
          var r = page.render(filename, settings);
          success(page);
        } catch (e) {
          error(new PhantomPageError("Could not render page to file '" + filename + "'. " + e.message, e.stack));
        }

        return alwaysCancel;
      }
    }
  }
}


exports.injectJs_ = function(page) {
  return function(filename) {
    return function(error, success) {
      // http://phantomjs.org/api/webpage/method/inject-js.html
      if (page.injectJs(filename)) {
        success(page);
      } else {
        error(new PhantomPageError("'" + filename + "' could not be injected into page.  Maybe the filepath is misspelled or does not exist?"));
      }
      return alwaysCancel;
    }
  }
}


exports.customHeaders_ = function(page) {
  return function(foreignObj) {
    return function(error, success) {
      page.customHeaders = foreignObj;
      success(page);
      return alwaysCancel;
    }
  }
}


exports.evaluate_ = function(page) {
  return function(fnName) {
    return function(error, success) {

      var r = page.evaluate(function(fnName) {
          try {
            return window[fnName]();
          } catch (e) {

            // If we just return e, then
            // { "line": Int, "sourceURL": String, "stack": String }
            // gets passed to the local context.  Creating a custom
            // object allow us to pass more information about the exception.
            return {
              type : "purescript-phantom-error",
              message : e.message,
              stack : e.stack,
              line : e.line,
              sourceURL : e.sourceURL
            }
          }
      }, fnName);

      if (r.type && r.type == "purescript-phantom-error") {
        // An exception was thrown in the page's context
        // so we'll create a custom Error object that
        // lets us set the message and stack
        error(new PhantomPageError(r.message, r.stack));
      } else {
        success(r);
      }
      
      return alwaysCancel;
    }
  }
}
