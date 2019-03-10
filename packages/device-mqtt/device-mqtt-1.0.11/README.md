# device-mqtt

## client

* **constructor** arguments:
  * *host*: required - MQTT broker host
  * *port*: required - MQTT broker port
  * *clientId*: required - MQTT clientId
  * *tls*: optional - refer to MQTT.js library for arguments
  * *extraOpts*: optional - refer to MQTT.js library for extra connection options


* **connect** arguments:
  * *will*: optional - MQTT will


* **destroy** arguments:
  * *cb*: callback is called when MQTT connection is closed


* **client events**:
  * *connected*, triggered when the client is connected. Returns the socket in the callback.
  * *error*, triggered when there is an error.
  * *reconnecting*, triggered when the client tries to reconnect to the MQTT broker

## socket

* **send** arguments:
  * *message*: required - The message must have parameters: {action, dest, payload}
  * *resultCb*: required - (error, result)
  * *mqttCb*: optional - (error, result)


* **createCollection** arguments:
  * *collectionName*: required - The name of the collection
  * *localState*: required - The local variable where the state will be stored
  * *collectionObjectCb*: required - Returns the collection object used to query the 'MQTT' database


* **createGlobalCollection** arguments:
  * *collectionName*: required - The name of the collection
  * *localState*: required - The local variable where the state will be stored
  * *collectionObjectCb*: required - Returns the collection object used to query the 'MQTT' database


* **customPublish** arguments:
  * *{ topic, message, opts }*
  * *cb*


* **customSubscribe** arguments:
* *{ topic, opts }*
* *cb*


# Usage

```coffee-script
  devicemqtt = require 'device-mqtt'

  client = devicemqtt host, port, 'client'

  client.on 'connected', (socket) ->
    socket.send(
      {action, dest, payload}
    , (error, response) ->

    , (error, ack) ->

    )
```
