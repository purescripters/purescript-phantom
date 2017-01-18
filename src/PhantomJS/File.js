'use strict';

var fs = require('fs');

exports.openStream_ = function(success, errorCallback, filepath, filesettings) {
  try {
    console.log(filepath, filesettings);
    console.log(filesettings.mode);
    console.log(filesettings.charset);

    var stream = fs.open(filepath, filesettings);
    success(stream)();
  } catch (e) {
    errorCallback(e.message)();
  }
}

exports.writeStream_ = function(success, errorCallback, stream, str) {
  try {
    console.log(stream, str);
    stream.write(str);
    success(stream)();
  } catch (e) {
    errorCallback(e.message)();
  }
}

exports.closeStream_ = function(success, errorCallback, stream) {
  try {
    stream.close();
    success()();
  } catch (e) {
    errorCallback(e.message)();
  }


}
