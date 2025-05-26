rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: 
# http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr)
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(scales)    # format
library(broom)     # for model
library(emmeans)   # for interpreting model results
library(ggalluvial)
# -- 2.Import only certain functions of a package into the search path.
# import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified
requireNamespace("readr"    )# data import/export
requireNamespace("readxl"   )# data import/export
requireNamespace("janitor"  )# tidy data
requireNamespace("testit"   )# For asserting conditions meet expected patterns.

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------
target_window_opens  <- as.Date("2014-01-01")
target_window_closes <- as.Date("2025-04-30")
target_window <- c(target_window_opens, target_window_closes)
local_root <- "./analysis/fs-dynamics/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/fs-dynamics/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}

sample_of_interest1 <- 4734747 # real id in focus
# sample_of_interest1 <- 179820 # scramble id in focus
sample_of_interest <- c(
  1017460
  ,1411830
  ,3777415
  ,4812318
  ,4734747
  ,2099597
)
sample_of_interest1 <- sample_of_interest[6]
# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level
check_id_duplicates <- function(data, id_var) {
  id_var <- rlang::enquo(id_var)
  
  data %>%
    count(!!id_var, name = "n") %>%
    filter(n > 1) %>%
    arrange(desc(n))
}
# ----- define-query -----------------------------------------------------------
sql_event <- "
SELECT --TOP (1000) 
       [person_oid]
      ,[edb_service_id]
      ,[date_start]
      ,[date_end]
      ,[spell_number]
      ,[spell_bit_number]
      ,[spell_bit_duration]
      ,[hh_role]
      ,[client_type_code]
      ,[category_group]
      ,[client_type]
      ,[gender]
      ,[age]
      ,[marital_status]
      ,[total_dependent_count]
      ,[pt_code]
      ,[sc_code]
      ,[st_code]
      ,[training_program_type_code]
      ,[assessment_type]
      ,[service_type_name]
      ,[program_class0]
      ,[program_class1]
      ,[program_class2]
      ,[program_class3]
      ,[program_type]
      ,[service_category]
      ,[service_type]
      ,[pc0]
      ,[pc1]
      ,[pc2]
      ,[pc3]
      ,[asmt_type]
      ,[fs_type]
      ,[program_group]
  FROM [RESEARCH_PROJECT_CACHE_UAT].[P20250520].[SERVICE_EVENT_V01]

"
# ---- load-data ---------------------------------------------------------------
file_path <- paste0("./data-private/derived/",basename(local_root),"/1-scribe-event.parquet")
# disable BELOW after you run it for the first time on your machine
# dsn <- "RESEARCH_PROJECT_CACHE_UAT" # one per database, typically in config file
# cnn <- DBI::dbConnect(odbc::odbc(),dsn=dsn) # open the connection
# ds_input <- DBI::dbGetQuery(cnn, sql_event)
# ds_input %>% # adding some formatting b/c saves time
#   as_tibble()  %>%
#   janitor::clean_names() %>% 
#   mutate_at(c("client_type_code"),~as.integer(.)) %>%
#   mutate_at(
#     .vars = c("date_start","date_end")
#     ,.funs = ~as.Date(.)
#   ) %>%
#   arrow::write_parquet(file_path)
# DBI::dbDisconnect(cnn) # hang up the phone
# disable ABOVE after you run it for the first time on your machine
ds_event <- arrow::read_parquet(file_path)
rm(file_path)

file_path <- paste0("./data-private/derived/",basename(local_root),"/0-ellis-taxonomy.parquet")
ds_taxonomy <- arrow::read_parquet(file_path)
rm(file_path)
# ---- tweak-data-0 -------------------------------------

