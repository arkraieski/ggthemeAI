#' Retrieve the contents of a package's news for the current major version
#'
#' @param pkg The name of the package (a character string).
#'
#' @return A character vector of lines from `NEWS.md`, or `NULL` if not found.
#' @keywords internal
#' @noRd
get_latest_version_news <- function(pkg) {
  # Get the major version as a string like "3."
  ver <- utils::packageVersion(pkg)
  major_ver <- ver$major

  # Load the news database (a "news_db" object)
  news_db <- tryCatch(utils::news(package = pkg), error = function(e) NULL)
  if (is.null(news_db) || !inherits(news_db, "news_db")) return(NULL)

  # Filter versions that start with current major version
  keep <- grepl(paste0("^", major_ver, "."), news_db$Version)
  if (!any(keep)) return(NULL)

  # Combine matching entries into a single string
  entries <- paste0(
    "## Version ", news_db$Version[keep],"\n",
    news_db$Text[keep]
  )
  paste(entries, collapse = "\n\n")
}

