library(tidyverse)
# Functions loaded by SOME scripts in the project
compute_fiscal_year <- function(x)(as.integer(zoo::as.yearmon(x) - 3/12 ))

# Compute difference in months
# turn a date into a 'monthnumber' relative to an origin
month_number <- function(d) { 
  lt <- as.POSIXlt(as.Date(d, origin="1900-01-01")); lt$year*12 + lt$mon 
} 
# compute a month difference as a difference between two monnb's
month_diff <- function(date1, date2) { month_number(date2) - month_number(date1)+1 }

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

keep_random_id <- function(d, idvar="person_oid", n = 1, seed=Sys.time()){
  # browser()
  set.seed(seed)
  all_unique_ids <- d %>%
    pull(!!rlang::sym(idvar)) %>%
    unique()
  a_random_id <- sample(all_unique_ids, size = n)
  d_out <- d %>% filter(!!rlang::sym(idvar)%in%a_random_id)
  return(d_out)
}
# How to use
# ds %>% keep_random_id()


show_random_case <- function(d, seed = Sys.time()){
  set.seed
  d %>% 
    keep_random_id() %>% 
    select(any_of(c("person_oid", "date_start", "date_end","program_class0", "program_class1", "intervention","interval_type","interval_num")))
}
# How to use
# d %>% show_random_case

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


# remove variables that contain direct and sensitive identifier
drop_idvars <- function(d,add_name="none"){
  known <- c("person_oid","edb_service_id","survey_id","sin","sin1","sin2","sin3")
  added <- add_name
  d_out <- d %>% select(-any_of(c(known, added)))
  return(d_out)
}


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


# ---- protecting-ids --------------------------------

df <- tribble(
  ~person_id, ~event_id, ~event_location,
  23, 111, "Library",
  23, 222, "Store",
  23, 333, "Library",
  23, 444, "Bank",
  40, 555, "Library",
  40, 666, "Bank",
  40, 777, "Store",
  51, 888, "Bank",
  51, 999, "Bank"
)

# view as single case
view_one <- function(
    d
    ,idvar    = "person_oid" # name of the variable to serve as unique identifier
    ,case_id  = draw_random_id(idvar=idvar,d, n = 1)
    ,add_case = NA # additional cases for review
){
  
  known <- c(case_id)
  added <- add_case
  subset_cases <- c(known,added) %>% unique() %>% na.omit() %>% as.vector()
  
  d_out <- 
    d %>% 
    filter(
      !!rlang::sym(idvar) %in% subset_cases
    )
  return(d_out)
}
# How to use:
# df %>% view_one(idvar="person_id")
# df %>% view_one(idvar="event_id")


mask_ids <- function(
    d_in,
    idvars = NULL # add more column names if known defaults do not cover
) {
  
  # browser()
  known_defaults <- c("person_oid", "edb_service_id", "sin", "sin1", "sin2", "sin3")
  used_in_group <- c(idvars, known_defaults) # to be passed
  passed_to_group_by <- intersect(names(d_in), used_in_group)
  
  passed_to_group_by <- if (length(passed_to_group_by) == 0) {
    stop("No variables to group by")
    
  } else {
    passed_to_group_by
  }
  # browser()
  d_out <- 
    d_in %>%
    mutate(across(any_of(passed_to_group_by), ~ as.integer(factor(.))))
  return(d_out)
}
# How to use
set.seed(42)
# df %>%
#   # mask_ids(idvars = "person_id") %>% # disable to see real IDs
#   mask_ids(idvars = c("person_id","event_id"))
rm(df)
