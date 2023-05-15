---
title: "Example: Combined Rmd Template"
author: "Andriy Koval"  
date: "last Updated: 2023-05-15"
output:
  html_document:
    keep_md: yes
    toc: yes
    toc_float: yes
    code_folding: hide
    theme: flatly
    highlight: tango
editor_options: 
  chunk_output_type: console
---

This report (add a brief description and the purpose of the report)
Demonstration of the __COMBINED__ template

<!--  Set the working directory to the repository's base directory; this assumes the report is nested inside of two directories.-->

```
## Warning: package 'knitr' was built under R version 4.2.3
```




# Environment

This section reviews the components of the working environment of the report. Non-technical readers are welcomed to skip. Come back if you need to understand the origins of custom functions, scripts, or data objects.

<details>
   <summary> Packages used <span class="glyphicon glyphicon-plus-sign"></span></summary>

Packages used in current report

<!-- Load packages, or at least verify they're available on the local machine.  Suppress the output when loading packages. -->

```{.r .fold-show}
library(tidyverse)
```
</details>


<details>
   <summary> External scripts <span class="glyphicon glyphicon-plus-sign"></span></summary>

```{.r .fold-show}
source("./scripts/common-functions.R")
source("./scripts/operational-functions.R")
```
</details>



<details>
   <summary> Global values <span class="glyphicon glyphicon-plus-sign"></span></summary>
Values used throughout the report.

</details>



<details>
   <summary> Functions <span class="glyphicon glyphicon-plus-sign"></span></summary>
Custom functions defined for use in this report.

</details>


# Data

