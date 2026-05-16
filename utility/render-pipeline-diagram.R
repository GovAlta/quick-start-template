# utility/render-pipeline-diagram.R
#
# Purpose : Extract the canonical Mermaid pipeline diagram from
#           manipulation/pipeline.md and render it to a static image.
#
# Source  : manipulation/pipeline.md — the ```mermaid block tagged with
#           <!-- PIPELINE-DIAGRAM-SOURCE --> on the line immediately before it
# Output  : manipulation/images/pipeline-architecture.jpg
#
# Insertion sites are tagged with <!-- PIPELINE-DIAGRAM --> in the repo.
# After rendering, this script scans and reports all tagged files.
#
# Dependencies:
#   - Node.js / npx on the system PATH  (for @mermaid-js/mermaid-cli)
#   - R package: magick  (PNG → JPG conversion and exact-dimension resizing)
#
# Usage:
#   Rscript utility/render-pipeline-diagram.R
#   # or interactively:
#   source("utility/render-pipeline-diagram.R")
#
# Embedding the output:
#   Markdown : <!-- PIPELINE-DIAGRAM -->
#              ![Pipeline Architecture](manipulation/images/pipeline-architecture.jpg)
#   Quarto   : <!-- PIPELINE-DIAGRAM -->
#              ![](../../manipulation/images/pipeline-architecture.jpg){width="100%"}
#
# -----------------------------------------------------------------------------

library(magick)

# ── Config ────────────────────────────────────────────────────────────────────
source_md  <- "manipulation/pipeline.md"
output_jpg <- "manipulation/images/pipeline-architecture.jpg"

width_in  <- 8.5    # output width  in inches
height_in <- 2.5    # output height in inches
dpi       <- 150    # resolution  (150 dpi → 1275 × 375 px at defaults)

# ── 1. Extract the ```mermaid block tagged with <!-- PIPELINE-DIAGRAM-SOURCE -->
lines      <- readLines(source_md, warn = FALSE)
src_marker <- "<!-- PIPELINE-DIAGRAM-SOURCE -->"
marker_ix  <- which(trimws(lines) == src_marker)[1]
if (is.na(marker_ix)) {
  stop(
    "No <!-- PIPELINE-DIAGRAM-SOURCE --> marker found in: ", source_md, "\n",
    "Add this comment on the line immediately before the ```mermaid fence."
  )
}

start_ix <- which(grepl("^```mermaid", lines) & seq_along(lines) > marker_ix)[1]
if (is.na(start_ix)) stop("No ```mermaid block found after the marker in: ", source_md)

fence_ix <- which(grepl("^```\\s*$", lines))
end_ix   <- fence_ix[fence_ix > start_ix][1]
if (is.na(end_ix)) stop("Unclosed mermaid block in: ", source_md)

mermaid_code <- paste(lines[(start_ix + 1L):(end_ix - 1L)], collapse = "\n")

# ── 2. Write to a temp .mmd file ─────────────────────────────────────────────
tmp_mmd <- tempfile(fileext = ".mmd")
tmp_png <- tempfile(fileext = ".png")
on.exit(suppressWarnings(file.remove(c(tmp_mmd, tmp_png))), add = TRUE)
writeLines(mermaid_code, tmp_mmd)

# ── 3. Render via Mermaid CLI (npx — auto-installs on first run) ──────────────
width_px  <- round(width_in  * dpi)
height_px <- round(height_in * dpi)

cmd <- paste(
  "npx --yes @mermaid-js/mermaid-cli",
  sprintf('-i "%s"', normalizePath(tmp_mmd, winslash = "/")),
  sprintf('-o "%s"', normalizePath(tmp_png, winslash = "/", mustWork = FALSE)),
  sprintf("-w %d", width_px),
  "-b white"          # white background (JPEG does not support transparency)
)

message("Rendering mermaid diagram via mmdc …")
rc <- system(cmd)
if (rc != 0L) {
  stop(
    "mmdc exited with code ", rc, ".\n",
    "Make sure Node.js and npx are on the system PATH.\n",
    "  Windows install: https://nodejs.org  (or run setup-nodejs.ps1)\n",
    "  Verify:  node --version && npx --version"
  )
}

# ── 4. Resize / pad to exact dimensions ───────────────────────────────────────
img <- image_read(tmp_png)

# Scale so width matches exactly; then extend/pad vertically to target height
geo_w  <- geometry_size_pixels(width = width_px)
img    <- image_resize(img, geo_w)

geo_wh <- geometry_size_pixels(width = width_px, height = height_px)
img    <- image_extent(img, geo_wh, gravity = "Center", color = "white")

# Ensure output directory exists
dir.create(dirname(output_jpg), showWarnings = FALSE, recursive = TRUE)

# ── 5. Save as JPG ───────────────────────────────────────────────────────────
image_write(img, path = output_jpg, format = "jpeg", quality = 95)

message(sprintf(
  "\u2713 Pipeline diagram saved to: %s  (%d \u00d7 %d px @ %d dpi)",
  output_jpg, width_px, height_px, dpi
))

# ── 6. Scan repo for <!-- PIPELINE-DIAGRAM --> insertion sites ────────────────
message("\n── Scanning repo for <!-- PIPELINE-DIAGRAM --> insertion sites …")

scan_exts  <- c("*.md", "*.qmd", "*.R", "*.Rmd")
all_files  <- unlist(lapply(scan_exts, function(ext) {
  list.files(".", pattern = glob2rx(ext), recursive = TRUE,
             full.names = TRUE, ignore.case = TRUE)
}))

ins_marker <- "<!-- PIPELINE-DIAGRAM -->"
tagged     <- Filter(function(f) {
  any(grepl(ins_marker, readLines(f, warn = FALSE), fixed = TRUE))
}, all_files)

if (length(tagged) == 0L) {
  message("  (no files tagged — add ", ins_marker, " above each diagram embed)")
} else {
  message(sprintf("  Found %d tagged file(s):", length(tagged)))
  for (f in sort(tagged)) message("    ", sub("^\\./", "", f))
}

message("\nDone. Refresh any tagged files to display the updated diagram.")
