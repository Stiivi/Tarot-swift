# Model and Semantics

Graph memory is a generic structure that has no explicit meaning. Model brings
meaning to the graph objects and their attributes.

## Overview

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

## Topics

### Traits

- ``Trait``
- ``AttributeDescription``
- ``LinkDescription``


### Model

- ``Model``

### Node Views

Node views are projections of nodes in the graph that give the nodes additional
meaning and provide higher level manipulation with the nodes. For example
the ``Collection`` view treats node as if it were a collection with items, and
treats specific outgoing link as references to the collection member items.

- ``Collection``
- ``Dictionary``
- ``NodeView``

