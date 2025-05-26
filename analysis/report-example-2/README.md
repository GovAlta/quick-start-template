# `./analysis/report-example-2` Directory

Contains an example of a reporducible analytic pipeline of the form `ellis + scribe + eda`

-   `ellis.R` queries RDB (`CAU_UAT`) to generate rectangular object(s) for further use in the pipeline. Usually, stores products on `RESEARCH_PROJECT_CACHE_UAT` or hard disk.\
-   `scribe.R` imports products of `ellis.R` and prepares data for analysis.\
-   `eda.qmd` reads chunks from `scribe.R` to load stable data and adds analysis chunks to compose a narrative.
