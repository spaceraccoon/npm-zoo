// Generated by CoffeeScript 1.12.7
(function() {
  var COLLECTIONS_TOPIC, COLLECTION_POSITION, GLOBAL_COLLECTION_POSITION, QOS, debug, isJson, randomstring;

  randomstring = require('randomstring');

  isJson = require('is-json');

  debug = (require('debug'))("device-mqtt:api_db");

  QOS = 2;

  COLLECTIONS_TOPIC = 'collections';

  COLLECTION_POSITION = 2;

  GLOBAL_COLLECTION_POSITION = 2;

  module.exports = function(arg) {
    var DB_REGEX, GLOBAL_REGEX, _createCollectionObject, _extractCollectionName, _extractGlobalCollectionName, _handleGlobalCollections, _handleLocalCollections, _isJson, _mqtt, _socket, _updateCollectionObject, createCollection, createGlobalCollection, handleMessage, mqttInstance, socket, socketId;
    mqttInstance = arg.mqttInstance, socket = arg.socket, socketId = arg.socketId;
    if (!mqttInstance) {
      throw new Error('No mqtt connection provided!');
    }
    if (!socketId) {
      throw new Error('ClientId must be provided!');
    }
    DB_REGEX = new RegExp("^" + socketId + "\/collections\/(.)+$");
    GLOBAL_REGEX = new RegExp("^global\/collections\/(.)+$");
    _mqtt = mqttInstance;
    _socket = socket;
    createCollection = function(collectionName, localState, collectionObjCb) {
      var singleObjCollTopic;
      singleObjCollTopic = socketId + "/" + COLLECTIONS_TOPIC + "/" + collectionName;
      debug("createCollection", singleObjCollTopic);
      return collectionObjCb(_createCollectionObject(singleObjCollTopic, localState));
    };
    createGlobalCollection = function(collectionName, localState, collectionObjCb) {
      var singleGlobalObjCollTopic;
      singleGlobalObjCollTopic = "global/collections/" + collectionName;
      return collectionObjCb(_createCollectionObject(singleGlobalObjCollTopic, localState));
    };
    _createCollectionObject = function(singleObjCollTopic, localState) {
      var collectionObj;
      collectionObj = {};
      collectionObj.add = function(arg1, done) {
        var key, value;
        key = arg1.key, value = arg1.value;
        if (localState[key]) {
          return done(new Error("Key `" + key + "` already existent!"));
        }
        localState[key] = value;
        if ((_isJson(value)) || (Array.isArray(value))) {
          value = JSON.stringify(value);
        }
        return _updateCollectionObject(singleObjCollTopic, localState, function() {
          return _mqtt.pub(singleObjCollTopic + "/" + key, value, {
            qos: QOS,
            retain: true
          }, function(error) {
            if (error) {
              return done(error);
            }
            return done();
          });
        });
      };
      collectionObj.remove = function(key, done) {
        if (!localState[key]) {
          return done(new Error("Cannot remove key `" + key + "`: not existent!"));
        }
        delete localState[key];
        return _updateCollectionObject(singleObjCollTopic, localState, function() {
          return _mqtt.pub(singleObjCollTopic + "/" + key, null, {
            qos: QOS,
            retain: true
          }, function(error) {
            if (error) {
              return done(error);
            }
            return done();
          });
        });
      };
      collectionObj.update = function(arg1, done) {
        var key, value;
        key = arg1.key, value = arg1.value;
        if (!localState[key]) {
          return done(new Error("Cannot update key `" + key + "`: not existent!"));
        }
        localState[key] = value;
        if ((_isJson(value)) || (Array.isArray(value))) {
          value = JSON.stringify(value);
        }
        return _updateCollectionObject(singleObjCollTopic, localState, function() {
          return _mqtt.pub(singleObjCollTopic + "/" + key, value, {
            qos: QOS,
            retain: true
          }, function(error) {
            if (error) {
              return done('error', error);
            }
            return done();
          });
        });
      };
      collectionObj.get = function(key) {
        if (!localState[key]) {
          return null;
        }
        if (isJson(localState[key])) {
          return JSON.parse(localState[key]);
        }
        return localState[key];
      };
      collectionObj.getAll = function() {
        return localState;
      };
      return collectionObj;
    };
    _isJson = function(object) {
      var passObjects;
      return isJson(object, [passObjects = true]);
    };
    _updateCollectionObject = function(singleObjCollTopic, localState, cb) {
      return _mqtt.pub(singleObjCollTopic, JSON.stringify(localState), {
        qos: QOS,
        retain: true
      }, function(error) {
        if (error) {
          return done(error);
        }
        return cb();
      });
    };
    handleMessage = function(topic, message, collectionType) {
      switch (collectionType) {
        case 'local':
          return _handleLocalCollections(topic, message);
        case 'global':
          return _handleGlobalCollections(topic, message);
      }
    };
    _handleLocalCollections = function(topic, message) {
      var collectionName, singleItemCollTopicRegex;
      singleItemCollTopicRegex = new RegExp("^" + socketId + "\/collections\/(.)+\/(.)+$");
      collectionName = _extractCollectionName(topic);
      if (singleItemCollTopicRegex.test(topic)) {
        if (isJson(message)) {
          message = JSON.parse(message);
        }
        return _socket.emit("collection:" + collectionName, message);
      } else {
        message = JSON.parse(message);
        return _socket.emit('collection', collectionName, message);
      }
    };
    _handleGlobalCollections = function(topic, message) {
      var collectionName, globalSingleItemCollTopicRegex;
      globalSingleItemCollTopicRegex = new RegExp("^global\/collections\/(.)+\/(.)+$");
      collectionName = _extractGlobalCollectionName(topic);
      if (globalSingleItemCollTopicRegex.test(topic)) {
        if (isJson(message)) {
          message = JSON.parse(message);
        }
        return _socket.emit("global:collection:" + collectionName, message);
      } else {
        message = JSON.parse(message);
        return _socket.emit('global:collection', collectionName, message);
      }
    };
    _extractCollectionName = function(topic) {
      return (topic.split('/'))[COLLECTION_POSITION];
    };
    _extractGlobalCollectionName = function(topic) {
      return (topic.split('/'))[GLOBAL_COLLECTION_POSITION];
    };
    return {
      createCollection: createCollection,
      createGlobalCollection: createGlobalCollection,
      handleMessage: handleMessage,
      dbRegex: DB_REGEX,
      globalRegex: GLOBAL_REGEX
    };
  };

}).call(this);
