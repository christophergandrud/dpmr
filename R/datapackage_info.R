#' Return key meta information about the data package
#'
#' @param path character string file path to the data package. If empty, then
#' the datapackage.json meta data file is searched for in the working directory.
#' Can also accept a datapackage.json file parsed in R as a list.
#' @param as_list logical indicating whether or not to return the
#' datapackage.json file as a list.
#'
#' @examples
#' \dontrun{
#' # Print information when working directory is a data package
#' datapackage_info()
#' }
#'
#' @importFrom jsonlite fromJSON
#' @importFrom magrittr %>%
#'
#' @export

datapackage_info <- function(path,
                             as_list = FALSE)
{
    if (missing(path)){
        if (!('datapackage.json' %in% list.files())) {
            stop('datapackage.json not found in working directory.', call. = F)
        }
        meta <- paste0('datapackage.json') %>% fromJSON()
    }
    else if (class(path) == 'character') {
        if (!('datapackage.json' %in% list.files(path))) {
            stop(paste0('datapackage.json not found in: ', path, '.'), call. = F)
        }
        meta <- paste0(path, '/datapackage.json') %>% fromJSON()
    }

    else if (class(path) == 'list') meta <- path

    message(paste('--', meta$title[[1]], '--\n'))

    meta_message('version', 'Version:', meta_in = meta)
    meta_message('datapackage_version', 'Version:', meta_in = meta)
    meta_message('last_updated', 'Last updated:', meta_in = meta)
    meta_message('description', 'Description:', meta_in = meta)
    meta_message('license', 'License:', meta_in = meta)
    meta_message('licenses', 'Licenses:', meta_in = meta)
    meta_message('homepage', 'Homepage:', meta_in = meta)
    meta_message('maintainer', 'Maintainers:', meta_in = meta)
    meta_message('contributors', 'Contributors:', meta_in = meta)
    meta_message('sources', 'Sources:', meta_in = meta)

    message('\n')

    meta$resources %>% meta_message_data()

    message('\n----')

    if (isTRUE(as_list)) return(meta)
}
