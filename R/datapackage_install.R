#' Install a data package
#'
#' @param path character string path to the data package directory. Can be a
#' local directory or a remote repository's URL. Note: if the file is compressed
#' then it currently must be \code{.zip}.
#' @param load_file character string specifying the path of the data file to
#' load into R. The correct file paths will be printed when the function runs.
#' By default the first file in the datapackage.json path list is
#' loaded. Can only be a CSV formatted file currently.
#' Note: unfortunately R only allows one file to be returned at a time.
#' @param full_meta logical. Wheter or not to return the full datapackage.json
#' metadata. Note: when \code{TRUE} only the meta data is returned not the data.
#'
#' @examples
#' \dontrun{
#' # To load a data package called
#' # [gdp](https://github.com/datasets/gdp) stored in
#' # the current working directory use:
#' gdp_data = datapackage_install(path = 'gdp')
#' }
#'
#' @importFrom downloader
#' @importFrom jsonlite fromJSON
#' @importFrom magrittr %>%
#' @export

datapackage_install <- function(path, package_name, load_file,
    full_meta = FALSE){
    # Determine how to load the data package and place it in a temp directory
    # Is the file from a url?
    if (isTRUE(grepl('^http', path))){
        if (missing(package_name)){
            
        }

        download(path, tempfile)
        if (grepl('.zip'))
    }

    # Is there a non-empty local path?
    NumFiles <- list.files(path) %>% length
    if (NumFiles == 0){
        # Fill in with remote repo downloaders
        # path <- tmp
    }

    # Parse the datapackage.json file to find the resources
    meta <- paste0(path, '/datapackage.json') %>% jsonlite::fromJSON()

    #### Return background information to user ------------------------------- #
    meta_message <- function(field, pre_field){
        fields <- unlist(meta[field])
        if (!is.null(fields)){
            if (length(fields) == 1){
                message(paste(pre_field, fields))
            }
            else if (length(fields) > 1){
                message(paste(pre_field))
                for (u in 1:length(fields)) {
                    fields[[u]] %>% message(paste())
                }
            }
        }
    }
    pkg_name <- meta$name # Name is a required field in the protocol
    if (!is.null(pkg_name)){
        message(paste('\n--------------------------------',
                '\nLoading data package:', meta$name))
    }
    else if (is.null(pkg_name)){
        stop('Properly documented data package not found.', call. = F)
    }
    if (!is.null(meta$title)) message(paste('--', meta$title, '--'))

    meta_message('version', 'Version:')
    meta_message('datapackage_version', 'Version:')
    meta_message('last_updated', 'Last updated:')
    meta_message('description', 'Description:')
    meta_message('license', 'License:')
    meta_message('licenses', 'Licenses:')
    meta_message('homepage', 'Homepage:')
    meta_message('maintainer', 'Maintainers:')
    meta_message('contributors', 'Contributors:')
    meta_message('sources', 'Sources:')

    message('\n----')

    #### Return requested objects to the workspace---------------------------- #
    if (isTRUE(full_meta)) {
        message('Returning the meta data list to you.')
        return(meta)
    }
    else {
        resources <- meta$resources

        if (is.null(resources)) {
            stop(paste0('\nData package is not properly documented.',
                '\nNo instruction for finding resources given.\n', call. = F))
        }
        else if (!is.null(resources)){
            data_files <- resources[[1]] %>% unlist()
            message(paste('The data package contains the following data file(s):\n'))
            for (i in data_files){
                message(paste0(i))
            }
        }

        # Load data file into workspace
        if (missing(load_file)){
            # Load first file into R
            message(paste('\nLoading into R:', data_files[1]))
            paste0(path, '/', data_files[1]) %>% read.csv(stringsAsFactors = F)
        }
        else if (!missing(load_file)) {
            if (!(load_file %in% data_files)) stop(paste(load_file,
                                "is not in the data package's resource list."),
                                call. = FALSE)
            message(paste('\nLoading into R:', load_file))
            paste0(path, '/', load_file) %>% read.csv(stringsAsFactors = FALSE)
        }
    }
}
