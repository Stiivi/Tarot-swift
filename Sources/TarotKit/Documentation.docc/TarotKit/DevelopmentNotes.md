# Development Notes

Here are few notes about the development of the TarotKit.

## Overview

Design principle:

- Every entity that represents the content knowledge must be represented by the
  graph
- Graph structures should be as simple as possible
- Purity of abstraction has its practical limits
- Multple perspectives on structures exists and is more common than exception
- Primarily porovide mechanisms, then provide convenience policies

## On Generics

The goal of the project is to provide a concrete, opinionated model for knowledge
representation and design. The goal is not to provide a graph and related
structures for generic usage.

Not providing genenerics allows us:

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

## Analogies

Think of it as if one were developing a simulation computer game with an option
for advanced users to develop extensions and plug-ins for the game. The game has
concrete entities that compose the simulation. Similar here, the entities
provided by the framework are the entites of a game simulation.

Or think of it as an operating system. Modules are connected through interfaces.
We design interfaces and core operating system model. On top of that model
developers can create concrete applications interacting with the model through
interfaces.

Goal is not to be able to do anything. Goal is to be a ble to design 
and operate on knowledge. We view knowledge as a stateful concrete entity.
