#' Create an LLM system prompt using ggplot2 Documentation
#'
#' This function creates a system prompt for an LLM that includes the contents of help pages
#' for 'ggplot2' functions related to themes.  This is useful for creating
#' [`ellmer::Chat`] objects that are fully aware of the documented state of the API.
#'
#' @return an `ellmer_prompt` object with the system prompt suitable for use creating
#' an `ellmer::Chat` object.
#'
#' @export
ggplot2_doc_prompt <- function(){

  db <- tools::Rd_db("ggplot2")
  theme_rd <- db[['theme.Rd']]
  element_rd <- db[['element.Rd']]

  docs_list <- list(theme_rd, element_rd)

  formatted_list <- lapply(docs_list, function(rd) {
    txt_output <- character() # doing this to shut up "no visible binding for global variable"
    con <- textConnection("txt_output", open = "w", local = TRUE)
    tools::Rd2txt(rd, out = con)
    close(con)
    paste(txt_output, collapse = "\n")
  })


  prompt_file <- system.file("prompts", "ggplot2-doc-system-prompt.md", package = "ggthemeAI")
  ellmer::interpolate_file(prompt_file,
                           theme_help = formatted_list[[1]],
                           element_help = formatted_list[[2]])
}
