[<img src="img/logo.png" align="right" height="80"/ alt="dmpr logo">](https://raw.githubusercontent.com/christophergandrud/dpmr/master/img/logo.png)

Data Package Manager for R
====

Version: 0.1.7 [![Build Status](https://travis-ci.org/christophergandrud/dpmr.svg?branch=master)](https://travis-ci.org/christophergandrud/dpmr)

## Description

The R package for creating and installing data packages that follow the
[Open Knowledge Foundation](https://okfn.org/)'s
[Data Package Protocol](http://dataprotocols.org/data-packages/).

**dpmr** has three core functions:

- `datapackage_init`: initialises a new data package from an R data frame and
(optionally) a meta data list.

- `datapackage_install`: installs a data package either stored locally or
remotely, e.g. on GitHub.

- `datapackage_info:` reads a data package's metadata (stored in its
*[datapackage.json](http://dataprotocols.org/data-packages/)*
file) into the R Console and (optionally) as a list.

## Examples

### Create Data Packages

To initiate a barebones data package in the current working directory called
`My_Data_Package` use:

```r
# Create fake data
A <- B <- C <- sample(1:20, size = 20, replace = TRUE)
ID <- sort(rep('a', 20))
Data <- data.frame(ID, A, B, C)

datapackage_init(df = Data, package_name = 'My_Data_Package')
```

This will create a data package with barebones metadata in a
*[datapackage.json](http://dataprotocols.org/data-packages/)*
file. You can then edit this by hand.

Alternatively, you can also create a list with the metadata in R and have this
included with the data package:

```r
meta_list <- list(name = 'My_Data_Package',
                    title = 'A fake data package',
                    last_updated = Sys.Date(),
                    version = '0.1',
                    license = data.frame(type = 'PDDL-1.0',
                            url = 'http://opendatacommons.org/licenses/pddl/'),
                    sources = data.frame(name = 'Fake',
                            web = 'No URL, its fake.'))

datapackage_init(df = Data, meta = meta_list)
```

Note if you don't include the `resources` fields in your metadata list, then
they will automatically be added. These fields identify the data files' paths
and data `schema`.

### Installing Data Packages

#### Locally
To load a data package called [gdp](https://github.com/datasets/gdp) stored in
the current working directory use:

```r
gdp_data <- datapackage_install(path = 'gdp/')
```

#### From the web

You can install a package stored remotely using its URL. In this example
we directly download the gdp data package from GitHub using the URL for its
zip file:

```r
URL <- 'https://github.com/datasets/gdp/archive/master.zip'
gdp_data <- datapackage_install(path = URL)
```

## Get Data Package Metadata

Use `datapackage_info` to read a data package's metadata into R:

```r
# Print information when working directory is a data package
datapackage_info()
```

## To-do for *v0.2*

- [ ] `datapackage_update` for updating a data package's data and metadata.

- [ ] Specify data variable descriptions in meta list.

- [ ] Load inline data from the *datapackage.json* file.

- [ ] Load data from a GitHub repo using GitHub usernames and repos.

---

Licensed under
[GPL-3](LICENSE.md)
