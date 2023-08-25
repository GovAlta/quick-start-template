---
title: "Rmarkdown Annotation Layer"
author: "Andriy Koval"
date: "last Updated: 2023-08-25"
output:
  html_document:
    keep_md: yes
    toc: yes
    toc_float: yes
    code_folding: show
    theme: simplex
    highlight: tango
    self-contained: true
editor: visual
editor_options: 
  chunk_output_type: inline
---

This report exemplifies a workflow in which executable script (source code layer) is coupled with the annotation layer to produce a dynamic document (e.g. html, pdf): `.R` + `.Rmd` = `.hmtl` files.





# Environment

<details>

<summary>Packages used</summary>

Packages used in current report <!-- Load packages, or at least verify they're available on the local machine.  Suppress the output when loading packages. -->


```{.r .fold-show}
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(scales)    # format
library(dplyr)     # loading dplyr explicitly is my guilty pleasure
library(broom)     # for model
library(emmeans)   # for interpreting model results
library(magrittr)
# -- 2.Import only certain functions of a package into the search path.
import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"    )# data import/export
requireNamespace("readxl"   )# data import/export
requireNamespace("tidyr"    )# tidy data
requireNamespace("janitor"  )# tidy data
requireNamespace("dplyr"    )# Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"   )# For asserting conditions meet expected patterns.
```

</details>

<details>

<summary>External scripts</summary>

<!-- Load the sources.  Suppress the output when loading sources. -->


```{.r .fold-show}
base::source("./scripts/common-functions.R") # project-level
```

</details>

<details>

<summary>Global values</summary>

Values used throughout the report. <!-- Load any Global functions and variables declared in the R file.  Suppress the output. -->


```{.r .fold-show}
# printed figures will go here:
prints_folder <- paste0("./analysis/report-example/prints/")
if(!file.exists(prints_folder)){dir.create(file.path(prints_folder))}
```

</details>

<details>

<summary>Functions</summary>

Custom functions defined for use in this report.



</details>

# Data

Consider a scenario in which rectangle `ds0` contains a set of survey responses


```r
ds0 <- readr::read_rds("./data-public/raw/example-prosthetic-2.rds")
```

What's inside this `analysis rectange`?


```r
# ds0 %>% View() #
# ds0 %>% glimpse()
explore::describe_all(ds0)
```

```
# A tibble: 8 × 8
  variable type     na na_pct unique   min    mean    max
  <chr>    <chr> <int>  <dbl>  <int> <dbl>   <dbl>  <dbl>
1 id       int       0    0     2000  1    1000.    2000 
2 weight   dbl       0    0      860  1.12    9.39   189.
3 date     dat       0    0      138 NA      NA       NA 
4 employed fct     103    5.1      3 NA      NA       NA 
5 race     fct      73    3.6      4 NA      NA       NA 
6 age      fct       0    0        3 NA      NA       NA 
7 earnings dbl    1331   66.6    313 20.8  2868.   49292.
8 gender   fct       0    0        2 NA      NA       NA 
```

```r
# labelled::look_for(ds0)
# tableone::CreateTableOne(data = ds0)
ds0 %>% select(-id,-weight,-date) %>% tableone::CreateTableOne(data=.)
```

```
                         
                          Overall          
  n                          2000          
  employed = employed (%)    1114 (58.7)   
  race (%)                                 
     caucasian               1184 (61.4)   
     visible minority         460 (23.9)   
     aboriginal               283 (14.7)   
  age (%)                                  
     middle age              1273 (63.6)   
     senior                   410 (20.5)   
     youth                    317 (15.8)   
  earnings (mean (SD))    2868.12 (2675.13)
  gender = female (%)        1069 (53.4)   
```

# Facts about the rectangle

Some facts about our analysis rectangle are good to know before any wrangling takes place.

## Q.1 What is the grain of this data set?

> Grain - the most granular level of the data, answers the question "What is a row?"


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

## Q.2 What is the period of observation?


```r
ds0$date %>% summary() # looks like from [2011 to 2014]
```

```
        Min.      1st Qu.       Median         Mean      3rd Qu.         Max. 
"2011-01-01" "2014-10-01" "2017-10-16" "2017-04-28" "2019-11-01" "2022-06-01" 
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
1 2011-01-01    2022-06-01  4169 days   
```

# Transformations

Wrangle data to assist in analysis


```r
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
```



# Analysis

## Q.3 What is sex ratio?


```r
ds1 %>% group_by(sex) %>% count()
```

```
# A tibble: 2 × 2
# Groups:   sex [2]
  sex        n
  <fct>  <int>
1 male     931
2 female  1069
```

```r
ds1 %>% group_by(sex) %>% summarize(row_count = n())
```

```
# A tibble: 2 × 2
  sex    row_count
  <fct>      <int>
1 male         931
2 female      1069
```

```r
ds1 %>% group_by(sex) %>% summarize(respondent_count = n_distinct(id))
```

```
# A tibble: 2 × 2
  sex    respondent_count
  <fct>             <int>
1 male                931
2 female             1069
```

```r
ds1 %>% 
  # mutate(weight = 1L) %>% 
  group_by(sex) %>% 
  summarize(
    respondent_count = n()
    ,client_count    = sum(weight)
  ) %>% 
  ungroup() %>% 
  mutate(
    respondent_share = respondent_count/sum(respondent_count)
    ,client_share    = client_count/sum(client_count)
)
```

```
# A tibble: 2 × 5
  sex    respondent_count client_count respondent_share client_share
  <fct>             <int>        <dbl>            <dbl>        <dbl>
1 male                931        9006.            0.466        0.479
2 female             1069        9778.            0.534        0.521
```

```r
# quick graph
ds1 %>% 
  group_by(sex) %>% 
  summarize(client_count = sum(weight)) %>%
  ggplot(aes(y = client_count, x = sex)) +
  geom_col()
```

![](figure-png-iso/unnamed-chunk-4-1.png)<!-- -->

Alternatively, organizing as sequence of objects (i.e. rectangle `ds1` begets plot `g1`) allows to be more versatile:


```r
g1 <-
  ds1 %>%
  group_by(sex) %>%
  summarize(client_count = sum(weight)) %>%
  ggplot(data=., aes(y = client_count, x = sex)) +
  geom_col()
g1 %>% print()
```

![](figure-png-iso/unnamed-chunk-5-1.png)<!-- -->

```r
ggsave("../../analysis/report-example/g1.png",plot=g1)
ggsave("../../analysis/report-example/g1.png",plot=g1,width=6,height = 4) # optimize
ggsave("../../analysis/report-example/g1.jpg",plot=g1,width=21,height = 14,units = "cm") # optimize
```

## Q.4 Sex difference in the outcome

Is the outcome (employment) related to the sex of the client? Who is more likely to report being employed after the program?
