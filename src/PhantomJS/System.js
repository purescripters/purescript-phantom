'use strict';

var system = require('system');

exports.os = function() {
  return system.os;
}

exports.foldEnv = function(fn) {
  return function(init) {
    var env = system.env;
    return Object.keys(env).reduce(function(acc, key) {
      acc = fn(acc)(key)(env[key]);
      return acc;
    }, init);
  }
}

exports.getEnv_ = function(key) {
  return function(just) {
    return function (nothing) {
      if (key in system.env) {
        return just(system.env[key]);
      } else {
        return nothing;
      }
    }
  }
}

exports.pid = function() {
  return system.pid;
}
