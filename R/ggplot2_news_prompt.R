#' Create an LLM system prompt using ggplot2 NEWS
#'
#' This function creates a system prompt for an LLM that includes the contents of the
#' news for the latest major version of **ggplot2**. This is useful for
#' creating [`ellmer::Chat`] objects that are aware of recent changes in the package.
#' However, doing this will incur extra costs from the LLM provider (if being billed per-token).
#'
#' @return an `ellmer_prompt` object with the system prompt suitable for use creating
#' an `ellmer::Chat` object.
#'
#' @export
ggplot2_news_prompt <- function(){
  news_md <- get_latest_version_news("ggplot2")
  if (is.null(news_md)) {
    stop("No NEWS.md file found for ggplot2 package.", call. = FALSE)
  }


  prompt_file <- system.file("prompts", "ggplot2-news-system-prompt.md", package = "ggthemeAI")

  ellmer::interpolate_file(prompt_file,
                              news = paste(news_md, collapse = "\n"))
}
