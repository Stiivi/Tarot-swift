# ``TarotKit``

An intertangled knowledge caputre system with multiple perspectives.

Tarot is a graph based knowledge codification system. It means that the
bits of knowledge are preserved in a non-linear inter-connected form. The core
structure is a ``GraphMemory`` that represents a directed labelled multi-graph.
That means that the structure is composed of nodes and links between the nodes
and that both the nodes and links can have information associated with them.
Graph memory stores a dictionary of scalar attributes of few basic types.

Design principle:

- Every entity that represents the content knowledge must be represented by the
  graph
- Graph structures should be as simple as possible
- Purity of abstraction has its practical limits
- Multple perspectives on structures exists and is more common than exception
- Primarily porovide mechanisms, then provide convenience policies

## Topics

### Graph Memory

Graph memory is an object that represents and manipulates an oriented labelled
graph. It is composed of nodes and links between the nodes. Graph memory and
associated structures are the core of TarotKit.

- <doc:Graph>

### Space


- ``Space``

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
