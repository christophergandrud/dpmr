#' Template for datapackage.json
#'
#' @param df The data frame object name of the data frame you would like to
#' convert into a data package.
#' @param name character string name of the datapackage.
#' @param data_paths character vector of df paths.
#'
#'
#' @keywords helpers
#' @export

meta_template <- function(df, name, data_paths){
    out <- list(name = name,
        title = '',
        description = '',
        maintainer = list(),
        contributors = list(),
        version = '1',
        last_updated = as.Date(Sys.time()),
        homepage = '',
        keywords = list(),
        publisher = list(),
        url = '',
        base = '',
        image = '',
        license = data.frame(type = 'PDDL-1.0',
                            url = 'http://opendatacommons.org/licenses/pddl/'),
        dataDependencies = '',
        sources = list(),
        resources = resources_create(data_paths, df = df)
    )
    return(out)
}

#' Create schema from a data frame
#' @importFrom magrittr %>%
#' @keywords internals
#' @noRd

schema_df <- function(df){
    type <- vector()
    for (i in 1:ncol(df)){
        type[i] <- df[, i] %>% class
    }

    ## Convert to closest JSON type
    type_json <- gsub(type, pattern = 'numeric|integer', replacement = 'number')
    type_json <- gsub(type_json, pattern = 'chracter|factor',
    replacement = 'string')
    type_json <- gsub(type_json, pattern = 'logical', replacement = 'boolean')

    schema_df <- data.frame(name = names(df), type = type_json)
    return(schema_df)
}

#' Create resources
#' @keywords internals
#' @noRd

resources_create <- function(data_paths, df){
    resources_out <- list(list(path = data_paths,
                          schema =list(fields=schema_df(df))))
    return(resources_out)
}

#' Downloade file
#'
#' @source Modified from devtools version Version: 1.6.1.9000
#'
#' @importFrom httr GET stop_for_status content
#'
#' @keywords internals
#' @noRd

download <- function(path, url, ...) {
    message(paste('Downloading from:', url))
    request <- GET(url, ...)
    stop_for_status(request)
    writeBin(content(request, "raw"), path)
}

#' Return key metadata to console
#' @importFrom magrittr %>%
#'
#' @keywords internals
#' @noRd

meta_message <- function(field, pre_field, meta_in = meta){
    meta <- NULL
    if ((field %in% names(meta_in))) {
        fields <- unlist(meta_in[field])
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
    else return('')
}

#' Return list of included data files to console
#' @importFrom magrittr %>%
#'
#' @keywords internals
#' @noRd

meta_message_data <- function(resources){
    if (is.null(resources)) {
        stop(paste0('\nData package is not properly documented.',
        '\nNo instruction for finding resources given.\n', call. = F))
    }
    else if (!is.null(resources)){
        data_files <- resources[['path']] %>% unlist()
        message(paste('The data package contains the following data file(s):\n'))
        for (i in data_files){
            message(paste0(i))
        }
    }
}
