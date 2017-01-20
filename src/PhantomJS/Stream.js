'use strict';

var fs = require('fs');

exports.open_ = function(filepath) {
  return function (filesettings) {
    return function (success, error) {
      try {
        var stream = fs.open(filepath, filesettings);
      } catch (e) {
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

exports.exists_ = function(filepath) {
  return function(success, error) {
    try {
      // http://phantomjs.org/api/fs/method/exists.html
      var exists = fs.exists(filepath);
    } catch (e) {
      error(e);
    }
    success(exists);
  }
}

exports.remove_ = function(filepath) {
  return function(success, error) {
    try {
      // http://phantomjs.org/api/fs/method/remove.html
      fs.remove(filepath);
    } catch (e) {
      error(e);
    }
    success();
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
