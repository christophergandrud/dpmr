#' Template for datapackage.json
#'
#' @param df The data frame object name of the data frame you would like to
#' convert into a data package.
#' @param data_paths character vector of df paths.
#'
#' @keywords helpers
#' @export

meta_template <- function(df, data_paths){
    list(name = 'Test',
        title = '',
        description = '',
        maintainer = '',
        contributors = '',
        version = 1,
        last_updated = as.Date(Sys.time()),
        homepage = '',
        keywords = '',
        publisher = '',
        url = '',
        base = '',
        image = '',
        license = data.frame(type = 'PDDL-1.0',
                    url = 'http://opendatacommons.org/licenses/pddl/'),
        dataDependencies = '',
        sources = '',
        resources = list(resources = data.frame(path = data_paths),
                         schema = 'test')
    )
}
