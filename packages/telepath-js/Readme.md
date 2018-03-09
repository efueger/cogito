Telepath for Javascript
=======================

[![build status](https://gitlab.ta.philips.com/blockchain-lab/telepath-js/badges/master/build.svg)](https://gitlab.ta.philips.com/blockchain-lab/telepath-js/commits/master)
[![coverage report](https://gitlab.ta.philips.com/blockchain-lab/telepath-js/badges/master/coverage.svg)](https://gitlab.ta.philips.com/blockchain-lab/telepath-js/commits/master)
[![JavaScript Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://standardjs.com)

Provides a secure channel for communication between a web app running in a browser and an app running on a mobile device.

For an overview of what Telepath is, please visit the [main telepath repo][1].

### Known Limitations

Currently uses independent encryption of messages. A recipient can therefore not detect if some messages have been duplicated, deleted or reordered.

### Usage

Create an instance of the Telepath class, providing the URL of the queuing
service:

```javascript
import Telepath from 'telepath-js'
const telepath = new Telepath('https://queuing.example.com')
```

Creating a new channel with a random id and a random encryption key. Returns a
promise:

```javascript
const channel = await telepath.createChannel()
```

Connecting a mobile app to the channel can be done by creating a connect URL.
This URL can be displayed in a QR code. The QR code can be scanned by the mobile
app and used to connect to this channel. The telepath library does not include
functionality for displaying QR codes, you can use a QR code component such as
[qrcode.react][2] for this purpose.

```javascript
const connectUrl = channel.createConnectUrl(appBaseUrl)
```

Messages are exchanged using [JSON-RPC][3]:

```javascript
const request = { jsonrpc: '2.0', method:'test', id: 1 }
const response = await channel.send(request)
```

The `send` method returns a promise. The queuing service will be polled for a
response for at least 10 minutes. If no response is available after this time it
will return `null`.

[1]: https://gitlab.ta.philips.com/blockchain-lab/telepath
[2]: https://www.npmjs.com/package/qrcode.react
[3]: http://www.jsonrpc.org/specification