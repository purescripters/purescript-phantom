'use strict';

var fs = require('fs');

function PhantomPageError(message, stack) {
  this.name = 'PhantomPageError';
  this.message = message;
  this.stack = stack || (new Error()).stack;
}
PhantomPageError.prototype = Object.create(Error.prototype);
PhantomPageError.prototype.constructor = PhantomPageError;

exports.open_ = function(filepath) {
  return function (filesettings) {
    return function (success, error) {
      try {
        var stream = fs.open(filepath, filesettings);
      } catch (e) {
        // when filepath doesn't exist, e is a string
        // not an error.  We'll turn it into an error;
        if (!(e instanceof Error)) e = new PhantomPageError(e);
        error(e);
      }
      success(stream);
    }
  }
}

exports.write_ = function(stream) {
  return function(str) {
    return function(success, error) {
      try {
        stream.write(str);
      } catch (e) {
        error(e);
      }
      success(stream);
    }
  }
}

exports.readLine_ = function(stream) {
  return function(just) {
    return function (nothing) {
      return function(success, error) {
        try {
          if (!stream.atEnd()) {
            var line = just(stream.readLine());
          } else {
            var line = nothing;
          }
        } catch (e) {
          error(e);
        }
        success(line);
      }
    }
  }
}

exports.writeLine_ = function(stream) {
  return function(str) {
    return function(success, error) {
      try {
        stream.writeLine(str);
      } catch (e) {
        error(e);
      }
      success(stream);
    }
  }
}

exports.close_ = function(stream) {
  return function(success, error) {
    try {
      stream.close();
    } catch (e) {
      error(e);
    }
    success();
  }
}
