---
# cSpell:words QUIC
---
# Distributed Queue

A distributed queue without a central authority.

## Design goals

- send authenticated and encrypted messages between nodes
- address nodes by public key
- nodes could be directly or indirectly reachable
- temporary and persistent messages

## Transport

There is no standard transport.
The main transports can be TLS and QUIC sessions.
The protocol does not rely on TLS to encrypt messages,
TLS is only used to protect metadata on the network layer.

## Public Key

A public key is used to identify and find a node or service.
Each public key can have different attributes describing how
visible a node should be.

### Immutable attributes

- local anonymity [none/everything through proxy]
- global anonymity [none/everything non local through proxy/no global reachability]

### Temporary attributes
- reachability: IP-Address/Host/Proxy node to use. Proxy node information might have recursive reachability hints.

## Retransmit of messages

A message can have multiple attributes to specify it's QoS.

## Proxy nodes

Because most nodes (smartphones/IoT devices behind NAT/device which don't even speak IP/anonymity)
are not reachable from the public internet,
proxy nodes are used to send messages to them.
Proxy nodes can be selected automatically on a temporary basis or
be configures permanently.

Some ideas for connection modes to proxy nodes:

- normal TLS based connection
- QUIC connection for improved roaming
- obfuscated protocols (in websocket, in DNS, over IRC, over MQTT)

### Proxy nodes with message queue

Some devices, for example mobile devices and IoT devices,
might not have a steady connection to save battery usage or airtime.
Those devices might use a proxy node which will store incoming messages for them.
The device will poll the proxy for new messages.

# Glossary

Node
: A device in the network

Public Key
: A (usually Ed25565) public key to identify a node or service

Proxy
: A node which can proxy or retain messages for other nodes

QoS
: Quality-of-Service: Describes if a message should be retransmitted or acknowledged