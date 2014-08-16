# ---------------------------------------------------------------------------- #
#### Contains utility functions for interacting with GitHub
#### Many of these functions are modified from those in devtools
# ---------------------------------------------------------------------------- #

#' Get a connection to a GitHub repository
#' @keywords internal
#' @noRd
github_get_conn <- function(repo, username = getOption("github.user"),
                            ref = "master", pull = NULL, subdir = NULL,
                            branch = NULL, auth_user = NULL, password = NULL,
                            auth_token = NULL, ...) {
    github_pull <- NULL
    if (!is.null(branch)) {
        warning("'branch' is deprecated. In the future, please use 'ref' instead.")
        ref <- branch
    }

    if (!is.null(pull)) {
        warning("'pull' is deprecated. In the future, please use 'ref = github_pull(...)' instead.")
        ref <- github_pull(pull)
    }

    params <- github_parse_path(repo)
    username <- params$username %||% username
    repo <- params$repo
    ref <- params$ref %||% ref
    subdir <- params$subdir %||% subdir

    if (!is.null(password)) {
        warning("'password' is deprecated. Please use 'auth_token' instead",
                call. = FALSE)
        auth <- httr::authenticate(
            user = auth_user %||% username,
            password = password,
            type = "basic"
        )
    } else if (!is.null(auth_token)) {
        auth <- httr::authenticate(
            user = auth_token,
            password = "x-oauth-basic",
            type = "basic"
        )
    } else {
        auth <- list()
    }

    param <- list(
        auth = auth, repo = repo, username = username,
        ref = ref, subdir = subdir,
        auth_user = auth_user, password = password
    )

    param <- modifyList(param, github_ref(param$ref, param))

    param$msg <- paste(
        "Installing github repo",
        paste(param$repo, param$ref, sep = "/", collapse = ", "),
        "from",
        paste(username, collapse = ", "))

    param$url <- paste(
        "https://api.github.com", "repos", param$username, param$repo,
        "zipball", param$ref, sep = "/")

    param
}

#' Parse a GitHub path
#' @keywords internal
#' @noRd

github_parse_path <- function(path) {
    github_pull <- NULL
    username_rx <- "(?:([^/]+)/)?"
    repo_rx <- "([^/@#]+)"
    subdir_rx <- "(?:/([^@#]*[^@#/]))?"
    ref_rx <- "(?:@(.+))"
    pull_rx <- "(?:#([0-9]+))"
    ref_or_pull_rx <- sprintf("(?:%s|%s)?", ref_rx, pull_rx)
    github_rx <- sprintf("^(?:%s%s%s%s|(.*))$",
                         username_rx, repo_rx, subdir_rx, ref_or_pull_rx)

    param_names <- c("username", "repo", "subdir", "ref", "pull", "invalid")
    replace <- setNames(sprintf("\\%d", seq_along(param_names)), param_names)
    params <- lapply(replace, function(r) gsub(github_rx, r, path, perl = TRUE))
    if (params$invalid != "")
        stop(sprintf("Invalid GitHub path: %s", path))
    params <- params[sapply(params, nchar) > 0]

    if (!is.null(params$pull)) {
        params$ref <- github_pull(params$pull)
        params$pull <- NULL
    }

    params
}

#' Resolve a token to a GitHub reference
#'
#' A generic function, for internal use only.
#'
#' @param x Reference token
#' @param param A named list of GitHub parameters
#' @keywords internal
#' @noRd

github_ref <- function(x, param) UseMethod("github_ref")

# Treat the parameter as a named reference
#' @keywords internal
#' @noRd
github_ref.default <- function(x, param) list(ref=x)

#' Helper function for NULLs
#' @keywords internal
#' @noRd

"%||%" <- function(a, b) if (!is.null(a)) a else b
