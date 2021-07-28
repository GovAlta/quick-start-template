# knitr::stitch_rmd(script="manipulation/mlm-scribe.R", output="stitched-output/manipulation/mlm-scribe.md")
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
# source("manipulation/osdh/ellis/common-ellis.R")
# base::source(file="dal/osdh/arch/benchmark-client-program-arch.R") #Load retrieve_benchmark_client_program

# ---- load-packages -----------------------------------------------------------
import::from("magrittr", "%>%")
requireNamespace("DBI")
requireNamespace("odbc")
requireNamespace("tibble")
requireNamespace("readr"                      )  # remotes::install_github("tidyverse/readr")
library("dplyr"                      )
requireNamespace("checkmate"                  )
requireNamespace("testit"                     )
requireNamespace("config"                     )
requireNamespace("babynames"                  )
requireNamespace("TeachingDemos"              )
requireNamespace("OuhscMunge"                 )  # remotes::install_github("OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------

# Constant values that won't change.
# config      <- config::get()
# https://github.com/OuhscBbmc/BbmcResources/blob/master/instructions/odbc-dsn.md
dsn                   <- "EDB1_old_driver" # one per database, typically in config file
# SQL that will extract the table(s)
sql <- "
  SELECT TOP 1000 
    [FACT_NAME], [SERVICE_FACT_TYPE_ID]
  FROM [EDB].[dbo].[WORP_FACTS]
"
cnn <- DBI::dbConnect(odbc::odbc(),dsn=dsn) # =den --> needs to go into config file
ds <- DBI::dbGetQuery(cnn, sql) # actual extract
DBI::dbDisconnect(cnn) # hang up the phone
rm(dsn, cnn, sql) # clean up

# ---- declare-functions -------------------------------------------------------
# custom function for HTML tables
neat <- function(x, output_format = "html"){
  # knitr.table.format = output_format
  if(output_format == "pandoc"){
    x_t <- knitr::kable(x, format = "pandoc")
  }else{
    x_t <- x %>%
      # x %>%
      # neat() %>%
      knitr::kable(format=output_format) %>%
      kableExtra::kable_styling(
        bootstrap_options = c("striped", "hover", "condensed","responsive"),
        # bootstrap_options = c( "condensed"),
        full_width = F,
        position = "left"
      )
  }
  return(x_t)
}
# Note: when printing to Word or PDF use `neat(output_format =  "pandoc")`


prints_folder <- paste0("./analysis/.../prints/")
if(!file.exists(prints_folder)){
  dir.create(file.path(prints_folder))
}

ggplot2::theme_set(
  ggplot2::theme_bw(
  )+
    theme(
      strip.background = element_rect(fill="grey95", color = NA)
    )
)
quick_save <- function(g,name,...){
  ggplot2::ggsave(
    filename = paste0(name,".jpg"),
    plot     = g,
    device   = "jpg",
    path     = prints_folder,
    # width    = width,
    # height   = height,
    # units = "cm",
    dpi      = 'retina',
    limitsize = FALSE,
    ...
  )
}

# ---- load-data ---------------------------------------------------------------


# ---- inspect-data ------------------------------------------------------------


# ---- tweak-data --------------------------------------------------------------


# ---- table-1 -----------------------------------------------------------------


# ---- graph-1 -----------------------------------------------------------------


# ---- graph-2 -----------------------------------------------------------------

# ---- save-to-disk ------------------------------------------------------------
# path <- "./analysis/.../report-isolated.Rmd"
# rmarkdown::render(
#   input = path ,
#   output_format=c(
#     "html_document"
#     # "word_document"
#     # "pdf_document"
#   ),
#   clean=TRUE
# )



