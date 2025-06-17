#' Default List of Dangerous Functions
#'
#' Returns the default set of dangerous function names that are checked
#' by [find_dangerous_calls()].
#'
#' @return A character vector of default forbidden function names.
#' @export
default_dangerous_calls <- function() {
  c("system",
    "system2",
    "unlink",
    "download.file",

    # System and shell access
    "shell",
    "pipe",

    # File system manipulation
    "file.remove",
    "file.rename",
    "file.copy",
    "dir.create",
    "file.create",
    "file.append",

    # Eval/parse-based code injection
    "eval",
    "parse",
    "get",
    "assign",
    "do.call",
    "match.fun",
    "eval.parent",

    # Environment and namespace manipulation
    "getAnywhere",
    "loadNamespace",
    "attachNamespace",
    "getNamespace",

    # network access
    "url",
    "curl_download",
    "httr::GET",
    "httr::POST"

    )
}
