# Disknet
Disknet works by using a shared directory between two or more computers to emulate the functionality of a modem. A channel file is opened, which can be used to send/receive messages to/from it.
While one machine is receiving, it is constantly checking the channel file for changes. If it finds one, it will re-read it and see if a new message was sent.

## Functions:
`disknet.open(string channelName)`
Opens a channel for use. Unopened channels can't be used.

`disknet.close(string channelName)`
Closes a channel.

`disknet.closeAll()`
Closes all channels.

`disknet.isOpen(string channel)`
Returns true/false is a channel is already open.

`disknet.send(string channel, string message, optional number recipientID)`
Sends `message` on `channel`. If a `recipientID` is specified, then only a disknet recipient whose computer ID matches it will be able to receive the message.

`disknet.receive(optional string channel, optional number senderID)`
Receives a disknet message. If `channel` is specified, it will only accept messages from that channel. If `senderID` is specified, it will only accept messages from that sender computer ID.
