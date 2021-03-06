// Generated by CoffeeScript 1.12.7
(function() {
  var extend;

  extend = require('underscore').extend;

  module.exports = function(mqtt) {
    var pub, sub;
    sub = function(topic, opts, cb) {
      return mqtt.subscribe(topic, opts, cb);
    };
    pub = function(topic, message, opts, cb) {
      return mqtt.publish(topic, message, opts, cb);
    };
    return extend(mqtt, {
      sub: sub,
      pub: pub
    });
  };

}).call(this);
