top <- getwd()
tags <- names(git2r::tags())

#' Turn ordinary strings into valid "slugs" so we can use them in URLs
#' @param content (character) The string to slugify
slugify <- function(content) { 
  gsub("[^a-z0-9]", "-", tolower(content))
}

if (!dir.exists("public/materials")) {
  dir.create("public/materials", recursive = TRUE)
}

#' First, we determine which tags are available to build and what their human-
#' readable names are. GitHub's tag naming feature is used to control the human-
#' readable name.
releases <- gh::gh("/repos/nceas/sasap-training/releases")
tags <- vapply(releases, "[[", "", "tag_name")
tag_names <- vapply(vapply(releases, "[[", "", "name"), slugify, "")

#' Then, for each tagged release, build all the materials and move the output
#' into the public folder
for (tag in tags) {
  message("Building ", tag)
  git2r::checkout(".", tag)

  for (material in dir("materials")) {
    message("Building book", material, " on tag ", tag)

    setwd(file.path("materials", material))

    remotes::install_deps(".")
    bookdown::render_book("index.Rmd", 
                          c("bookdown::gitbook"),
                          clean_envir = FALSE)
    
    message("Copying _book folder from ", getwd(), " to ", file.path(top, "public", "materials", material, tag))
    copy_dest <- file.path(top, "public", "materials", paste0(material, "-", tag_names[which(tag %in% tags)]))
    system2("cp", c("-r", "_book", copy_dest))

    message("Materials folder contains:", dir(file.path(top, "public", "materials")))
    unlink("_book", recursive = TRUE)

    setwd(top)
  }
}
