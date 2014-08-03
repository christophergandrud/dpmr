dpmr = Data Package Manager for R
====

**Under Development. No stable version currently available.**

## Description

An R package for creating and installing data packages that follow the [Open Knowledge Foundation](https://okfn.org/)'s [Data Package Protocol](http://dataprotocols.org/data-packages/). The package largely mirrors functionality in the Node.js package [Data Package Manager (dpm)](https://github.com/okfn/dpm).

The package will eventually have two core functions:

- `dpmr_init`: a function for turning R data frames, associated metadata lists, and source code files used to create the data into data packages.

- `dpmr_install`: a function for downloading and loading datapackages into R.
