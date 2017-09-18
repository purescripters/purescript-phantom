'use strict';

var fs = require('fs');

function PhantomPageError(message, stack) {
  this.name = 'PhantomPageError';
  this.message = message;
  this.stack = stack || (new Error()).stack;
}
PhantomPageError.prototype = Object.create(Error.prototype);
PhantomPageError.prototype.constructor = PhantomPageError;

function alwaysCancel(cancelError, onCancelerError, onCancelerSuccess) {
  onCancelerSuccess();
}

exports.open_ = function(filepath) {
  return function (filesettings) {
    return function (error, success) {
      try {
        var stream = fs.open(filepath, filesettings);
      } catch (e) {
        // when filepath doesn't exist, e is a string
        // not an error.  We'll turn it into an error;
        if (!(e instanceof Error)) e = new PhantomPageError(e);
        error(e);
      }
      success(stream);
      return alwaysCancel;
    }
  }
}

exports.write_ = function(stream) {
  return function(str) {
    return function(error, success) {
      try {
        stream.write(str);
      } catch (e) {
        error(e);
      }
      success(stream);
      return alwaysCancel;
    }
  }
}

exports.readLine_ = function(stream) {
  return function(just) {
    return function (nothing) {
      return function(error, success) {
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
        return alwaysCancel;
      }
    }
  }
}

exports.writeLine_ = function(stream) {
  return function(str) {
    return function(error, success) {
      try {
        stream.writeLine(str);
      } catch (e) {
        error(e);
      }
      success(stream);
      return alwaysCancel;
    }
  }
}

exports.close_ = function(stream) {
  return function(error, success) {
    try {
      stream.close();
    } catch (e) {
      error(e);
    }
    success();
    return alwaysCancel;
  }
}

exports.seek_ = function(stream) {
  return function (position) {
    return function (error, success) {
      try {
        stream.seek(position);
        success(stream);
      } catch (e) {
        error(e);
      }
      return alwaysCancel;
    }
  }
}