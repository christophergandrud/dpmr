#' Initialise a data package from a data frame, metadata list, and source code
#' file used to create the data set.
#'
#' @param df The object name of the data frame you would like to convert into a
#' data package.
#' @param package_name character string name for the data package. Unnecessary
#' if the \code{name} field is specified in \code{meta}.
#' @param meta The list object with the data frame's meta data. The list
#' item names must conform to the Open Knowledge Foundation's Data Package
#' Protocol (see \url{http://dataprotocols.org/data-packages/}). \code{dpmr}
#' uses \code{jsonlite} to convert the list into a JSON file. If
#' \code{meta = NULL} then a barebones \code{datapackage.json} file will be
#' created. If \code{resources} is not specified then this will be automatically
#' generated.
#' @param source_cleaner a character string or vector of file paths pointing to
#' the source code file used to gather and clean the \code{df} data frame. Can
#' be in R or any other language, e.g. Python. Following Data Package convention
#' the scripts are renamed \code{process*.*}. You can also
#' \code{source_cleaner} is not required, but HIGHLY RECOMMENDED.
#' @param source_cleaner_rename logical. Whether or not to rename the 
#' \code{source_cleaner} files.
#' @param ... arguments to pass to methods.
#'
#' @examples
#' \dontrun{
#' # Create fake data
#' A <- B <- C <- sample(1:20, size = 20, replace = TRUE)
#' ID <- sort(rep('a', 20))
#' Data <- data.frame(ID, A, B, C)
#'
#' # Initialise data package
#' datapackage_init(df = Data, package_name = 'My_Data_Package')
#' }
#'
#' @importFrom jsonlite toJSON
#' @importFrom magrittr %>%
#'
#' @export

datapackage_init <- function(df,
                            package_name = NULL,
                            meta = NULL,
                            source_cleaner = NULL,
                            source_cleaner_rename = TRUE,
                            ...)
{
    #------------------- Initialize data package directories ----------------- #
    if (missing(df)) stop('df must be specified.', call. = F)

    if (!is.null(meta$name)){
        name <- meta$name
    }
    else if (is.null(meta$name)){
        if (is.null(package_name)) stop("Must specify the data package's name.",
                                        call. = F)
        name <- package_name
    }
    name <- gsub(name, pattern = ' ', replacement = '') # strip name whitespace

    # Stop if data package already exists
    if (name %in% list.files()) stop(paste('A data package called', name,
                                    'already exists in this directory.'),
                                    call. = F)

    message(paste('\n--- Creating the', name,
            'data package ---\n'))
    message(paste('Data package created in:', getwd(), '\n'))
    dir.create(name); dir.create(paste0(name, '/data'))
    dir.create(paste0(name, '/scripts'))

    #----------------------- Create/validate datapackage.json ---------------- #
    data_base_paths <- paste0('data/', name, '_data.csv')
    if (is.null(meta)){ # Create bare
        message(paste0('Creating barebones metadata datapackage.json\n',
                    '- Please add additional information directly in:\n',
                    '  ', getwd(), '/', name, '/', 'datapackage.json\n\n',
                    '  For more information see: http://dataprotocols.org/data-packages/\n'))
        meta_template(df = df, name = name, data_paths = data_base_paths) %>%
        toJSON(pretty = T) %>%
        writeLines(con = paste0(name, '/datapackage.json'))
    }
    else if (!is.null(meta)){
        if (class(meta) != 'list') stop('meta must be a list', call. = F)

        if (is.null(meta$resources)) {
            message('Adding resources to meta saved in datapackage.json.\n')
            list(meta, resources_create(data_paths = data_base_paths,
                                        df = df)) %>%
                toJSON(pretty = T) %>%
                writeLines(con = paste0(name, '/datapackage.json'))
        }

        else if (!is.null(meta$resources)){
            message('Meta data saved in: datapackage.json\n')
            meta %>% toJSON(pretty = T) %>%
            writeLines(con = paste0(name, '/datapackage.json'))
        }
    }

    #---------------------- Copy source files into scripts ------------------- #
    if (!is.null(source_cleaner)) {
        message('Moving in the source cleaner file(s):')
        for (i in 1:length(source_cleaner)){
            # Check to see if exists in working directory/valid file path
            #### To Do ####
            # if (!(source_cleaner %in% list.files(path))) stop('source_cleaner files not found'.)
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

            file.copy(from = source_cleaner[i],
                        to = paste0(name, '/scripts/', new_s_name))
            message(paste('-', source_cleaner[i], '    >>    ', new_s_name))
        }
    }

    #--- TO-DO Validate Data Frame using testdat ----------------------------- #

    # Write the data file into data/ as a CSV
    message(paste('Saving data frame as:', data_base_paths))
    write.csv(df, file = paste0(name, '/', data_base_paths), ...)
}
