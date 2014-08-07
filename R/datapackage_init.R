#' Initialise a data package from a data frame, metadata list, and source code
#' file used to create the data set.
#'
#' @param df The data frame object name of the data frame you would like to convert
#' into a data package.
#' @param package_name character string name for the data package. Unnecessary
#' if the \code{name} field is specified in \code{meta}.  
#' @param meta The list object name with the data frames meta data. The list
#' item names must conform to the Open Knowledge Foundation's Data Package
#' Protocol (see \url{http://dataprotocols.org/data-packages/}). If 
#' \code{meta = NULL} then a barebones \code{datapackage.json} file will be 
#' created.
#' @param source_clean a character string file path pointing to the source code
#' file used to gather and clean the \code{df} data frame. Can be in R or any
#' other language, e.g. Python. \code{source_clean} is not required, but HIGHLY
#' RECOMMENDED.
#' 
#' @importFrom magrittr %>%
#'
#' @export

datapacakge_init <- function(df, package_name, meta = NULL, source_clean = NULL){
    # Initialize data package directory
    if (!is.null(meta$name)){
        name <- meta$name
    }
    else if (is.null(meta$name)){
        if (is.null(package_name)) stop('Must specify package name.', call. = F)
        name <- package_name
    }
    grepl(name, pattern = ' ', replacement = '')
    dir.create(name); dir.create(paste0(name, '/data'))
    dir.create(paste0(name, '/scripts'))

}
