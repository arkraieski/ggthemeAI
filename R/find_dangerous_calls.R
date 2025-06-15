#' Detect Dangerous Function Calls in an R Expression
#'
#' Recursively inspects an R expression (typically parsed code) and identifies any calls
#' to functions listed in a forbidden list. This is useful for validating code generated
#' by large language models (LLMs) or user input before evaluating it.
#'
#' @param expr An R expression or language object, typically returned by [base::parse()].
#' @param forbidden A character vector of function names to flag as disallowed.
#' Defaults to `c("system", "system2", "unlink", "download.file")`.
#'
#' @return A character vector of disallowed function names that were found in the expression.
#' If none were found, returns `character(0)`.
#'
#' @details
#' This function traverses the expression tree recursively and checks whether any of the
#' function calls match names in the `forbidden` list. It does not evaluate the expression,
#' and it does not inspect calls constructed dynamically (e.g., via `get()` or `match.fun()`).
#' Only syntactic references to function names are detected.
#'
#' This function is useful in contexts where LLMs or other tools generate R code dynamically,
#' and you want to enforce a safety layer before parsing or evaluation.
#'
#' @examples
#' # Basic example with raw code
#' find_dangerous_calls(parse(text = "system('ls')"))
#'
#' # Multiple disallowed calls
#' expr <- parse(text = "unlink('file'); system2('echo', 'hi')")
#' find_dangerous_calls(expr)
#'
#' # Safe code
#' find_dangerous_calls(parse(text = "mean(c(1, 2, 3))"))
#'
#' @export
find_dangerous_calls <- function(expr, forbidden = c("system", "system2", "unlink", "download.file")) {
  bad_calls <- character()

  # AST traversal
  walk <- function(e) {
    if (is.call(e)) {
      fn <- as.character(e[[1]])
      if (fn %in% forbidden) {
        bad_calls <<- c(bad_calls, fn)
      }
      lapply(e[-1], walk)
    }
  }

  walk(expr)
  unique(bad_calls)
}
