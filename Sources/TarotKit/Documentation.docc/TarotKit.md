# ``TarotKit``

An intertangled knowledge caputre system with multiple perspectives.

Tarot is a graph based knowledge codification system. It means that the
bits of knowledge are preserved in a non-linear inter-connected form. The core
structure is a ``Graph`` that represents a directed labelled multi-graph.
That means that the structure is composed of nodes and links between the nodes
and that both the nodes and links can have information associated with them.
Graph stores a dictionary of scalar attributes of few basic types.

See also: <doc:DevelopmentNotes>


## Topics

### Graph

Graph is an object that represents a mutable oriented labelled graph structure.
It is composed of nodes and links between the nodes. Graph and
associated structures are the core of TarotKit.

- <doc:Graph>

### Graph Manager


- ``GraphManager``


### Projections

- <doc:Projections>

### Model and Semantics

- <doc:ModelAndSemantics>

### Persistence

- <doc:Persistence>

### Query

Structures and functionality to query the graph.

- ``DynamicNodeCollection``
- ``ObjectPredicate``
- ``TraitPredicate``
- ``AttributeValuePredicate``

### Interfaces

Structures and functionality for interfacing with external environments: for
importing or exporting content of the graph.


- ``Loader``
- ``FieldMap``
- ``Package``
- ``LinkResourceDescription``
- ``NodeResourceDescription``
- ``Sequencer``
- ``Issue``
