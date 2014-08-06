#' Install a data package
#'
#' @param path character string path to the data package directory. Can be a
#' local directory, a remote repository's URL, or a GitHub username/repo.
#' @param load_file character string specifying the name of the data file to
#' load into R.
#' Note: unfortunately R only allows one file to be returned at a time.
#'
#' @importFrom jsonlite fromJSON
#' @importFrom magrittr %>%
#' @export

datapackage_install <- function(path, load_file = NULL){
    # Determine how to load the data package and place it in a temp directory
    # Is there a non-empty local path?
    NumFiles <- list.files(path) %>% length
    if (NumFiles == 0){
        # Fill in with remote repo downloaders
        # path <- tmp
    }

    # Parse the datapackage.json file to find the resources
    meta <- paste0(path, '/datapackage.json') %>% fromJSON()

    # Return background information to user
    pkg_name <- meta$name # Name is a required field in the protocol
    if (!is.null(pkg_name)){
        message(paste('\nLoading data package:', meta$name))
    }
    else if (is.null(pkg_name)){
        stop('Properly documented data package not found.', call. = FALSE)
    }
    if (!is.null(meta$title)) message(paste('--', meta$title, '--'))
    if (!is.null(meta$version)) message(paste('Version:', meta$version))
    if (!is.null(meta$last_updated)) message(paste('Last updated:',
                                            meta$last_updated))
    if (!is.null(meta$homepage)) message(paste('Homepage:', meta$homepage))
    if (!is.null(meta$maintainer)) message(paste('Maintainer:', meta$maintainer))


    resources <- meta$resources

    if (is.null(resources)) {
        stop(paste0('\nData package is not properly documented.',
            '\nNo instruction for finding resources given.\n', call. = FALSE))
    }
    else if (!is.null(resources)){
        data_files <- resources[[1]] %>% unlist()
        message(paste('\nThe data package contains the following data file(s):'))
        for (i in data_files){
            message(paste0(i, '\n'))
        }
    }

    # Load data file into workspace
    if (is.null(load_file)){

    }
}
