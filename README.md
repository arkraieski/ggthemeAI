
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggthemeAI

<!-- badges: start -->
<!-- badges: end -->

The goal of ggthemeAI is to make it quicker to prototype highly-custom
‘ggplot2’ themes. It uses LLMs to rapidly generate theme functions
according to the visual characteristics you describe.

Imagine some `theme_x()` function that might look cool. Now, if you can
describe it in natural language, you can try a version of it instantly!

It uses [ellmer](https://ellmer.tidyverse.org/index.html) as a chat
interface to various LLM providers.

## Installation

You can install the development version of ggthemeAI like so:

``` r
pak::pkg_install('arkraieski/ggthemeAI')
```

## Example

This example shows you how to get started creating themes with
`ggthemeAI`. The `make_ai_theme()` function takes a chat object and a
description of the theme you want, and returns a ggplot2 theme function
that you can use in your plots.

``` r
library(ggplot2)
library(ellmer)
library(ggthemeAI)


chat <- chat_openai() # can customize system prompt here if desired
#> Using model = "gpt-4.1".

theme_solarized <- make_ai_theme(chat, 'solarized dark take on the default ggplot2 theme')
#> function(base_size = 11, base_family = "") {
#>   solarized_bg <- "#002b36"
#>   solarized_fg <- "#839496"
#>   solarized_grid <- "#073642"
#>   solarized_axis <- "#586e75"
#>   solarized_title <- "#93a1a1"
#>   solarized_strip_bg <- "#073642"
#>   solarized_strip_text <- "#b58900"
#>   theme_grey(base_size = base_size, base_family = base_family) %+replace%
#>     theme(
#>       line = element_line(colour = solarized_grid),
#>       rect = element_rect(fill = solarized_bg, colour = NA),
#>       text = element_text(colour = solarized_fg, family = base_family, size = 
#> base_size),
#>       plot.background = element_rect(fill = solarized_bg, colour = NA),
#>       panel.background = element_rect(fill = solarized_bg, colour = NA),
#>       panel.border = element_rect(fill = NA, colour = solarized_bg),
#>       panel.grid.major = element_line(colour = solarized_grid, size = 0.5),
#>       panel.grid.minor = element_line(colour = solarized_grid, size = 0.25),
#>       axis.title = element_text(colour = solarized_title, size = rel(1.1)),
#>       axis.text = element_text(colour = solarized_fg),
#>       axis.text.x = element_text(margin = margin(t = 2.8, unit = "pt")),
#>       axis.text.y = element_text(margin = margin(r = 2.8, unit = "pt")),
#>       axis.ticks = element_line(colour = solarized_axis),
#>       axis.line = element_line(colour = solarized_axis),
#>       legend.background = element_rect(fill = solarized_bg, colour = NA),
#>       legend.key = element_rect(fill = solarized_bg, colour = NA),
#>       legend.text = element_text(colour = solarized_fg),
#>       legend.title = element_text(colour = solarized_title),
#>       plot.title = element_text(colour = solarized_title, size = rel(1.2), face
#> = "bold", hjust = 0),
#>       plot.subtitle = element_text(colour = solarized_title, size = rel(1), 
#> hjust = 0),
#>       plot.caption = element_text(colour = solarized_fg, size = rel(0.85), 
#> hjust = 1),
#>       strip.background = element_rect(fill = solarized_strip_bg, colour = NA),
#>       strip.text = element_text(colour = solarized_strip_text, face = "bold", 
#> size = rel(1)),
#>       complete = TRUE
#>     )
#> }

ggplot(mtcars, aes(x = hp)) + 
  geom_histogram(binwidth = 25) +
  labs(title = "Horsepower Distribution") +
  theme_solarized() # LLM wrote the code for this function
```

<img src="man/figures/README-example-1.png" width="100%" />

It should be noted that `make_ai_theme()` is **not** a pure function.
This is by design. In addition to return the new theme, the state of the
R6 Chat is updated. You can then chat with the LLM to have it explain
the theme or iterate on it.

There’s also a `check_theme()` function that checks if a function is
actually a ggplot2 theme.

## Use cases

- Rapid design and prototyping of custom themes for stylized
  infographics
- Trying out a bunch of drastically different looks quickly
- Starting a custom theme without starting from scratch
- Iterating on themes conversationally
- Learning ggplot2 and improving skills: see working examples of
  extensively-customized themes and then have the LLM explain it
- Accessibility use cases
  - Designing/modifying themes for visually-impaired users
  - Shiny: you can let users customize a plot to their perceptual needs
    in natural language. This can make your app more accessible to
    everyone but especially low-vision, neurodivergent, and colorblind
    users (and others surely)

## Warnings/Disclaimers

It’s not guaranteed that the themes produced by this package will:

1.  Avoid using deprecated ggplot2 features
2.  Adhere to “best-practices” in design, accessibility, etc.
3.  Not do nasty things like calling `unlink()` (though validating the
    safety of generated functions is a development priority)

Also, it’s worth thinking about how custom fonts (and other design
choices like that) could enhance your themes, instead of just always
using the LLM output and never trying to do anything more interesting.
