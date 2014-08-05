dpmr = Data Package Manager for R
====

**Under Development. No stable version currently available.**

## Description

An R package for creating and installing data packages that follow the
[Open Knowledge Foundation](https://okfn.org/)'s
[Data Package Protocol](http://dataprotocols.org/data-packages/).
The package largely mirrors functionality in the Node.js package
[Data Package Manager (dpm)](https://github.com/okfn/dpm).

The package will eventually have two core functions:

- `datapackage_init`: Initialise a data package from a data frame, metadata list, and
source code file used to create the data set.

- `datapackage_install`: Load a data package into R.
