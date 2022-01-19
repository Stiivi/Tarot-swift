# Tarot

An intertangled knowledge caputre system with multiple perspectives. Or
a knowledge aided design and simulation system.

Tarot is a graph based knowledge codification system. It means that the
bits of knowledge are preserved in a non-linear inter-connected form. The core
structure is a directed labelled multi-graph.
That means that the structure is composed of nodes and links between the nodes
and that both the nodes and links can have information associated with them.
Links and nodes can have a dictionary of scalar attributes of few basic types
associated with them.

This is an experiment, a toy, an idea playground for discovering the knoweledge 
capture and knowledge codification system itself.


Design principle:

- Every entity that represents the content knowledge must be represented by the
  graph
- Graph structures should be as simple as possible
- Multple perspectives on structures exists and is more common than exception.
  One has to be able to express them.
- Primarily porovide mechanisms, then provide convenience policies
- Synthesis and mutability of structures is primary functionality, analysis
  is secondary.
- Every structure should be considered as presentable in an user interface,
  unless deemed internal
- Avoid recursive structures, they are not easy to work with in user interfaces

Restrictions:

- If it can not be expressed by graph, it sohuld be rethinked.
- No core functionality or structure can be added if it can be expressed by
  existing functionality.
- Optimisation, either spatial or temporal, is not a reason to add or change
  anything.
- If the potential user interface for the functionality or a structure is
  complicated to create, has a risk of users being confused or is too
  structured, then the functionality or a structure should be rethinked.

For more detailed information, please refer to the documentation in
[TarotKit/Documentation](TarotKit/Documentation).

# Development

There is a lot of `#TODO:` and `#FIXME:` markers all over the code. They usually
mark technical debt that I had no time to work on at the moment but was aware
of what needs to be done.

# Disclaimer

Please, do no lament over the code. I am very well aware of what is in there and
how things should be or should not be. The code is just a reflection of
an exploration process where I am discovering how the structures for knowledge 
capture. It is an experiment.

The code might or might not get better. It will either die of coplexity and
rot, or will be replaced by something fresh. Hard to tell right now.


# Authors

- Stefan Urbanek, stefan.urbanek@gmail.com

# License

MIT
