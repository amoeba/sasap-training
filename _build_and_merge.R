top <- getwd()
tags <- names(git2r::tags())

if (!dir.exists("public/materials")) {
  dir.create("public/materials", recursive = TRUE)
}

# Build all books in the books subdir
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
    
    file.copy("_book", file.path(top, "public", "materials", material, tag), recursive = TRUE)
    unlink("_book", recursive = TRUE)

    setwd(top)
  }
}
