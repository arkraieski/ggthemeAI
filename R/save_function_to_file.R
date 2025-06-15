#' Save a Function to a File
#'
#' Writes the source code of a function to a `.R` file in the current working directory.
#' The saved file will include the assignment (`name <- function(...)`) so it can be sourced back in.
#'
#' @param fn A function object. This can be any function, including anonymous functions or LLM-generated ones.
#' @param fn_name Optional. A name to assign the function in the output file. If omitted, the function is named
#'        using the expression passed to `fn` (e.g., `my_fun`).
#' @param file Optional. The file name to save to. Defaults to `"<fn_name>.R"` in the working directory.
#'
#' @return Invisibly returns the normalized file path.
#'
#' @details
#' This is useful for exporting dynamically created or LLM-generated functions,
#' such as those created by [make_ai_theme()]. Only the function's definition is written —
#' any captured environment or side objects will not be preserved.
#'
#' The function is deparsed and written as text, so certain corner cases like primitives or compiled functions
#' may not serialize as expected.
#'
#' @examples
#' \dontrun{
#' my_fun <- function(x) x^2 + 1
#' save_function_to_file(my_fun)
#'
#' # Save anonymously created function with a given name
#' save_function_to_file(function(x) log(x + 1), fn_name = "logplus1")
#' }
#'
#' @export
save_function_to_file <- function(fn, fn_name = NULL, file = NULL) {
  if (!is.function(fn)) {
    stop("`fn` must be a function.")
  }

  if (is.null(fn_name)) {
    fn_name <- deparse(substitute(fn))
  }

  if (!is.character(fn_name) || length(fn_name) != 1 || fn_name == "") {
    stop("`fn_name` must be a non-empty character string.")
  }

  if (is.null(file)) {
    file <- paste0(fn_name, ".R")
  }

  fn_code <- paste0(fn_name, " <- ", paste(deparse(fn), collapse = "\n"))
  writeLines(fn_code, file)

  message("Function '", fn_name, "' saved to ", normalizePath(file))
  invisible(normalizePath(file))
}
