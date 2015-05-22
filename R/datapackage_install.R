#' Install a data package
#'
#' @param path character string path to the data package directory. Can be a
#' local directory or a URL. If a URL is given the package will be installed
#' in the current working directory. If the file is compressed
#' then it currently must be \code{.zip}-ped.
#' @param load_file character string specifying the path of the data file to
#' load into R. The correct file paths will be printed when the function runs.
#' By default the first file in the datapackage.json path list is
#' loaded.
#' Note: only one file can be loaded at a time.
#' @param full_meta logical. Wheter or not to return the full datapackage.json
#' metadata. Note: when \code{TRUE} only the meta data is returned not the data.
#' @param ... arguments to pass to \code{\link{import}}.
#' @examples
#' \dontrun{
#' # Load a data package called gdp stored in the current working directory:
#' gdp_data = datapackage_install(path = 'gdp')
#'
#' # Install the gdp data package from GitHub using its .zip URL
#' URL <- 'https://github.com/datasets/gdp/archive/master.zip'
#' gdp_data <- datapackage_install(path = URL)
#'
#' # Install co2 data
#' library(dplyr)
#' co2_data <- "https://github.com/datasets/co2-ppm/archive/master.zip" %>%
#'          datapackage_install()
#' }
#' @importFrom rio import
#' @importFrom digest digest
#' @importFrom jsonlite fromJSON
#' @importFrom magrittr %>%
#' @export

datapackage_install <- function(path,
                                load_file,
                                full_meta = FALSE,
                                ...)
{
    . <- NULL
    # Determine how to load the data package and place it in a temp directory
    # Is the file from a url?
    if (grepl('^http', path)){
        URL <- path
        temp_path <- digest(URL) %>% paste0('temp_', .)
        download(path = temp_path, url = URL)

        # Unzip if  .zip
        if (grepl(pattern = 'zip?', x = URL)) {
            temp_path_2 <- paste0('Second', temp_path)

            unzip(temp_path, exdir = temp_path_2)

            zipped_path <- list.files(temp_path_2)
            meta_zipped <- paste0(temp_path_2, '/', zipped_path,
                                '/datapackage.json') %>%
                        fromJSON()
            pkg_zipped_name <- meta_zipped$name

            if (file.exists(pkg_zipped_name)){
                unlink(c(temp_path, temp_path_2), recursive = T)
                stop(paste('Datapackage already installed.\n\n',
                    'Either remove and reinstall \n\n',
                    'OR\n\n',
                    'If you just want to load data from the package, load the data using a normal R way.\n\n',
                    'To find a list of data file paths for this package change the working directory to the data package\n',
                    'and use datapackage_info().'),
                    call. = F)
            }

            comb_unzipped <- paste0(temp_path_2, '/', zipped_path)

            file.rename(comb_unzipped, zipped_path)

            suppressMessages(file.remove(c(temp_path_2, temp_path)))

            path <- zipped_path
        }
        else if (!grepl('^http', path)){
            path <- temp_path
        }
    }

    # Parse the datapackage.json file to find the resources
    meta <- paste0(path, '/datapackage.json') %>% fromJSON()

    pkg_name <- meta$name # Name is a required field in the protocol

    # Rename downloaded directories
    if (exists('path')) file.rename(path, pkg_name); path <- pkg_name

    if (!is.null(pkg_name)){
        message(paste('\n--------------------------------',
                '\nLoading data package:', meta$name))
    }
    else if (is.null(pkg_name)){
        stop('Properly documented data package not found.', call. = F)
    }
    if (!is.null(meta$title)) datapackage_info(meta)

    #### Return requested objects to the workspace---------------------------- #
    if (isTRUE(full_meta)) {
        message('Returning the meta data list to you.')
        return(meta)
    }
    else {
        data_files <- meta$resources[['path']]
        # Load data file into workspace
        if (missing(load_file)){
            # Load first file into R
            message(paste('\nLoading into R:', data_files[1]))
            import(paste0(path, '/', data_files[1]), ...)
        }
        else if (!missing(load_file)) {
            if (!(load_file %in% data_files)) stop(paste(load_file,
                                "is not in the data package's resource list."),
                                call. = FALSE)
            message(paste('\nLoading into R:', load_file))
            import(paste0(path, '/', load_file), ...)
        }
    }
}
