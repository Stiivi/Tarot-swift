# GraphSpace

A description of this package.

- Serious toy
- Explore your domain, explore your model
- Develop model with your data
- Validate data with your model, validate model with your data

# Modules

## Records

Package for working with structured records and record sets with support for
basic data types. Primary use case is validating and treating import of
structured data into an application where the data might represent application
objects and structures.

All record sets are managed in memory, therefore this package is not suitable
for problems which require huge volumes of data.  

Examples:

- Application objects collection of CSV file where one CSV file represents one
  kind of object.
- Simulation model or a scenario editale by an external textual editor

Out of scope:

- Memory and time performance for large volumes

### Notes

Should consider renaming this to "Foreign Records" or "Interfaces"


# Technical Debt

- All #FIXME comments are markers of known technical debt - shortcuts, hacks

