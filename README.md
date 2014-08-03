dpmr: Datapackage Manager for R
====

**Under Development**

## Description

An R package for creating and installing [datapackages](http://dataprotocols.org/data-packages/) that follow the [Open Knowledge Foundation](https://okfn.org/)'s Data Package Protocol. The package largely mirrors functionality in the Node.js package [Data Package Manager (dpm)](https://github.com/okfn/dpm).

The package will eventually have two core functions:

- `dpmr_init`: a function for taking R data frames and associated metadata lists and turning them into datapackages.

- `dpmr_install`: a function for downloading and loading datapackages into R.
