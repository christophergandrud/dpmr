#' Initialise a data package from a data frame, metadata list, and source code
#' file used to create the data set.
#'
#' @param df The object name of the data frame you would like to convert into a
#' data package.
#' @param package_name character string name for the data package. Unnecessary
#' if the \code{name} field is specified in \code{meta}.
#' @param output_dir character string naming the output directory to save the
#' data package into. By default the current working directory is used.
#' @param meta The list object with the data frame's meta data. The list
#' item names must conform to the Open Knowledge Foundation's Data Package
#' Protocol (see \url{http://dataprotocols.org/data-packages/}). Must include
#' the \code{name}, \code{license}, and \code{version} fields.
#' If \code{resources} is not specified then this will be automatically
#' generated. \code{dpmr} uses \code{jsonlite} to convert the list into a
#' JSON file. See the \code{\link{toJSON}} documentation for details.
#' If \code{meta = NULL} then a barebones \code{datapackage.json} file will be
#' created.
#' @param source_cleaner a character string or vector of file paths relative to
#' the current working directory pointing to the source code file used to gather
#' and clean the \code{df} data frame. Can be in R or any other language, e.g.
#' Python. Following Data Package convention the scripts are renamed
#' \code{process*.*}, unless specified otherwise with
#' \code{source_cleaner_rename}. \code{source_cleaner} is not required, but
#' HIGHLY RECOMMENDED.
#' @param source_cleaner_rename logical. Whether or not to rename the
#' \code{source_cleaner} files.
#' @param ... arguments to pass to \code{\link{export}}.
#'
#' @examples
#' \dontrun{
#' # Create fake data
#' A <- B <- C <- sample(1:20, size = 20, replace = TRUE)
#' ID <- sort(rep('a', 20))
#' Data <- data.frame(ID, A, B, C)
#'
#' # Initialise data package with barebones, automatically generated metadata
#' datapackage_init(df = Data, package_name = 'my-data-package')
#'
#' # Initialise with user specified metadata
#' meta_list <- list(name = 'my-data-package',
#'                  title = 'A fake data package',
#'                  last_updated = Sys.Date(),
#'                  version = '0.1',
#'                  license = data.frame(type = 'PDDL-1.0',
#'                           url = 'http://opendatacommons.org/licenses/pddl/'),
#'                  sources = data.frame(name = 'Fake',
#'                           web = 'No URL, its fake.'))
#'
#'  datapackage_init(df = Data, meta = meta_list)
#' }
#'
#' @importFrom rio export
#' @importFrom jsonlite toJSON
#' @importFrom magrittr %>%
#'
#' @export

datapackage_init <- function(df,
                            package_name = NULL,
                            output_dir = getwd(),
                            meta = NULL,
                            source_cleaner = NULL,
                            source_cleaner_rename = TRUE,
                            ...)
{
    #------------------- Initialize data package directories ----------------- #
    if (missing(df)) stop('df must be specified.', call. = FALSE)
    if (!is.data.frame(df)) stop('df must be a data.frame class object.',
        call. = FALSE)
    if ('tbl_df' %in% class(df)) {
        message('Converting your tbl_df to a data.frame')
        df <- as.data.frame(df)
    }

    # Set working directory for datapackage
    old_dir <- getwd()
    setwd(output_dir)

    if (!is.null(meta)){
        # Ensure that required fields are present in metadata list
        required_fields <- c('name', 'license.*', '.*version')
        for (i in required_fields){
            if (!any(grepl(i, names(meta)))) {
                stop(paste('Missing required metadata field:', i))
            }
        }
        # Extract data package name from metadata
        name <- meta$name
    }
    else if (is.null(meta$name)){
        if (is.null(package_name)) stop("Must specify the data package's name.",
                                        call. = FALSE)
        name <- package_name
    }
    name <- gsub(name, pattern = ' ', replacement = '') # strip name whitespace

    # Stop if data package already exists
    if (name %in% list.files()) stop(paste('A data package called', name,
                                    'already exists in this directory.'),
                                    call. = FALSE)

    message(paste('\n--- Creating the', name,
            'data package ---\n'))
    message(paste('Data package created in:', getwd(), '\n'))
    dir.create(name); dir.create(paste0(name, '/data'))
    dir.create(paste0(name, '/scripts'))

    #----------------------- Create/validate datapackage.json ---------------- #
    data_base_paths <- paste0('data/', name, '-data.csv')
    if (is.null(meta)){ # Create bare
        message(paste0('Creating barebones metadata datapackage.json\n',
                    '- Please add additional information directly in:\n',
                    '  ', getwd(), '/', name, '/', 'datapackage.json\n\n',
                    '  For more information see: http://dataprotocols.org/data-packages/\n'))
        meta_template(df = df, name = name, data_paths = data_base_paths) %>%
            toJSON(pretty = T,auto_unbox=T) %>%
            writeLines(con = paste0(name, '/datapackage.json'))
    }
    else if (!is.null(meta)){
        if (class(meta) != 'list') stop('meta must be a list', call. = FALSE)

        if (is.null(meta$resources)) {
            message('Adding resources to metadata saved in datapackage.json.\n')
            list(meta, resources_create(data_paths = data_base_paths,
                                        df = df)) %>%
                toJSON(pretty = T,auto_unbox=T) %>%
                writeLines(con = paste0(name, '/datapackage.json'))
        }

        else if (!is.null(meta$resources)){
            message('Meta data saved in: datapackage.json\n')
            meta %>% toJSON(pretty = T, auto_unbox = T) %>%
            writeLines(con = paste0(name, '/datapackage.json'))
        }
    }

    #---------------------- Copy source files into scripts ------------------- #
    if (!is.null(source_cleaner)) {
        for (i in 1:length(source_cleaner)){
            if (isTRUE(source_cleaner_rename)){
                new_s_name <- gsub(pattern = '(.*\\/)([^.]+)',
                                   replacement = paste0('process_', i),
                                   x = source_cleaner[i])
            }
            else {
                new_s_name <- gsub(pattern = '(.*\\/)',
                                   replacement = '',
                                   x = source_cleaner[i])
            }

            info <- file.info(source_cleaner[i])
            if (is.na(info[1])) {
                warning(paste(source_cleaner[i], 'not found.'))
            }
            else {
                message('Moving in the source cleaner file(s):')
                file.copy(from = source_cleaner[i],
                    to = paste0(name, '/scripts/', new_s_name))
                message(paste('-', source_cleaner[i], '    >>    ', new_s_name))
            }
        }
    }

    #--- TO-DO Validate Data Frame using testdat ----------------------------- #

    # Write the data file into data/ as a CSV
    message(paste('Saving data frame as:', data_base_paths))
    export(df, file = paste0(name, '/', data_base_paths), ...)

    setwd(old_dir)
}
