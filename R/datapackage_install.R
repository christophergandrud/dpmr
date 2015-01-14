#' Install a data package
#'
#' @param path character string path to the data package directory. Can be a
#' local directory or a URL. If a URL is given the package will be installed
#' in the current working directory. If the file is compressed
#' then it currently must be \code{.zip}-ped.
#' @param load_file character string specifying the path of the data file to
#' load into R. The correct file paths will be printed when the function runs.
#' By default the first file in the datapackage.json path list is
#' loaded. Can only be a CSV formatted file currently.
#' Note: only one file can be loaded at a time.
#' @param full_meta logical. Wheter or not to return the full datapackage.json
#' metadata. Note: when \code{TRUE} only the meta data is returned not the data.
#'
#' @examples
#' \dontrun{
#' # Load a data package called gdp stored in the current working directory:
#' gdp_data = datapackage_install(path = 'gdp')
#'
#' # Install the gdp data package from GitHub using its .zip URL
#' URL <- 'https://github.com/datasets/gdp/archive/master.zip'
#' gdp_data <- datapackage_install(path = URL)
#' }
#'
#' @importFrom digest digest
#' @importFrom jsonlite fromJSON
#' @importFrom magrittr %>%
#' @export

datapackage_install <- function(path,
                                load_file,
                                full_meta = FALSE)
{
    . <- NULL
    # Determine how to load the data package and place it in a temp directory
    # Is the file from a url?
    if (isTRUE(grepl('^http', path))){
        URL <- path
        temp_path <- digest(URL) %>% paste0('temp_', .)
        download(path = temp_path, url = URL)

        # Unzip if  .zip
        if (grepl(pattern = 'zip?', x = URL)) {
            temp_path_2 <- paste0('Second', temp_path)

            unzip(temp_path, exdir = temp_path_2)

            zipped_path <- list.files(temp_path_2)
            if (zipped_path %in% list.files()) {
                unlink(c(temp_path, temp_path_2), recursive = T)
                stop(paste('Datapackage', zipped_path, 'already installed.\n',
                    'Either remove and reinstall \n',
                    'or\n',
                    'if you just want to load data from the package, load the data using a normal R way.'),
                    call. = F)
            }

            comb_unzipped <- paste0(temp_path_2, '/', zipped_path)

            file.rename(comb_unzipped, zipped_path)

            suppressMessages(file.remove(c(temp_path_2, temp_path)))

            path <- zipped_path
        }
        else if (!isTRUE(grepl('^http', path))){
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
        resources <- meta$resources

        if (is.null(resources)) {
            stop(paste0('\nData package is not properly documented.',
                '\nNo instruction for finding resources given.\n', call. = F))
        }
        else if (!is.null(resources)){
            data_files <- resources[[2]] %>% unlist()
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