ds0_taxonomy <- 
  ds_taxonomy %>% 
  # add some useful variables
  # these two take a long time, so we isolate them  in this step
  rename(
    pt_code = program_type_code      # to minimize space in the output   
    ,sc_code = service_category_code # to minimize space in the output
    ,st_code = service_type_code     # to minimize space in the output
  ) %>%
  mutate(
    pc0 = program_class0 %>% case_match(
      "Financial Support" ~ "FS"
      ,"Assessment"       ~ "AS"
      ,"Training"         ~ "TR"
    )
    ,pc1 = program_class1  %>% case_match(
      "One Time Issues"    ~ "OTI"   # Financial Support               
      ,"Income Support"    ~ "IS"    # Financial Support         
      ,"AISH"              ~ "AISH"  # Financial Support           
      ,"DRES"              ~ "DRES"  # Financial Support           
      ,"Assessment"        ~ "ASMT"  # Assessment          
      ,"Career Information"~ "CI"    # Training        
      ,"Work Foundations"  ~ "WF"    # Training        
      ,"Training for Work" ~ "TFW"   # Training         
    ),pc2 = program_class2 %>% case_match(
      "One Time Issues"                 ~ "OTI"   # Financial Support       
      ,"Barriers to Full Employment"    ~ "BFE"   # Financial Support     
      ,"Expected to Work"               ~ "ETW"   # Financial Support     
      ,"AISH"                           ~ "AISH"  # Financial Support      
      ,"DRES"                           ~ "DRES"  # Financial Support      
      ,"ERA"                            ~ "ERA"   # Assessment     
      ,"Employability"                  ~ "EA"    # Assessment    
      ,"Needs Identification"           ~ "NI"    # Assessment    
      ,"Service Needs Determination"    ~ "SND"   # Assessment     
      ,"Work Foundations"               ~ "WF"    # Training    
      ,"Training for Work"              ~ "TFW"   # Training     
      ,"Workshop"                       ~ "WS"    # Training    
      ,"Job Placement"                  ~ "JP"    # Training    
      ,"Exposure Course"                ~ "EC"    # Training     
      ,"English as Second"              ~ "ESL"   # Training       
    )
    ,pc3 = program_class3 %>% abbreviate()
    # new variables for aiding custom grouping (driven by research agenda)
    ,asmt_type = assessment_type %>% case_match( # because small and straightforward
      "Employability"                ~ "EA"
      ,"Needs Identification"        ~ "NI"
      ,"Service Needs Determination" ~ "SND"
      ,"ERA"                         ~ "ERA"
    )
    # new variables for aiding custom grouping (driven by research agenda)
    ,fs_type = program_class2 %>% case_match(
      "One Time Issues"              ~ "OTI"
      ,"Expected to Work"            ~ "ETW"
      ,"Barriers to Full Employment" ~ "BFE"
      ,"AISH"                        ~ "AISH"
      # ,TRUE ~ NA # by default
    )
    # custom grouping to aid in graph making = horizontal row
    # this variable controls the custom grouping needed for history graphs
    ,program_group = program_class1 %>% case_match(
      "One Time Issues"     ~ "OTI"  # FS
      ,"Income Support"     ~ "IS"   # FS
      ,"AISH"               ~ "AISH" # FS
      ,"DRES"               ~ "DRES"
      ,"Assessment"         ~ "ASMT"  # Assessment, used to be "EA"
      ,"Career Information" ~ "CI"  # Training
      ,"Training for Work"  ~ "WTR" # that's why can't use pc1
      ,"Work Foundations"   ~ "WTR" # that's why can't use pc1
    ) %>% 
      factor( # from lightest to heaviest
        levels = c(
          "ASMT"
          ,"CI"
          ,"WTR"
          ,"OTI"
          ,"IS"
          ,"DRES"
          ,"AISH"
        )
      ) %>%
      fct_rev() # to reverse the order
  )

# we will keep only episodes of financial support
ds_event %>% count(program_class0)

# Remove dates suspect to data entry errors
ds_event %>% select(date_end, date_start,pc0) %>% group_by(pc0) %>%  skimr::skim()
ds0_event <- 
  ds_event %>% 
  filter(program_class0 == "Financial Support") %>% 
  filter(date_start >= target_window_opens) %>% 
  filter(date_start <= target_window_closes) %>% 
  filter(date_end   >= target_window_opens) %>% 
  filter(date_end   <= target_window_closes) %>% 
  filter(client_type_code %in% c(
    91:93, # AISH
    42:47, # BFE
    11:18 # ETW
  ))
  
ds0_event %>% select(date_end, date_start,pc0) %>% group_by(pc0) %>%  skimr::skim()
# ---- tweak-data-1 -------------------------

reference_date <- target_window_closes
ds1_event <- 
  ds0_event %>% 
  mutate(
    last_month = date_start >= (reference_date %m-% months(1)) & date_start <= reference_date,
    last_year  = date_start >= (reference_date %m-% years(1))  & date_start <= reference_date,
    year = year(date_start)
  ) %>% 
  # add info from Civida
  left_join(
    ds_civida %>% select(person_oid, study_role, head_spouse, relation4 ) %>% 
      distinct() %>% drop_na(person_oid)
  ) %>% 
  filter(relation4 %in% c("Head of Household","Spouse")) 

ds1_event %>% 
  group_by(study_role,pc0, pc1, pc2) %>% 
  summarize(
    row_count = n()
    ,event_count  = n_distinct(edb_service_id)
    ,oid_count = n_distinct(person_oid)
    ,.groups = "drop"
  ) %>% print_all() 

# ---- analysis-below -------------------------------------

# ds2_tenant %>% group_by(tenant_status) %>% summarize(hh_count = n_distinct(tenant))