To better understand the tables used in the report, you can click to expand a more technical description of the data origin. However, we suggest starting with the [What is a Row](#what-is-a-row) and [Data Description](#data-description) sections first. These sections provide a foundation for understanding the data and will help you better navigate the more technical description provided here. If you find that you still need more details, feel free to return to this section.


<details>
   <summary> Load data <span class="glyphicon glyphicon-plus-sign"></span></summary>


```{.r .fold-show}
ds0 <- readr::read_rds("./data-public/raw/example-prosthetic-1.rds")
```
</details>


<details>
   <summary> Inspect data <span class="glyphicon glyphicon-plus-sign"></span></summary>

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
   <summary> Transform data <span class="glyphicon glyphicon-plus-sign"></span></summary>

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

 What is the grain of this data set?

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

What is the period of observation?


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

## Table 1

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
# A tibble: 2 × 2
  sex    client_count
  <fct>         <dbl>
1 male          9260.
2 female       12913.
```

## Graph 1

We can create a graph on the fly...

![](figure-png-com/graph-1-1.png)<!-- -->

Alternatively, organizing as sequence of objects (i.e. rectangle `ds1` begets plot `g1`) allows to be more versatile:

![](figure-png-com/graph-2-1.png)<!-- -->

Session Information {#session-info}
===========================================================================

For the sake of documentation and reproducibility, the current report was rendered in the following environment.  Click the line below to expand.

<details>
  <summary>Environment <span class="glyphicon glyphicon-plus-sign"></span></summary>

```
─ Session info ───────────────────────────────────────────────────────────────────────────────────────────────────────
 setting  value
 version  R version 4.2.2 (2022-10-31 ucrt)
 os       Windows 10 x64 (build 22621)
 system   x86_64, mingw32
 ui       RTerm
 language (EN)
 collate  English_United States.utf8
 ctype    English_United States.utf8
 tz       America/Denver
 date     2023-05-15
 pandoc   2.19.2 @ C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools/ (via rmarkdown)

─ Packages ───────────────────────────────────────────────────────────────────────────────────────────────────────────
 package     * version    date (UTC) lib source
 bslib         0.4.2      2022-12-16 [1] CRAN (R 4.2.3)
 cachem        1.0.7      2023-02-24 [1] CRAN (R 4.2.3)
 callr         3.7.3      2022-11-02 [1] CRAN (R 4.2.2)
 cli           3.4.1      2022-09-23 [1] CRAN (R 4.2.2)
 colorspace    2.1-0      2023-01-23 [1] CRAN (R 4.2.3)
 crayon        1.5.2      2022-09-29 [1] CRAN (R 4.2.2)
 devtools      2.4.5      2022-10-11 [1] CRAN (R 4.2.2)
 digest        0.6.31     2022-12-11 [1] CRAN (R 4.2.3)
 dplyr       * 1.1.1      2023-03-22 [1] CRAN (R 4.2.3)
 ellipsis      0.3.2      2021-04-29 [1] CRAN (R 4.2.2)
 evaluate      0.20       2023-01-17 [1] CRAN (R 4.2.3)
 fansi         1.0.4      2023-01-22 [1] CRAN (R 4.2.3)
 farver        2.1.1      2022-07-06 [1] CRAN (R 4.2.2)
 fastmap       1.1.1      2023-02-24 [1] CRAN (R 4.2.3)
 forcats     * 1.0.0      2023-01-29 [1] CRAN (R 4.2.3)
 fs            1.6.1      2023-02-06 [1] CRAN (R 4.2.3)
 generics      0.1.3      2022-07-05 [1] CRAN (R 4.2.2)
 ggplot2     * 3.4.1      2023-02-10 [1] CRAN (R 4.2.3)
 glue          1.6.2      2022-02-24 [1] CRAN (R 4.2.2)
 gtable        0.3.3      2023-03-21 [1] CRAN (R 4.2.3)
 highr         0.10       2022-12-22 [1] CRAN (R 4.2.3)
 hms           1.1.3      2023-03-21 [1] CRAN (R 4.2.3)
 htmltools     0.5.5      2023-03-23 [1] CRAN (R 4.2.3)
 htmlwidgets   1.6.2      2023-03-17 [1] CRAN (R 4.2.3)
 httpuv        1.6.9      2023-02-14 [1] CRAN (R 4.2.3)
 jquerylib     0.1.4      2021-04-26 [1] CRAN (R 4.2.2)
 jsonlite      1.8.4      2022-12-06 [1] CRAN (R 4.2.2)
 knitr       * 1.42       2023-01-25 [1] CRAN (R 4.2.3)
 labeling      0.4.2      2020-10-20 [1] CRAN (R 4.2.0)
 later         1.3.0      2021-08-18 [1] CRAN (R 4.2.2)
 lifecycle     1.0.3      2022-10-07 [1] CRAN (R 4.2.2)
 lubridate   * 1.9.2      2023-02-10 [1] CRAN (R 4.2.3)
 magrittr      2.0.3      2022-03-30 [1] CRAN (R 4.2.2)
 memoise       2.0.1      2021-11-26 [1] CRAN (R 4.2.2)
 mime          0.12       2021-09-28 [1] CRAN (R 4.2.0)
 miniUI        0.1.1.1    2018-05-18 [1] CRAN (R 4.2.2)
 munsell       0.5.0      2018-06-12 [1] CRAN (R 4.2.2)
 pillar        1.9.0      2023-03-22 [1] CRAN (R 4.2.3)
 pkgbuild      1.4.0      2022-11-27 [1] CRAN (R 4.2.2)
 pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.2.2)
 pkgload       1.3.2      2022-11-16 [1] CRAN (R 4.2.2)
 prettyunits   1.1.1      2020-01-24 [1] CRAN (R 4.2.2)
 processx      3.8.0      2022-10-26 [1] CRAN (R 4.2.2)
 profvis       0.3.7      2020-11-02 [1] CRAN (R 4.2.2)
 promises      1.2.0.1    2021-02-11 [1] CRAN (R 4.2.2)
 ps            1.7.3      2023-03-21 [1] CRAN (R 4.2.3)
 purrr       * 1.0.1      2023-01-10 [1] CRAN (R 4.2.3)
 R6            2.5.1      2021-08-19 [1] CRAN (R 4.2.2)
 ragg          1.2.5      2023-01-12 [1] CRAN (R 4.2.3)
 Rcpp          1.0.10     2023-01-22 [1] CRAN (R 4.2.3)
 readr       * 2.1.4      2023-02-10 [1] CRAN (R 4.2.3)
 remotes       2.4.2      2021-11-30 [1] CRAN (R 4.2.2)
 rlang         1.1.0      2023-03-14 [1] CRAN (R 4.2.3)
 rmarkdown     2.21       2023-03-26 [1] CRAN (R 4.2.3)
 rstudioapi    0.14       2022-08-22 [1] CRAN (R 4.2.2)
 sass          0.4.5      2023-01-24 [1] CRAN (R 4.2.3)
 scales        1.2.1      2022-08-20 [1] CRAN (R 4.2.2)
 sessioninfo   1.2.2      2021-12-06 [1] CRAN (R 4.2.2)
 shiny         1.7.4      2022-12-15 [1] CRAN (R 4.2.3)
 stringi       1.7.12     2023-01-11 [1] CRAN (R 4.2.2)
 stringr     * 1.5.0      2022-12-02 [1] CRAN (R 4.2.3)
 systemfonts   1.0.4      2022-02-11 [1] CRAN (R 4.2.2)
 textshaping   0.3.6      2021-10-13 [1] CRAN (R 4.2.2)
 tibble      * 3.2.1      2023-03-20 [1] CRAN (R 4.2.3)
 tidyr       * 1.3.0      2023-01-24 [1] CRAN (R 4.2.3)
 tidyselect    1.2.0      2022-10-10 [1] CRAN (R 4.2.2)
 tidyverse   * 2.0.0      2023-02-22 [1] CRAN (R 4.2.3)
 timechange    0.2.0      2023-01-11 [1] CRAN (R 4.2.3)
 tzdb          0.3.0      2022-03-28 [1] CRAN (R 4.2.2)
 urlchecker    1.0.1      2021-11-30 [1] CRAN (R 4.2.2)
 usethis       2.1.6      2022-05-25 [1] CRAN (R 4.2.2)
 utf8          1.2.3      2023-01-31 [1] CRAN (R 4.2.3)
 vctrs         0.6.1.9000 2023-03-30 [1] Github (r-lib/vctrs@af29ad7)
 withr         2.5.0      2022-03-03 [1] CRAN (R 4.2.2)
 xfun          0.38       2023-03-24 [1] CRAN (R 4.2.3)
 xtable        1.8-4      2019-04-21 [1] CRAN (R 4.2.2)
 yaml          2.3.7      2023-01-23 [1] CRAN (R 4.2.3)

 [1] C:/Users/Andriy/AppData/Local/R/win-library/4.2
 [2] C:/Program Files/R/R-4.2.2/library

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```
</details>



Report rendered by Andriy at 2023-05-15, 05:42 -0600 in 5 seconds.
