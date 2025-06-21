#' Save a Function Definition to a File
#'
#' Dispatches to a method based on the type of input (`function`, `expression`, or `character`).
#' Writes a valid R function definition to a `.R` file, assigning it the provided or inferred name.
#'
#' @param fn The function code to save. Can be a function object, an `expression()` containing a function,
#'   or a character string with valid R function code.
#' @param ... Passed to class-specific methods.
#'
#' @return Invisibly returns the normalized file path.
#'
#' @export
save_function_to_file <- function(fn, fn_name, file, ...) {
UseMethod("save_function_to_file")
}

#' @describeIn save_function_to_file Save a function defined as an expression
#'
#' @param fn_name Required name to assign the function in the saved file.
#' @param file Optional file name to write to. Defaults to `<fn_name>.R`.
#'
#' @details
#' The expression must contain a function definition, such as `expression(function(x) x^2)`.
#' If this structure is not detected, an error is raised.
#'
#' @examples
#' \dontrun{
#' save_function_to_file(expression(function(x) x^2), fn_name = "square")
#' }
#'
#' @export
save_function_to_file.function <- function(fn, fn_name = NULL, file = NULL, ...) {
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

#' @describeIn save_function_to_file Save a function defined as an expression
#'
#' @param fn_name Required name to assign the function in the saved file.
#' @param file Optional file name to write to. Defaults to `<fn_name>.R`.
#'
#'
#' @details
#' The expression must contain a function definition, such as `expression(function(x) x^2)`.
#' If this structure is not detected, an error is raised.
#'
#' @examples
#' \dontrun{
#' save_function_to_file(expression(function(x) x^2), fn_name = "square")
#' }
#'
#' @export
save_function_to_file.expression <- function(fn, fn_name, file = NULL, ...) {
  if (missing(fn_name)) stop("You must supply `fn_name` for expressions.")

  expr_text <- paste(deparse(fn[[1]]), collapse = "\n")

  if (!is.call(fn[[1]]) || as.character(fn[[1]][[1]]) != "function") {
    stop("The expression must be a function definition, e.g., `expression(function(x) x)`.")
  }

  if (is.null(file)) {
    file <- paste0(fn_name, ".R")
  }

  code <- paste0(fn_name, " <- ", expr_text)
  writeLines(code, file)

  message("Function expression saved as '", fn_name, "' to ", normalizePath(file))
  invisible(normalizePath(file))
}

#' @describeIn save_function_to_file Save a function from a character string
#'
#' @param fn_name Required name to assign the function in the output file.
#' @param file Optional file name to write to. Defaults to `<fn_name>.R`.
#'
#' @details
#' The string must parse as valid R code starting with `function(...)`. This method is useful
#' when saving LLM-generated code or string-encoded snippets that define a function.
#'
#' @examples
#' \dontrun{
#' save_function_to_file("function(x) log(x + 1)", fn_name = "logplus1")
#' }
#'
#' @export
save_function_to_file.character <- function(fn, fn_name, file = NULL, ...) {
  if (missing(fn_name)) stop("You must supply `fn_name` for character input.")

  ## regex to validate that it's a function definition
  if(!grep("^function\\s*\\(", fn, perl = TRUE)) {
    stop("The character string must define a function, e.g., 'function(x) x^2'.")
  }

  if (is.null(file)) {
    file <- paste0(fn_name, ".R")
  }

  code <- paste0(fn_name, " <- ", fn)
  writeLines(code, file)

  message("Function string saved as '", fn_name, "' to ", normalizePath(file))
  invisible(normalizePath(file))
}

