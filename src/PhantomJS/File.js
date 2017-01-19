'use strict';

var fs = require('fs');

exports.openStream_ = function(filepath, filesettings, success, error) {
  try {
    console.log(filesettings);
    var stream = fs.open(filepath, filesettings);
    success(stream);
  } catch (e) {
    error(e);
  }
}

exports.writeStream_ = function(stream, str, success, error) {
  try {
    console.log(stream, str);
    stream.write(str);
    success(stream);
  } catch (e) {
    error(e);
  }
}

exports.closeStream_ = function(stream, success, error) {
  try {
    stream.close();
    success();
  } catch (e) {
    error(e);
  }


}
