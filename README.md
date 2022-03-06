# Tarot

Graph world sculpting library. TarotKit is a library and set of tools for
creating mental worlds represented as a graph with focus on the creation
process over graph analysis.

This toolkit itself is an experiment, a toy, an idea playground and a space
to discover itself.

Tarot is a labelled-property graph. For convenience the graph is directed
although it provides some functionality to treat it as undirected graph.


Design principle:

- Synthesis and mutability of structures is primary functionality. As a
  consequence: analysis and graph traversal is secondary.
- Changes to the structure can be reverted to some extent. There must be
  a possibility to have a reasonable undo-redo buffer, not just a single
  transaction that can be rolled-back.
- Library structures should be as simple as possible
- Provide multiple perspectives on the graph structures (sub-graphs) instead
  of creating different types of graph objects.
- Primarily provide mechanisms, then provide convenience policies
- Every library entity should be considered as presentable in an user interface,
  unless deemed internal
- Avoid recursive structures, they are not easy to work with in user interfaces

Restrictions:

- If a higher level entity can not be expressed by graph, it should be
  reconsidered
- No core functionality or structure can be added if it can be expressed by
  existing functionality.
- Optimisation, either spatial or temporal, is not a reason to add or change
  anything.
- If the potential user interface for the functionality or a structure is
  complicated to create, has a risk of users being confused or is too
  structured, then the functionality or a structure should be re-thinkied.

For more detailed information, please refer to the documentation in
[TarotKit/Documentation](TarotKit/Documentation).

# What it is not

Tarot is not a full graph database, despite carrying some of the elements of it.

# Development

There is a lot of `#TODO:` and `#FIXME:` markers all over the code. They usually
mark technical debt that I had no time to work on at the moment but was aware
of what needs to be done.

# Disclaimer

The library is experimental. Can be used as a toy.

The code might contain:

- technical debt (usually marked as `FIXME`)
- historical remnants - ways of doing things that seemed to be appropriate
  at the time of the implementation, but were not aligned with the newest
  understanding of the project


# Authors

- Stefan Urbanek, stefan.urbanek@gmail.com

# License

MIT
