#' Create a ggplot2 Theme Function Using an LLM
#'
#' Generates a new `ggplot2` theme function by prompting a large language model
#' (LLM) with a user-supplied description. The generated code is parsed,
#' evaluated, and returned as a usable theme function.
#'
#' @param chat A `Chat` R6 object from the [ellmer] package
#' @param theme_prompt A character string describing the desired theme style.
#' @param image An optional object of class `ellmer::ContentImageInline`, created by calling [`ellmer::content_image_url()`] or similar. The image will be added to the data that is sent to the LLM so it can be referenced in `theme_prompt`.
#' @param return_type `"function"`, `"expression"`, or `"character"`. Determines the type of object returned. A function is returned by default. See Value.
#'
#' @return A function that can be used as a `ggplot2` theme. If `return_type` is set to `"expression"` or `"character"`, the raw code is returned instead in those formats instead. This allows the user inspect the code for safety before parsing/evaluating to create the final, usable function.
#'
#' @details
#' The theme description is embedded into a prompt that is sent to the LLM.
#' The resulting response is expected to be valid R code for a theme function.
#' If the response cannot be parsed as a function, an error is raised.
#'
#' The full conversation with the LLM remains accessible via the `chat` object,
#' which may be useful for debugging or iteration.
#'
#' **Warning:** You **must** set `return_type` to `"expression"` or `"character"`
#' if you do not want to run LLM-generated code before review!
#'
#' @examples
#' \dontrun{
#' library(ellmer)
#' library(ggplot2)
#'
#' theme_neon_dark <- make_ai_theme(chat,
#'   "dark theme with neon green accents")
#'  ggplot(mtcars, aes(x = hp)) + geom_histogram() +
#'   theme_neon_dark()
#' }
#'
#' @export
make_ai_theme <- function(chat, theme_prompt, image = NULL, return_type = c('function', 'expression', 'character')){
  if(!inherits(chat, 'Chat')) stop(
    "chat must be an ellmer Chat object",
    call. = FALSE
  )

  return_type <- match.arg(return_type)

  prompt_file <- system.file('prompts',
                             'custom-theme-prompt.md',
                             package = 'ggthemeAI')

  prompt <- ellmer::interpolate_file(prompt_file,
                             theme_request = theme_prompt)

  # Build args for chat$chat()
  chat_args <- list(prompt)
  if (!is.null(image)) {
    # add image to the list
    if (!inherits(image, 'ellmer::ContentImageInline')) {
      stop("image must be an ellmer_image object", call. = FALSE)
    }
    chat_args[[ length(chat_args) + 1 ]] <- image
  }

  # Call with optional image arg
  theme_text <- do.call(chat$chat, chat_args)

  if(return_type == 'character') {
    return(theme_text)
  }

  # intentional side effect: you can chat w/ the LLM about the theme later
  #theme_text <- chat$chat(prompt)

  theme_function <- tryCatch({
    expr <- parse(text = theme_text)

    bad_calls <- find_dangerous_calls(expr)
    if (length(bad_calls)) {
      stop("LLM response contains disallowed functions: ",
           paste(bad_calls, collapse = ", "),
           call. = FALSE)
    }

    if(return_type == 'expression') {
      return(expr)
    }

    eval(expr)
  }, error = function(e) {
    stop("Failed to parse or evaluate the LLM response as a function.\n\n",
         "Original error: ", e$message, "\n\n",
         "LLM response was:\n", theme_text,
         call. = FALSE)
  })

  if (!is.function(theme_function)){
    stop('The response from the LLM wasn\'t an R function.
         Maybe you should yell at it. Or try a different LLM provider/model',
         call. = FALSE)
  }

  theme_function
}
