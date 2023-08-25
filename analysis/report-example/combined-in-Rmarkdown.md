---
title: "Example: Combined in Rmarkdown"
author: "Andriy Koval"  
date: "last Updated: 2023-08-25"
output:
  html_document:
    keep_md: yes
    toc: yes
    toc_float: yes
    code_folding: hide
    theme: flatly
    highlight: tango
    self-contained: true
editor_options: 
  chunk_output_type: console
---

This report exemplifies a workflow in which executable script (source code layer) and information displays for humans (annotation layer) are composed and managed in the a single `.Rmd` document, as opposed to a pair of linked `.R`-- `.Rmd` files.





# Environment

This section reviews the components of the working environment of the report. Non-technical readers are welcomed to skip. Come back if you need to understand the origins of custom functions, scripts, or data objects.

<details>

<summary>Packages used </summary>

Packages used in current report

<!-- Load packages, or at least verify they're available on the local machine.  Suppress the output when loading packages. -->


```{.r .fold-show}
library(tidyverse)
```

</details>

<details>

<summary>External scripts </summary>


```{.r .fold-show}
source("./scripts/common-functions.R")
source("./scripts/operational-functions.R")
```

</details>

<details>

<summary>Global values </summary>

Values used throughout the report.



</details>

<details>

<summary>Functions </summary>

Custom functions defined for use in this report.



</details>

# Data

