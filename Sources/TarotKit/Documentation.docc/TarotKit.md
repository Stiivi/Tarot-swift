# ``TarotKit``

An intertangled knowledge caputre system with multiple perspectives.

Tarot is a graph based knowledge codification system. It means that the
bits of knowledge are preserved in a non-linear inter-connected form. The core
structure is a ``GraphMemory`` that represents a directed labelled multi-graph.
That means that the structure is composed of nodes and links between the nodes
and that both the nodes and links can have information associated with them.
Graph memory stores a dictionary of scalar attributes of few basic types.

See also: <doc:DevelopmentNotes>


## Topics

### Graph Memory

Graph memory is an object that represents and manipulates an oriented labelled
graph. It is composed of nodes and links between the nodes. Graph memory and
associated structures are the core of TarotKit.

- <doc:Graph>

### Space


- ``Space``


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
