#' Validate a ggplot2 Theme Function
#'
#' Checks whether a given function returns a valid `ggplot2` theme object when called with no arguments.
#' The function is executed in a separate R process to reduce risk.
#'
#' @param f A function expected to return a `ggplot2::theme` object. It must take no arguments.
#'
#' @return Invisibly returns `TRUE` if the function is valid. Otherwise, an error is thrown.
#'
#' @details
#' This function is useful for validating dynamically generated theme functions,
#' such as those produced by [make_ai_theme()]. The function `f` is called inside a
#' subprocess using [callr::r()] to limit the risk of evaluating untrusted or erroneous code.
#' However, it's important to note that not all risk is mitigated.
#'
#' The result must inherit from both `"theme"` and `"gg"`, as expected from objects
#' returned by standard `ggplot2` theme functions like [ggplot2::theme_minimal()].
#'
#' Note that the theme function must not require any arguments (e.g., `base_size`)
#' in order to be validated correctly.
#'
#' @examples
#' check_theme(ggplot2::theme_minimal)
#'
#' @export
check_theme <- function(f){
  if (!is.function(f)) {
    stop("Input is not a function.", call. = FALSE)
  }


  # TODO: should I look for strings of nasty functions (unlink, system) here?

  result <- tryCatch({
    callr::r(function(fn) {
      # try calling it without any arguments, still potentially dangerous!
      out <- fn()
      if (!all(c("theme", "gg") %in% class(out))) {
        stop("Function did not return a ggplot2 theme.", call. = FALSE)
      }
      TRUE
    }, args = list(fn = f), spinner = FALSE)
  }, error = function(e) {
    stop("Theme function failed validation: ", e$message, call. = FALSE)
  })

  invisible(result)
}