To better understand the tables used in the report, you can click to expand a more technical description of the data origin. However, we suggest starting with the [What is a Row](#what-is-a-row) and [Data Description](#data-description) sections first. These sections provide a foundation for understanding the data and will help you better navigate the more technical description provided here. If you find that you still need more details, feel free to return to this section.

<details>

<summary>Load data </summary>


```{.r .fold-show}
ds0 <- readr::read_rds("./data-public/raw/example-prosthetic-1.rds")
```

</details>

<details>

<summary>Inspect data </summary>


```{.r .fold-show}
ds0  %>% explore::describe_all()
```

```
# A tibble: 7 × 8
  variable type     na na_pct unique   min   mean   max
  <chr>    <chr> <int>  <dbl>  <int> <dbl>  <dbl> <dbl>
1 id       int       0    0     2000  1    1000.  2000 
2 weight   dbl       0    0      579  1.12   11.1  309.
3 date     dat       0    0       48 NA      NA     NA 
4 employed fct      75    3.8      3 NA      NA     NA 
5 gender   fct       0    0        2 NA      NA     NA 
6 age      fct       0    0        3 NA      NA     NA 
7 race     fct      59    2.9      4 NA      NA     NA 
```

```{.r .fold-show}
ds0 %>% select(-id,-weight,-date) %>% tableone::CreateTableOne(data=.) %>% summary()
```

```

     ### Summary of categorical variables ### 

strata: Overall
      var    n miss p.miss            level freq percent cum.percent
 employed 2000   75    3.8     not employed  829    43.1        43.1
                                   employed 1096    56.9       100.0
                                                                    
   gender 2000    0    0.0             male  836    41.8        41.8
                                     female 1164    58.2       100.0
                                    unknown    0     0.0       100.0
                                                                    
      age 2000    0    0.0       middle age 1312    65.6        65.6
                                     senior  400    20.0        85.6
                                      youth  288    14.4       100.0
                                                                    
     race 2000   59    2.9        caucasian 1251    64.5        64.5
                           visible minority  450    23.2        87.6
                                 aboriginal  240    12.4       100.0
                                                                    
```

</details>

<details>

<summary>Transform data </summary>


```{.r .fold-show}
ds1 <-
  ds0 %>%
  rename(
    sex = gender # less biased term
  ) %>%
  mutate(
    male    = sex == "male"
    ,female = sex == "female"
    # ,caucasian  = race == "caucasian"
    # ,minority   = race == "minority"
    # ,aboriginal = race == "aboriginal"
    # ,employed_at_survey = employed == "employed"
  ) %>%
  mutate(
    year                = lubridate::year(date) %>% as.integer(),
    # yearmon             = tsibble::yearmonth, # not supported by look_for()
    # year_fiscal         = compute_fiscal_year(date),
    # quarter             = lubridate::quarter(date), # custom function, load from ./scripts/operational-functions.R
    # quarter_fiscal      = (quarter - 1),
    # quarter_fiscal      = ifelse(quarter_fiscal==0,4,quarter_fiscal)%>% as.integer(),
    # year_date           = as.Date(paste0(year,"-01-01")),
    # year_fiscal_date    = as.Date(paste0(year_fiscal,"-04-01")),
    # quarter_date        = paste(year,(quarter*3-1),"15", sep="-") %>% as.Date(),
    # quarter_fiscal_date = quarter_date,
  )
# compare the initial state to spot the diff
# some summaries are more useful for various comparisons
explore::describe_all(ds0)
```

```
# A tibble: 7 × 8
  variable type     na na_pct unique   min   mean   max
  <chr>    <chr> <int>  <dbl>  <int> <dbl>  <dbl> <dbl>
1 id       int       0    0     2000  1    1000.  2000 
2 weight   dbl       0    0      579  1.12   11.1  309.
3 date     dat       0    0       48 NA      NA     NA 
4 employed fct      75    3.8      3 NA      NA     NA 
5 gender   fct       0    0        2 NA      NA     NA 
6 age      fct       0    0        3 NA      NA     NA 
7 race     fct      59    2.9      4 NA      NA     NA 
```

```{.r .fold-show}
explore::describe_all(ds1)
```

```
# A tibble: 10 × 8
   variable type     na na_pct unique     min    mean   max
   <chr>    <chr> <int>  <dbl>  <int>   <dbl>   <dbl> <dbl>
 1 id       int       0    0     2000    1    1000.   2000 
 2 weight   dbl       0    0      579    1.12   11.1   309.
 3 date     dat       0    0       48   NA      NA      NA 
 4 employed fct      75    3.8      3   NA      NA      NA 
 5 sex      fct       0    0        2   NA      NA      NA 
 6 age      fct       0    0        3   NA      NA      NA 
 7 race     fct      59    2.9      4   NA      NA      NA 
 8 male     lgl       0    0        2    0       0.42    1 
 9 female   lgl       0    0        2    0       0.58    1 
10 year     int       0    0        4 2011    2013.   2014 
```

```{.r .fold-show}
# THe point is, must must provide a self-explanatory comparions of analysis rectangle BEFORE and AFTER a meaningful set of transformations. (e.g ds0 --> ds1)
```

</details>

# What is a row? {#what-is-a-row}

## Q.1 What is the grain of this data set?

> Grain - the most granular level of the data, answers the question "What is a row?"

Each row of `ds0` represents a person


```r
ds0 %>% nrow()
```

```
[1] 2000
```

```r
ds0 %>% summarize(row_count=n())
```

```
# A tibble: 1 × 1
  row_count
      <int>
1      2000
```

```r
ds0 %>% summarize(
  row_count = n()
  ,id_count = n_distinct(id)
) %>%
  mutate(
    id_is_the_grain = row_count == id_count
  )
```

```
# A tibble: 1 × 3
  row_count id_count id_is_the_grain
      <int>    <int> <lgl>          
1      2000     2000 TRUE           
```

# Data Description {#data-description}

## Q.2 What is the period of observation?


```r
ds0$date %>% summary() # looks like from [2011 to 2014]
```

```
        Min.      1st Qu.       Median         Mean      3rd Qu.         Max. 
"2011-01-01" "2012-04-01" "2013-04-01" "2013-03-06" "2014-03-01" "2014-12-01" 
```

```r
ds0 %>% 
  summarize(
    earliest_date  = min(date,na.rm=T)
    ,latest_date   = max(date,na.rm=T)
    ,span_in_days  = (latest_date-earliest_date)
  )
```

```
# A tibble: 1 × 3
  earliest_date latest_date span_in_days
  <date>        <date>      <drtn>      
1 2011-01-01    2014-12-01  1430 days   
```

# Analysis

## Q.3 What is sex ratio?

### Table 1


```
# A tibble: 2 × 2
# Groups:   sex [2]
  sex        n
  <fct>  <int>
1 male     836
2 female  1164
```

```
# A tibble: 2 × 2
  sex    row_count
  <fct>      <int>
1 male         836
2 female      1164
```

```
# A tibble: 2 × 2
  sex    respondent_count
  <fct>             <int>
1 male                836
2 female             1164
```

```
# A tibble: 2 × 5
  sex    respondent_count client_count respondent_share client_share
  <fct>             <int>        <dbl>            <dbl>        <dbl>
1 male                836        9260.            0.418        0.418
2 female             1164       12913.            0.582        0.582
```

### Graph 1

We can create a graph on the fly...

![](figure-png-com/graph-1-1.png)<!-- -->

Alternatively, organizing as sequence of objects (i.e. rectangle `ds1` begets plot `g1`) allows to be more versatile:

![](figure-png-com/graph-2-1.png)<!-- -->

# Session Information {#session-info}

For the sake of documentation and reproducibility, the current report was rendered in the following environment. Click the line below to expand.

<details>

<summary>Environment </summary>


```
─ Session info ───────────────────────────────────────────────────────────────────────────────────────────────────────
 setting  value
 version  R version 4.3.1 (2023-06-16 ucrt)
 os       Windows 11 x64 (build 22621)
 system   x86_64, mingw32
 ui       RTerm
 language (EN)
 collate  English_United States.utf8
 ctype    English_United States.utf8
 tz       America/Edmonton
 date     2023-08-25
 pandoc   2.19.2 @ C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools/ (via rmarkdown)

─ Packages ───────────────────────────────────────────────────────────────────────────────────────────────────────────
 package     * version date (UTC) lib source
 bslib         0.5.0   2023-06-09 [1] CRAN (R 4.3.1)
 cachem        1.0.8   2023-05-01 [1] CRAN (R 4.3.1)
 callr         3.7.3   2022-11-02 [1] CRAN (R 4.3.1)
 cli           3.6.1   2023-03-23 [1] CRAN (R 4.3.1)
 codetools     0.2-19  2023-02-01 [2] CRAN (R 4.3.1)
 colorspace    2.1-0   2023-01-23 [1] CRAN (R 4.3.1)
 crayon        1.5.2   2022-09-29 [1] CRAN (R 4.3.1)
 DBI           1.1.3   2022-06-18 [1] CRAN (R 4.3.1)
 devtools      2.4.5   2022-10-11 [1] CRAN (R 4.3.1)
 digest        0.6.32  2023-06-26 [1] CRAN (R 4.3.1)
 dplyr       * 1.1.2   2023-04-20 [1] CRAN (R 4.3.1)
 DT            0.28    2023-05-18 [1] CRAN (R 4.3.1)
 ellipsis      0.3.2   2021-04-29 [1] CRAN (R 4.3.1)
 evaluate      0.21    2023-05-05 [1] CRAN (R 4.3.1)
 explore       1.0.2   2023-01-14 [1] CRAN (R 4.3.1)
 fansi         1.0.4   2023-01-22 [1] CRAN (R 4.3.1)
 farver        2.1.1   2022-07-06 [1] CRAN (R 4.3.1)
 fastmap       1.1.1   2023-02-24 [1] CRAN (R 4.3.1)
 forcats     * 1.0.0   2023-01-29 [1] CRAN (R 4.3.1)
 fs            1.6.2   2023-04-25 [1] CRAN (R 4.3.1)
 generics      0.1.3   2022-07-05 [1] CRAN (R 4.3.1)
 ggplot2     * 3.4.2   2023-04-03 [1] CRAN (R 4.3.1)
 glue          1.6.2   2022-02-24 [1] CRAN (R 4.3.1)
 gridExtra     2.3     2017-09-09 [1] CRAN (R 4.3.1)
 gtable        0.3.3   2023-03-21 [1] CRAN (R 4.3.1)
 haven         2.5.3   2023-06-30 [1] CRAN (R 4.3.1)
 highr         0.10    2022-12-22 [1] CRAN (R 4.3.1)
 hms           1.1.3   2023-03-21 [1] CRAN (R 4.3.1)
 htmltools     0.5.5   2023-03-23 [1] CRAN (R 4.3.1)
 htmlwidgets   1.6.2   2023-03-17 [1] CRAN (R 4.3.1)
 httpuv        1.6.11  2023-05-11 [1] CRAN (R 4.3.1)
 jquerylib     0.1.4   2021-04-26 [1] CRAN (R 4.3.1)
 jsonlite      1.8.7   2023-06-29 [1] CRAN (R 4.3.1)
 knitr       * 1.43    2023-05-25 [1] CRAN (R 4.3.1)
 labeling      0.4.2   2020-10-20 [1] CRAN (R 4.3.0)
 labelled      2.12.0  2023-06-21 [1] CRAN (R 4.3.1)
 later         1.3.1   2023-05-02 [1] CRAN (R 4.3.1)
 lattice       0.21-8  2023-04-05 [2] CRAN (R 4.3.1)
 lifecycle     1.0.3   2022-10-07 [1] CRAN (R 4.3.1)
 lubridate   * 1.9.2   2023-02-10 [1] CRAN (R 4.3.1)
 magrittr      2.0.3   2022-03-30 [1] CRAN (R 4.3.1)
 Matrix        1.5-4.1 2023-05-18 [2] CRAN (R 4.3.1)
 memoise       2.0.1   2021-11-26 [1] CRAN (R 4.3.1)
 mime          0.12    2021-09-28 [1] CRAN (R 4.3.0)
 miniUI        0.1.1.1 2018-05-18 [1] CRAN (R 4.3.1)
 mitools       2.4     2019-04-26 [1] CRAN (R 4.3.1)
 munsell       0.5.0   2018-06-12 [1] CRAN (R 4.3.1)
 pillar        1.9.0   2023-03-22 [1] CRAN (R 4.3.1)
 pkgbuild      1.4.2   2023-06-26 [1] CRAN (R 4.3.1)
 pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.3.1)
 pkgload       1.3.2   2022-11-16 [1] CRAN (R 4.3.1)
 prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.3.1)
 processx      3.8.2   2023-06-30 [1] CRAN (R 4.3.1)
 profvis       0.3.8   2023-05-02 [1] CRAN (R 4.3.1)
 promises      1.2.0.1 2021-02-11 [1] CRAN (R 4.3.1)
 ps            1.7.5   2023-04-18 [1] CRAN (R 4.3.1)
 purrr       * 1.0.1   2023-01-10 [1] CRAN (R 4.3.1)
 R6            2.5.1   2021-08-19 [1] CRAN (R 4.3.1)
 ragg          1.2.5   2023-01-12 [1] CRAN (R 4.3.1)
 Rcpp          1.0.11  2023-07-06 [1] CRAN (R 4.3.1)
 readr       * 2.1.4   2023-02-10 [1] CRAN (R 4.3.1)
 remotes       2.4.2   2021-11-30 [1] CRAN (R 4.3.1)
 rlang         1.1.1   2023-04-28 [1] CRAN (R 4.3.1)
 rmarkdown     2.23    2023-07-01 [1] CRAN (R 4.3.1)
 rstudioapi    0.14    2022-08-22 [1] CRAN (R 4.3.1)
 sass          0.4.6   2023-05-03 [1] CRAN (R 4.3.1)
 scales        1.2.1   2022-08-20 [1] CRAN (R 4.3.1)
 sessioninfo   1.2.2   2021-12-06 [1] CRAN (R 4.3.1)
 shiny         1.7.4.1 2023-07-06 [1] CRAN (R 4.3.1)
 stringi       1.7.12  2023-01-11 [1] CRAN (R 4.3.0)
 stringr     * 1.5.0   2022-12-02 [1] CRAN (R 4.3.1)
 survey        4.2-1   2023-05-03 [1] CRAN (R 4.3.1)
 survival      3.5-5   2023-03-12 [2] CRAN (R 4.3.1)
 systemfonts   1.0.4   2022-02-11 [1] CRAN (R 4.3.1)
 tableone      0.13.2  2022-04-15 [1] CRAN (R 4.3.1)
 textshaping   0.3.6   2021-10-13 [1] CRAN (R 4.3.1)
 tibble      * 3.2.1   2023-03-20 [1] CRAN (R 4.3.1)
 tidyr       * 1.3.0   2023-01-24 [1] CRAN (R 4.3.1)
 tidyselect    1.2.0   2022-10-10 [1] CRAN (R 4.3.1)
 tidyverse   * 2.0.0   2023-02-22 [1] CRAN (R 4.3.1)
 timechange    0.2.0   2023-01-11 [1] CRAN (R 4.3.1)
 tzdb          0.4.0   2023-05-12 [1] CRAN (R 4.3.1)
 urlchecker    1.0.1   2021-11-30 [1] CRAN (R 4.3.1)
 usethis       2.2.2   2023-07-06 [1] CRAN (R 4.3.1)
 utf8          1.2.3   2023-01-31 [1] CRAN (R 4.3.1)
 vctrs         0.6.3   2023-06-14 [1] CRAN (R 4.3.1)
 withr         2.5.0   2022-03-03 [1] CRAN (R 4.3.1)
 xfun          0.39    2023-04-20 [1] CRAN (R 4.3.1)
 xtable        1.8-4   2019-04-21 [1] CRAN (R 4.3.1)
 yaml          2.3.7   2023-01-23 [1] CRAN (R 4.3.0)

 [1] C:/Users/Andriy/AppData/Local/R/win-library/4.3
 [2] C:/Program Files/R/R-4.3.1/library

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

</details>



Report rendered by Andriy at 2023-08-25, 11:25 -0600 in 13 seconds.
