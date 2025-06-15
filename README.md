
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
#>   # Solarized dark palette
#>   bg      <- "#002b36"
#>   fg      <- "#839496"
#>   fg_light <- "#93a1a1"
#>   fg_strong <- "#eee8d5"
#>   grid    <- "#073642"
#>   grid_minor <- "#1a343f"
#>   accent  <- "#b58900"
#>   
#>   theme_grey(base_size = base_size, base_family = base_family) %+replace%
#>     theme(
#>       # Backgrounds
#>       plot.background      = element_rect(fill = bg, colour = NA),
#>       panel.background     = element_rect(fill = bg, colour = NA),
#>       legend.background    = element_rect(fill = bg, colour = NA),
#>       legend.key           = element_rect(fill = bg, colour = NA),
#>       # Grid lines
#>       panel.grid.major     = element_line(colour = grid, size = 0.6),
#>       panel.grid.minor     = element_line(colour = grid_minor, size = 0.3),
#>       # Text
#>       text                 = element_text(family = base_family, size = 
#> base_size, colour = fg_strong),
#>       plot.title           = element_text(size = rel(1.2), face = "bold", 
#> colour = fg_strong),
#>       plot.subtitle        = element_text(size = rel(1), colour = fg),
#>       plot.caption         = element_text(size = rel(0.9), colour = fg_light),
#>       axis.title           = element_text(face = "bold", colour = fg_strong),
#>       axis.text            = element_text(colour = fg_light),
#>       axis.text.x          = element_text(colour = fg_light),
#>       axis.text.y          = element_text(colour = fg_light),
#>       # Axes
#>       axis.ticks           = element_line(colour = fg_light),
#>       axis.line            = element_line(colour = fg_light),
#>       # Legend
#>       legend.text          = element_text(colour = fg_light),
#>       legend.title         = element_text(face = "bold", colour = fg_strong),
#>       legend.position      = "right",
#>       # Strips
#>       strip.background     = element_rect(fill = grid, colour = NA),
#>       strip.text           = element_text(face = "bold", colour = accent),
#>       # Remove default borders
#>       panel.border         = element_blank(),
#>       # Facet label background
#>       strip.placement      = "outside"
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

Lastly, for use in Shiny apps, you need to be careful about security.
Using a hardened system prompt is a good idea if you don’t want people
doing kooky things in your app.
