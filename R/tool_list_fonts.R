#' List available font families
#'
#' @return a character vector
#' @noRd
list_available_fonts <- function() {
  unique(systemfonts::system_fonts()$family)
}
#' Define a tool to list available fonts
#'
#' Defines a tool that lists all available font families on the system for
#' a chatbot. This is intended to be used with an `ellmer::Chat` object.
#'
#' @return An S7 `ToolDef` object.
#' @examples
#' \dontrun{
#' chat <- ellmer::chat_openai()
#'
#' chat$register_tool(tool_list_fonts)
#'
#' chat$chat('What font families are on this system')
#'
#' }
#' @export
tool_list_fonts <- function() {
  ellmer::tool(
  list_available_fonts,
  'Lists the available font familes on the system'
  )
}
