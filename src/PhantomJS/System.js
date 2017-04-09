'use strict';

var system = require('system');

exports.os = function() {
  return system.os;
}

exports.foldEnv = function(fn) {
  return function(init) {
    var env = system.env;
    return function() {
      return Object.keys(env).reduce(function(acc, key) {
        acc = fn(acc)(key)(env[key]);
        return acc;
      }, init);
    }
  }
}

exports.getEnv_ = function(key) {
  return function(just) {
    return function (nothing) {
      return function() {
        var env = system.env;
        if (key in env) {
          return just(env[key]);
        } else {
          return nothing;
        }
      }
    }
  }
}

exports.pid = function() {
  return system.pid;
}
