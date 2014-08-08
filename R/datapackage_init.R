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
#' @param source_cleaner a character string or vector of file paths pointing to
#' the source code file used to gather and clean the \code{df} data frame. Can
#' be in R or any other language, e.g. Python. Following Data Package convention
#' the scripts are renamed \code{process*.*}. You can also  \code{source_cleaner} is not
#' required, but HIGHLY RECOMMENDED.
#'
#' @importFrom magrittr %>%
#'
#' @export

datapackage_init <- function(df, package_name, meta = NULL,
                            source_cleaner = NULL){
    #------------------- Initialize data package directories ----------------- #
    if (!is.null(meta$name)){
        name <- meta$name
    }
    else if (is.null(meta$name)){
        if (is.null(package_name)) stop('Must specify package name.', call. = F)
        name <- package_name
    }
    name <- gsub(name, pattern = ' ', replacement = '') # strip name whitespace

    # Stop if data package already exists
    if (name %in% list.files()) stop(paste('A data package called', name,
                                    'already exists in this directory.'),
                                    call. = F)

    dir.create(name); dir.create(paste0(name, '/data'))
    dir.create(paste0(name, '/scripts'))

    #---------------------- Copy source files into scripts ------------------- #
    if (!is.null(source_cleaner)) {
        message('Moving in the source cleaner files:')
        for (i in 1:length(source_cleaner)){
            new_s_name <- source_cleaner[i] %>% gsub(pattern = '(.*\\/)([^.]+)',
                                            replacement = paste0('process_', i))

            file.copy(from = source_cleaner[i],
                to = paste0(name, '/scripts/', new_s_name))
            message(new_s_name)
        }
    }


    #--- TO-DO Validate Data Frame using testdat ----------------------------- #

    # Write the data file into data/ as a CSV
    write.csv(df, file = paste0(name, '/data/', 'data1.csv')) # CHANGE NAMING SO THAT IT DRAWS ON META
}
