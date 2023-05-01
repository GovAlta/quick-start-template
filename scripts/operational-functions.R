# Functions loaded by SOME scripts in the project
compute_fiscal_year <- function(x)(as.integer(zoo::as.yearmon(x) - 3/12 ))

# Define bottom and right limits when import Excel sheet
trim_sheet_input <- function(
  d
  , skip_n_rows      = 0
  , total_n_rows     = nrow(d)
  , column_positions = 1:ncol(d)
  
){
  # browser()
  # d <- dto$EmpButLost
  # skip_n_rows  <- 4
  # total_n_rows <- 35
  # column_positions <- c(1,2,3)
  # nrow(d)
  d_out <- d %>%
    slice( (skip_n_rows+1):total_n_rows ) %>%
    select(all_of(column_positions))
  return(d_out)
}


draw_random_id <- function(d, idvar="person_oid", n = 1){
  all_unique_ids <- d %>%
    pull(idvar) %>%
    unique()
  a_random_id <- sample(all_unique_ids, size = n)
  return(a_random_id)
}
# ds_is %>% draw_random_id()
# ds_ea %>% draw_random_id()

# see https://www.tidyverse.org/blog/2019/06/rlang-0-4-0/
# for details on using `.data[[]]` pronoun
get_sample <- function(
  d
  ,sample_size=10
  , idvar = "PERSON_OID"
  , uniques = TRUE # if TRUE, only unique values are sampled
  ,seed = 42
){
  # browser()
  sampling_universe <- d %>% pull(.data[[idvar]])
  if(uniques){
    sampling_universe <- sampling_universe %>% unique()
  }
  x_out <- sample(
    x        = sampling_universe
    ,size    = sample_size
    ,replace = FALSE
  )
  return(x_out)
}
# How to use
# a_sample <- ds2 %>% get_sample_uniques(sample_size =10, "person_oid")
# a_sample <- ds2 %>% get_sample_uniques(10)

count_total <- function(d){
  d1 <-
    d %>% 
    count() %>% 
    ungroup() %>% 
    mutate(
      pct = (n/sum(n,na.rm = T)) %>% scales::percent(accuracy = .1)
    )
  return(d1)
}
# How to use
# ds %>% 
#   group_by(var1) %>% 
#   count_total()

compare_freq <- function(d_full, d_sample, group_vars ){
  
  d1f <- d_full %>% 
    dplyr::group_by(!!!rlang::syms(group_vars)) %>%
    count() %>% ungroup() %>% 
    mutate(
      pct = (n/sum(n,na.rm = T)) #%>% scales::percent(accuracy = .1)
    )
  
  d2f <- d_sample %>%
    dplyr::group_by(!!!rlang::syms(group_vars)) %>%
    count() %>% ungroup() %>% 
    mutate(
      pct = (n/sum(n,na.rm = T)) #%>% scales::percent(accuracy = .1)
    ) %>% 
    rename(n_sample = n, pct_sample = pct) 
  
  d_out1 <- 
    dplyr::left_join(
      d1f
      ,d2f
    ) %>% 
    mutate(
      diff = pct - pct_sample
    )  
  cat("Total |deviation|: ", scales::percent(sum(abs(d_out1$diff), na.rm =T), accuracy=.001) )
  
  d_out2 <- 
    d_out1 %>% 
    mutate(
      across(
        .cols = c("pct", "pct_sample","diff")
        ,.fns = ~ scales::percent(., accuracy =.01)
      )
    ) %>% 
    relocate(n_sample, .after = "n")
  return(d_out2)
}
# How to use
# compare_freq(
#   ds
#   ,ds %>% get_sample(., 1000, idvar="person_oid", uniques=TRUE, seed = 42)
# )