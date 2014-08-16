[<img src="img/logo.png" align="right" height="80"/ alt="dmpr logo">]()

Data Package Manager for R
====

**Under Development. Check below for current capabilities.**

[![Build Status](https://travis-ci.org/christophergandrud/dpmr.svg?branch=master)](https://travis-ci.org/christophergandrud/dpmr)

## Description

An R package for creating and installing data packages that follow the
[Open Knowledge Foundation](https://okfn.org/)'s
[Data Package Protocol](http://dataprotocols.org/data-packages/).
The package largely mirrors functionality in the Node.js package
[Data Package Manager (dpm)](https://github.com/okfn/dpm).

The package will eventually have two core functions:

- `datapackage_init`: Initialise a data package from a data frame,
metadata list, and the source code file used to create the data set.

    + To-do for v0.1

    - [x] Init basic directory structure.

    - [x] Move cleaner scripts in to *scripts/*.

    - [x] Save data frame as csv in *data/*.

    - [x] Create bare *database.json*, including deriving attributes from the data.

    - [ ] Initialise using info (almost) exclusively from the `meta` *database_list*.

- `datapackage_install`: Load a data package into R.

    + To-do for v0.1

    - [x] Load data from locally stored data package CSV and return metadata.

    - [ ] Load inline data from the *datapackage.json* file.

    - [ ] Load data from a zip file at http.

    - [ ] Load data from a GitHub repo.

## Examples

To initiate a barebones data package in the current working directory called
`My_Data_Package` use:


```S
# Create dummy data
A <- B <- C <- sample(1:20, size = 20, replace = TRUE)
ID <- sort(rep('a', 20))
Data <- data.frame(ID, A, B, C)


datapackage_init(df = Data, package_name = 'My_Data_Package')
```

To load a data package called [gdp](https://github.com/datasets/gdp) stored in
the current working directory use:

```S
gdp_data = datapackage_install(path = 'gdp/')
```

## Install development build

```{S}
devtools::install_github('christophergandrud/dpmr')
```

---

[<img src="http://media.tumblr.com/023c285c14ef01953d3b67ffe789004d/tumblr_inline_mor1uu2OOZ1qz4rgp.png" height = "100" align="right" />](http://nadrosia.tumblr.com/post/53520500877/made-in-berlin-badge-update)

Licensed under
[GPL-3](LICENSE.md)
