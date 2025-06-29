% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_dangerous_calls.R
\name{find_dangerous_calls}
\alias{find_dangerous_calls}
\title{Detect Dangerous Function Calls in an R Expression}
\usage{
find_dangerous_calls(
  expr,
  additional_forbidden = NULL,
  block_namespace_access = TRUE
)
}
\arguments{
\item{expr}{An R expression or language object, typically returned by \code{\link[base:parse]{base::parse()}}.}

\item{additional_forbidden}{A character vector of function names to flag as disallowed. These are combined with the vector of function names from \code{\link[=default_dangerous_calls]{default_dangerous_calls()}}}

\item{block_namespace_access}{A logical indicating whether to block namespace access operators (\code{::} and \code{:::}) in the expression.}
}
\value{
A character vector of disallowed function names that were found in the expression.
If none were found, returns \code{character(0)}.
}
\description{
Recursively inspects an R expression and identifies any calls
to functions listed in a forbidden list. This is useful for validating code generated
by large language models (LLMs) or user input before evaluating it.
}
\details{
This function traverses the expression tree recursively and checks whether any of the
function calls match names in the \code{forbidden} list. It does not evaluate the expression,
and it does not inspect calls constructed dynamically (e.g., via \code{get()} or \code{match.fun()}).
Only syntactic references to function names are detected.

This function is useful in contexts where LLMs or other tools generate R code dynamically,
and you want to enforce a safety layer before evaluation.
}
\examples{
# Basic example with raw code
find_dangerous_calls(parse(text = "system('ls')"))

# Multiple disallowed calls
expr <- parse(text = "unlink('file'); system2('echo', 'hi')")
find_dangerous_calls(expr)

# Using base:: syntax
find_dangerous_calls(parse(text = "base::system2('echo', 'hi')" ))

# Using namespace access with `::` or `:::`
find_dangerous_calls(parse(text = 'purr::map(1:3, ~ base::system("echo hi"))'))

# Safe code
find_dangerous_calls(parse(text = "mean(c(1, 2, 3))"))
}
