'use strict';

function alwaysCancel(cancelError, onCancelerError, onCancelerSuccess) {
  onCancelerSuccess();
}

function defaultErrorHandler(msg, trace) {

  var msgStack = [msg];

  if (trace && trace.length) {
    trace.forEach(function(t) {
      msgStack.push(' at ' + (t.function ? t.function + ' ' : '') + '(' + t.file + ':' + t.line + ')');
    });
  }
  console.error(msgStack.join('\n'));

}

var phantomPageGlobal = {
  pageCounter : 0,
  errors : {}
};


function PhantomPageError(message, stack) {
  this.name = 'PhantomPageError';
  this.message = message;
  this.stack = stack || (new Error()).stack;
}
PhantomPageError.prototype = Object.create(Error.prototype);
PhantomPageError.prototype.constructor = PhantomPageError;

exports.createPage_ = function(error, success) {
  var webpage = require('webpage').create();
  webpage.phantomUniqueId = phantomPageGlobal.pageCounter++;
  webpage.onError = defaultErrorHandler;
  success(webpage);
  return alwaysCancel;
};

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
};

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
};

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
};


exports.customHeaders_ = function(page) {
  return function(foreignArr) {
    return function(error, success) {
      var foreignObj = {}, i, item;
      for (i = 0; i < foreignArr.length; i++) {
        item = foreignArr[i];
        foreignObj[item.key] = item.value;
      }
      page.customHeaders = foreignObj;
      success(page);
      return alwaysCancel;
    }
  }
};

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

      if (r && r.type && r.type == "purescript-phantom-error") {
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
};

exports.onResourceRequested_ = function(page) {
  return function(error, success) {

    page.onResourceRequested = function(request) {
      success(request);
    }

    return alwaysCancel;

  }
};

exports.onResourceRequestedFor_ = function(page) {
  return function(time) {
    var start = Date.now();
    var end = start + time;
    var requests = [];

    return function(error, success) {

      window.setTimeout(function() {
        success(requests);
      }, time);

      page.onResourceRequested = function(request) {
        if (Date.now() <= end) {
          requests.push(request);
        }
      }

      return alwaysCancel;

    }
  }
};

exports.silencePageErrors_ = function(page) {

  phantomPageGlobal.errors[page.phantomUniqueId] = phantomPageGlobal.errors[page.phantomUniqueId] || [];

  return function(error, success) {
    // http://phantomjs.org/api/webpage/handler/on-error.html
    page.onError = function(msg, trace) {
      phantomPageGlobal.errors[page.phantomUniqueId].push({
        message : msg,
        trace : trace
      });
    };

    // success();

    return function cancelSilencePageErrors_(cancelError, onCancelerError, onCancelerSuccess) {
      page.onError = defaultErrorHandler;
      onCancelerSuccess();
    }

  }
};

exports.getSilencedErrors_ = function(page, just, nothing) {
  return function(error, success) {
    if (phantomPageGlobal.errors[page.phantomUniqueId]) {
      var errors = phantomPageGlobal.errors[page.phantomUniqueId].map(function(e) {
        return {
          message : e.message,
          trace : e.trace.map(function(t) {
            return {
              file : t.file,
              line : t.line,
              function : t.function ? just(t.function) : nothing,
            }
          })
        }
      });
      success(errors);
    } else {
      success([]);
    }

    return alwaysCancel;
  }
};

exports.clearPageErrors_ = function(page) {
  return function(error, success) {
    if (phantomPageGlobal.errors[page.phantomUniqueId]) {
      phantomPageGlobal.errors[page.phantomUniqueId] = [];
      success();
    } else {
      success();
    }

    return alwaysCancel;
  }
};


exports.waitImpl = function(time) {
  return function (error, success) {
    setTimeout(function() {
      success();
    }, time);

    function alwaysCancel(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess();
    }

    return alwaysCancel;

  }
};
