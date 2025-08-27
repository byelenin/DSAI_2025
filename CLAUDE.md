# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Quarto-based academic course website for "Data Science and AI for Economists" taught at Nanjing University Business School. The course covers practical applications of data science and AI in economics, including spatial data analysis, web scraping, text analysis, and OCR techniques.

## Architecture

This is a **Quarto website project** that generates static HTML pages from `.qmd` (Quarto Markdown) files. The project structure follows Quarto's website conventions:

- **Source files**: Root directory contains `.qmd` files for course content
- **Build output**: `docs/` directory contains the generated HTML website
- **Configuration**: `_quarto.yml` defines the website structure, navigation, and build settings
- **Content organization**: 
  - Course pages (syllabus, schedule, project) as `.qmd` files
  - Slides in `slides/` directory (HTML presentations)
  - Static assets in `Pics/` directory
  - Custom styling in `Css/custom.scss`

The website uses the Zephyr theme with custom SCSS styling and includes a navbar, sidebar navigation, and search functionality.

## Development Commands

### Building and Previewing
```bash
# Preview the website locally with live reload
quarto preview

# Render all pages to docs/ directory
quarto render

# Render a specific page
quarto render index.qmd
```

### Project Management
```bash
# Check Quarto installation and version
quarto --version

# Validate project configuration
quarto check
```

## Key Configuration Files

- `_quarto.yml`: Main website configuration including navigation, theme, and output settings
- `DSAI_2024.Rproj`: R project file for RStudio integration
- Individual `.qmd` files contain YAML frontmatter for page-specific settings

## Content Structure

- **Course content**: Written in Quarto Markdown (`.qmd`) with R code chunks where needed
- **Slides**: Self-contained HTML presentations in `slides/` directory
- **Navigation**: Defined in `_quarto.yml` with navbar and sidebar configuration
- **Styling**: Zephyr theme customized with `Css/custom.scss`

## Development Notes

- The site outputs to `docs/` for GitHub Pages hosting
- Uses R/RStudio ecosystem with knitr for document processing
- Custom fonts and styling defined in CSS files in `slides/Lec0/CSS/`
- Site URL configured for GitHub Pages deployment at `byelenin.github.io/DSAI_2024/`