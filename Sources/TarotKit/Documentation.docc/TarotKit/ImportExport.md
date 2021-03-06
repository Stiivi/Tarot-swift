# Import and Export

Moving pieces of information into the graph and extracting it from the graph.

## Overview

Import is a process when a pieces of external information, that might exist in
various formats, is loaded into the graph. The imported information usually
blends in the existing graph and does not retain its original shape.

Export is a process hwen a part of the graph is extracted and encoded in an
external format. For example a sequence of nodes is exported as a text document
or as a table.


## Topics

### Imporiting

Import is performed by a loader. A loader loads a resource, converts entities
and their properties at the source into nodes and/or links in the graph. Loaders
can create additional artefacts that represent the loaded batch.

Loader returns a dictionary of named objects. The dictionary is used by the
caller to perform additional linking of nodes of some special significance.

- ``Loader``
- ``TarotFileLoader``
- ``MarkdownLoader``
- ``RelationalPackageLoader``
- ``RelationalPackageInfo``
- ``RelationalPackage``
- ``NodeRelation``
- ``LinkRelation``

### Exporting

- ``GraphWriter``
- ``TarotFileWriter``
- ``DotExporter``
- ``MarkdownExporter``
