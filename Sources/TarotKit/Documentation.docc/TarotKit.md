# ``TarotKit``

Graph world sculpting library. TarotKit is a library and set of tools for
creating mental worlds represented as a graph with focus on the creation
process over graph analysis.

This toolkit itself is an experiment, a toy, an idea playground and a space
to discover itself.

Tarot is a labelled-property graph system. The core structure is a ``Graph``,
which is a directed graph where graph objects – links and nodes – can have a
set of attributes associated with them.


See also: <doc:DevelopmentNotes>


## Topics

### Graph

Graph is an object that represents a mutable oriented labelled graph structure.
It is composed of nodes and links between the nodes. Graph and
associated structures are the core of TarotKit.

- <doc:GraphElements>

### Graph Manager


- ``GraphManager``


### Projections and Neighbourhoods

- <doc:Projections>

### Skeleton

- <doc:Skeleton>


### Interfaces: Import and Export

Structures and functionality for interfacing with external environments: for
importing or exporting content of the graph.

- <doc:ImportExport>


### Query

Structures and functionality to query the graph.

- ``ObjectPredicate``
- ``AttributeValuePredicate``

