How to enable interactive plotting for EDA-3

This folder contains the EDA-3 analysis script and Quarto document. For interactive plotting in VS Code we recommend using the `httpgd` device.

Quick steps (Windows)

1. Install `httpgd` (CRAN binary recommended):

```powershell
Rscript -e "install.packages('httpgd', repos='https://cran.rstudio.com')"
```

2. In VS Code start an R session (e.g. use the R extension).
3. Run the following in the R console:

```r
library(httpgd)
httpgd::hgd()          # start server
plot(1:10)             # quick test
httpgd::hgd_browse()   # open interactive viewer in browser
```

Notes

- The EDA script (`eda-1.R`) will automatically start `httpgd` only when it detects an interactive VS Code session. This prevents Quarto/CI from attempting to start a server during non-interactive renders.
- For reproducible reports, the script still saves static PNGs via `ggsave()`; interactive plotting is strictly for development and exploration.
- If installation fails on Windows because of compilation errors, make sure you install the Windows binary of `httpgd` from CRAN or install Rtools if needed.

If you want, I can add a short VS Code settings snippet to automatically use httpgd for the R extension plot device.
