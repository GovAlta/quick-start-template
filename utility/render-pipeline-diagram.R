# utility/render-pipeline-diagram.R
#
# Purpose : Extract the canonical Mermaid pipeline diagram from
#           manipulation/pipeline.md and render it to a static image.
#
# Output  : libs/images/pipeline-architecture.jpg
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
# Referencing the output in other documents:
#   Markdown  : ![Pipeline Architecture](libs/images/pipeline-architecture.jpg)
#   Quarto    : ![](../libs/images/pipeline-architecture.jpg){width="100%"}
#
# -----------------------------------------------------------------------------

library(magick)

# ── Config ────────────────────────────────────────────────────────────────────
source_md  <- "manipulation/pipeline.md"
output_jpg <- "manipulation/images/pipeline-architecture.jpg"

width_in  <- 8.5    # output width  in inches
height_in <- 2.5    # output height in inches
dpi       <- 150    # resolution  (150 dpi → 1275 × 375 px at defaults)

# ── 1. Extract the first ```mermaid block from pipeline.md ────────────────────
lines    <- readLines(source_md, warn = FALSE)
start_ix <- which(grepl("^```mermaid", lines))[1]
if (is.na(start_ix)) stop("No ```mermaid block found in: ", source_md)

# find the closing fence that follows the opening fence
fence_ix <- which(grepl("^```\\s*$", lines))
end_ix   <- fence_ix[fence_ix > start_ix][1]
if (is.na(end_ix)) stop("Unclosed mermaid block in: ", source_md)

mermaid_code <- paste(lines[(start_ix + 1L):(end_ix - 1L)], collapse = "\n")

# ── 2. Write to a temp .mmd file ──────────────────────────────────────────────
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

# ── 4. Resize / crop to exact dimensions and save as JPG ─────────────────────
img <- image_read(tmp_png)

# Scale so width matches exactly; then extend/pad vertically to target height
geo_w <- geometry_size_pixels(width = width_px)
img   <- image_resize(img, geo_w)

geo_wh <- geometry_size_pixels(width = width_px, height = height_px)
img    <- image_extent(img, geo_wh, gravity = "Center", color = "white")

# Ensure output directory exists
dir.create(dirname(output_jpg), showWarnings = FALSE, recursive = TRUE)

image_write(img, path = output_jpg, format = "jpeg", quality = 95)

message(sprintf(
  "\u2713 Pipeline diagram saved to: %s  (%d \u00d7 %d px @ %d dpi)",
  output_jpg, width_px, height_px, dpi
))
