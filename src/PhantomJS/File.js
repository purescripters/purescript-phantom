'use strict';

var fs = require('fs');

function alwaysCancel(cancelError, onCancelerError, onCancelerSuccess) {
  onCancelerSuccess();
}

exports.exists_ = function(filepath) {
  return function(error, success) {
    try {
      // http://phantomjs.org/api/fs/method/exists.html
      var exists = fs.exists(filepath);
    } catch (e) {
      error(e);
    }
    success(exists);
    return alwaysCancel;
  }
}

exports.remove_ = function(filepath) {
  return function(error, success) {
    try {
      // http://phantomjs.org/api/fs/method/remove.html
      fs.remove(filepath);
    } catch (e) {
      // e is undefeind in this situation, so we don't do
      // error(e);
      error(new Error("File '" + filepath + "' does not exist."));
    }
    success();
    return alwaysCancel;
  }
}

exports.write_ = function(filepath) {
  return function (str) {
    return function (filemode) {
      return function(error, success) {
        try {
          // http://phantomjs.org/api/fs/method/write.html
          fs.write(filepath, str, filemode);
        } catch (e) {
          error(e);
        }
        success();
        return alwaysCancel;
      }
    }
  }
}

exports.read_ = function(filepath) {
  return function(error, success) {
    try {
      // http://phantomjs.org/api/fs/method/read.html
      var content = fs.read(filepath);
    } catch (e) {
      // e is undefeind in this situation, so we don't do
      // error(e);
      error(new Error("File '" + filepath + "' could not be read."));
    }
    success(content);
    return alwaysCancel;
  }
}

exports.lastModified_ = function(filepath) {
  return function(toDateTime) {
    return function(error, success) {
      try {
        // http://phantomjs.org/api/fs/method/lastModified.html
        var modified = fs.lastModified(filepath);
        if (modified == null) throw new Error(filepath + ' does not exist.');
        var instant = modified.toTime();

      } catch (e) {
        error(e);
      }
      success(instant);
      return alwaysCancel;
    }
  }
}
