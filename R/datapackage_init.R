#' Initialise a data package from a data frame, metadata list, and source code
#' file used to create the data set.
#'
#' @param df The data frame object name of the data frame you would like to convert
#' into a data package.
#' @param meta The list object name with the data frames meta data. The list
#' item names must conform to the Open Knowledge Foundation's Data Package
#' Protocol (see \url{http://dataprotocols.org/data-packages/}).
#' @param source_clean a character string file path pointing to the source code
#' file used to gather and clean the \code{df} data frame. Can be in R or any
#' other language, e.g. Python. \code{source_clean} is not required, but HIGHLY
#' RECOMMENDED.
#'
#' @export

datapacakge_init <- function(df, meta, source_clean){

}
