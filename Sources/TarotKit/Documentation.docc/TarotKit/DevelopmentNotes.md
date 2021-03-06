# Development Notes

Here are few notes about the development of the TarotKit.

## Overview

This toolkit itself is an experiment, a toy, an idea playground and a space
to discover itself.



Design principle:

- Synthesis and mutability of structures is primary functionality. As a
  consequence: analysis and graph traversal is secondary.
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

## Know Debt and Out of Scope

The following features are out of scope for now. When they might become
considered as important is not known at this moment. One of the reasons why
they might be out of scope is that they might be going into the way of
idea exploration and idea refinement.

The framework needs to be done right from structure and interfaces perspective
first.

Known debt:

- Error handling – important, but postponed for a bit later (``fatalError()``
  is fine for now)
- Performance – postponed for later
- Thread safety – postponed for later

Out of scope:

- Generics - not intended (see a note below)


## Status

The whole framework should be treated as "exploration of an idea space". It is
an experimentation playground for concepts.


Documentation of some symbols contains a remark about its current development
status, if it is relevant to be pointed out. The possible status is:

- `Idea` – the feature is just an idea, it might disappear without warning. If
  if is an object, its structure and functionality might contain elements that 
  are there "just to make it work" and that might not be designed thoroughly.
  Ideas are there to be studied.
- `Experimental` – feature seems to be more reasonable to be used, yet still
  is not in its final form. Not only structure might change, but also the
  elements themselves might be redesigned. Name might change.
- `Unstable` – Structure might change, yet the impact is lower than of an
  experimental feature. It is to be used with caution. Name is less likely to
  be changed.
- `Stable` – Feature reached its maturity. Changes are unlikely.


## On Generics

### Concrete Graph Model

The goal of the project is to provide a concrete, opinionated model for
knowledge representation and design. The goal is not to provide an abstract
graph structure.

Not making the graph (and some other objects) as a generics allows us:

- reduce cognitive load during the development process of the framework
- reduce visual noise of the source code (and therefore another reduction of 
  cognitive load)
- reduce scope of potential cases and therefore potential worries
- make external interfaces simpler
    - make import and export of structures from applications simpler, easier
      to implement
    - reduce potential cases that developers of external tools have to worry
      about
    - reduce the amount of metadata that might be required to be exposed or 
      consumed when interacting with the outside world
- make the framework more friendly to beginners


### Exploration of Requirements

During the development I want to understand the model first, what is required
and what is not. I want to observe repeated interface patterns and how they
interact with each other. I want to understand what is required for implementing
the model in some other programming language that might not provide generics
natively, for example Python.

## Analogies

Think of it as if one were developing a simulation computer game with an option
for advanced users to develop extensions and plug-ins for the game. The game has
concrete entities that compose the simulation. Similar here, the entities
provided by the framework are the entities of a game simulation.

Or think of it as an operating system. Modules are connected through interfaces.
We design interfaces and core operating system model. On top of that model
developers can create concrete applications interacting with the model through
interfaces.

Goal is not to be able to do anything. Goal is to be able to design 
and operate on knowledge. We view knowledge as a stateful concrete entity.
