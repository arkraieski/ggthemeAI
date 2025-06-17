#' Detect Dangerous Function Calls in an R Expression
#'
#' Recursively inspects an R expression and identifies any calls
#' to functions listed in a forbidden list. This is useful for validating code generated
#' by large language models (LLMs) or user input before evaluating it.
#'
#' @param expr An R expression or language object, typically returned by [base::parse()].
#' @param additional_forbidden A character vector of function names to flag as disallowed. These are combined with the vector of function names from [default_dangerous_calls()]
#' @param block_namespace_access A logical indicating whether to block namespace access operators (`::` and `:::`) in the expression.
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
#' # Using base:: syntax
#' find_dangerous_calls(parse(text = "base::system2('echo', 'hi')" ))
#'
#' # Using namespace access with `::` or `:::`
#' find_dangerous_calls(parse(text = 'purr::map(1:3, ~ base::system("echo hi"))'))
#'
#' # Safe code
#' find_dangerous_calls(parse(text = "mean(c(1, 2, 3))"))
#' @export
find_dangerous_calls <- function(expr,
                                 additional_forbidden = NULL,
                                 block_namespace_access = TRUE) {

  forbidden <-forbidden <- unique(c(default_dangerous_calls(), additional_forbidden))
  bad_calls <- character()

  walk <- function(e) {
    if (is.call(e)) {
      fn <- e[[1]]

      # Always block `::` and `:::` if that flag is on
      # note that this doesn't block calls to functions that are already loaded
      if (block_namespace_access && is.symbol(fn)) {
        ns_op <- as.character(fn)
        if (ns_op %in% c("::", ":::")) {
          bad_calls <<- c(bad_calls, ns_op)
        }
      }

      # Handle base::system or pkg:::system
      if (is.call(fn) && (as.character(fn[[1]]) %in% c("::", ":::"))) {
        func_name <- as.character(fn[[3]])
        if (func_name %in% forbidden) {
          bad_calls <<- c(bad_calls, func_name)
        }
      }

      # Handle plain function calls like system("...")
      else if (is.symbol(fn)) {
        func_name <- as.character(fn)
        if (func_name %in% forbidden) {
          bad_calls <<- c(bad_calls, func_name)
        }
      }

      # Recurse into all arguments of the call
      lapply(as.list(e), walk)
    } else if (is.recursive(e)) {
      lapply(as.list(e), walk)
    }
  }

  if (is.function(expr)) {
    walk(body(expr))
  } else if (is.call(expr) || is.expression(expr) || is.language(expr)) {
    walk(expr)
  } else {
    stop("Unsupported input type. Use a function or quoted expression.")
  }

  unique(bad_calls)
}
