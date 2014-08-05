#' Install a data package
#'
#' @param path character string path to the data package directory. Can be a
#' local directory, a remote repository's URL, or a GitHub username/repo.
#'
#' @importFrom jsonlite fromJSON
#' @export

datapackage_install <- function(path){
    # Determine how to load the data package and place it in a temp directory

    # Parse the datapackage.json file to find the resources
    meta <- fromJSON(metaPath)
    resouces <- meta$resouces

    if (is.null(resources)) stop('Data package is not properly documented.\nNo instruction for finding resources given.\n',
    call. = FALSE)
}
