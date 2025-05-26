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

sql_events <- "
WITH RESEARCH_COHORT AS (
  SELECT 
  --TOP 1000
        [PERSON_OID],
        [PERIOD_START] AS date_start,
        [PERIOD_END]   AS date_end
    FROM [C-GOA-SQL-10478].[CAO_UAT].[dbo].[TC2_IS_SPELL_BITS] AS b
    WHERE 
        PERIOD_START >= '2014-01-01'  -- Target window opens
        --AND PERIOD_END < '2025-04-01'     -- Target window closes
		    --AND PERSON_OID = 1700479 
),

FINANCIAL_SUPPORT_EVENTS AS (
    SELECT 
        b.[PERSON_OID],
        NULL AS EDB_SERVICE_ID, -- Ensures consistency across event tables
        b.[PERIOD_START] AS date_start,
        b.[PERIOD_END]   AS date_end
    FROM [CAO_UAT].[dbo].[TC2_IS_SPELL_BITS] AS b
    WHERE 
        b.PERSON_OID IN (SELECT a.PERSON_OID FROM RESEARCH_COHORT AS a)
),

TRAINING_EVENTS AS (
    SELECT 
        c.[PERSON_OID],
        c.[EDB_SERVICE_ID],
        c.[START_DATE] AS date_start,
        c.[END_DATE]   AS date_end
    FROM [CAO_UAT].[dbo].[TC_ES_SERVICES] AS c
    WHERE 
        c.[ACTIVE_FLAG] = 1
        AND c.PERSON_OID IN (SELECT a.PERSON_OID FROM RESEARCH_COHORT AS a)
),

ASSESSMENT_EVENTS AS (
    SELECT 
        d.[PERSON_OID],
        d.[EDB_SERVICE_ID],
        d.[ASSESSMENT_DATE] AS date_start, -- Assumed 1-day event
        d.[COMPLETED_DATE]  AS date_end    -- Date might be inaccurate
    FROM [CAO_UAT].[dbo].[TC_EA_EVENTS] AS d
    WHERE 
        d.PERSON_OID IN (SELECT a.PERSON_OID FROM RESEARCH_COHORT AS a)
),

ALL_EVENTS AS (
    SELECT * FROM FINANCIAL_SUPPORT_EVENTS
    UNION ALL
    SELECT * FROM TRAINING_EVENTS
    UNION ALL
    SELECT * FROM ASSESSMENT_EVENTS
)

SELECT 
    E.*, 
    -- Enrich FINANCIAL SUPPORT events
    b.[SPELL_NUMBER],
    b.[SPELL_BIT_NUMBER],
    b.[SPELL_BIT_DURATION],
    --b.[BENEFIT_BIT_DURATION],
    --b.[IS_SPELL_BIT_BENEFIT],
    b.[ROLE_TYPE_START] AS HH_ROLE,
    b.[CLIENT_TYPE_CODE],
    -- Demographic data from FINANCIAL SUPPORT
    b.[GENDER],
    b.[AGE_AS_OF_IS_START_IN_YEARS] AS AGE,
    b.[MARITAL_STATUS],
    b.[TOTAL_DEPENDENT_COUNT],
    -- Enrich TRAINING events
    --c.[PROGRAM_TYPE],
    c.[PROGRAM_TYPE_CODE],
    c.[SERVICE_CATEGORY_CODE],
    --c.[SERVICE_CATEGORY],
    c.[SERVICE_TYPE_CODE],
    --c.[SERVICE_TYPE],
    --c.[TRAINING_PROGRAM_TYPE],
    c.[TRAINING_PROGRAM_TYPE_CODE],
    -- Enrich ASSESSMENT events
    d.[ASSESSMENT_TYPE],
    d.[SERVICE_TYPE_NAME]
FROM ALL_EVENTS AS E
LEFT JOIN [CAO_UAT].[dbo].[TC2_IS_SPELL_BITS] AS b -- FINANCIAL SUPPORT
    ON E.PERSON_OID = B.PERSON_OID
    AND E.DATE_START = B.PERIOD_START 
    AND E.DATE_END = B.PERIOD_END
LEFT JOIN [CAO_UAT].[dbo].[TC_ES_SERVICES] AS c -- TRAINING
    ON E.PERSON_OID = C.PERSON_OID
    AND E.EDB_SERVICE_ID = C.EDB_SERVICE_ID
LEFT JOIN [CAO_UAT].[dbo].[TC_EA_EVENTS] AS d -- ASSESSMENT
    ON E.PERSON_OID = D.PERSON_OID
    AND E.EDB_SERVICE_ID = D.EDB_SERVICE_ID
ORDER BY 
    E.PERSON_OID, 
    E.DATE_START, 
    E.DATE_END;
"


sql_taxonomy <- "
SELECT [program_class0]
      ,[program_class1]
      ,[program_class2]
      ,[program_class3]
      
      ,[service_type_name]
      ,[assessment_type]
      
      ,[program_type_code]
      ,[program_type]
      ,[service_category_code]
      ,[service_category]
      ,[service_type_code]
      ,[service_type]
      
      ,[category_group]
      ,[client_type_code]
      ,[client_type]
      
  FROM [RESEARCH_PROJECT_WAREHOUSE_UAT].[tc2].[PROGRAM_CLASS]
"

# ---- load-data ---------------------------------------------------------------

file_path <- paste0("./data-private/derived/",basename(local_root),"/0-ellis-client-events.parquet")
# disable BELOW after you run it for the first time on your machine
# dsn <- "CAO_UAT" # one per database, typically in config file
# cnn <- DBI::dbConnect(odbc::odbc(),dsn=dsn) # open the connection
# ds_input <- DBI::dbGetQuery(cnn, sql_events)
# ds_input %>% # adding some formatting b/c saves time
#   as_tibble()  %>%
#   janitor::clean_names() %>%
#   mutate_at("client_type_code",~as.integer(.)) %>% 
#   # mutate_at(
#   #   .vars = c("date_start","date_end")
#   #   ,.funs = ~as.Date(.)
#   # ) %>%
#   arrow::write_parquet(file_path)
# DBI::dbDisconnect(cnn) # hang up the phone
# disable ABOVE after you run it for the first time on your machine
ds_event <- arrow::read_parquet(file_path)
rm(ds_input)

dsn <- "RESEARCH_PROJECT_WAREHOUSE_UAT" # one per database, typically in config file
cnn <- DBI::dbConnect(odbc::odbc(),dsn=dsn) # open the connection
ds_taxonomy <-
  DBI::dbGetQuery(cnn, sql_taxonomy) %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  # filter(program_class0 == "Financial Support") %>%
  # select(
  #   starts_with("program_class")
  #   ,client_type_code, client_type, category_group
  #   ,program_type_code, service_category_code, service_type_code
  #   ,assessment_type
  # ) %>%
  arrange(client_type_code)
DBI::dbDisconnect(cnn) # hang up the phone
rm(cnn)



# ---- tweak-data-0 -------------------------------------
# add customized groupings and names for convenient handling
# this was added here to explicate new variables and provide the place for adjusting it
ds0_taxonomy <- 
  ds_taxonomy %>% 
  # add some useful variables
  # these two take a long time, so we isolate them  in this step
  # rename(
  #   pt_code = program_type_code      # to minimize space in the output   
  #   ,sc_code = service_category_code # to minimize space in the output
  #   ,st_code = service_type_code     # to minimize space in the output
  # ) %>%
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

clients_with_data_error <- 
  ds_event  %>% 
  left_join(ds_taxonomy) %>% # cannot match coordinates = dropped from analysis
  filter(is.na(program_class0))%>% # NA when there is no match
  pull(person_oid) %>% 
  unique()
cat("Total number of clients drops = ",length(clients_with_data_error))

# classify each even withing the program_class0123 taxonomy by joining
ds0 <-
  ds_event %>% 
  filter(person_oid %not in% clients_with_data_error ) %>% # we  drop all data points of these clients
  left_join(ds0_taxonomy) %>% 
  relocate(c("category_group","client_type"), .after = "client_type_code") %>% 
  relocate(starts_with("program_class"),.after = "service_type_name") %>% 
  rename(
    pt_code = program_type_code      # to minimize space in the output
    ,sc_code = service_category_code # to minimize space in the output
    ,st_code = service_type_code     # to minimize space in the output
  )
ds0 %>% glimpse()


# ---- write-to-disk -------------------------
OuhscMunge::verify_value_headstart(ds0)
checkmate::assert_integer(  ds0$person_oid                 , any.missing=F , lower=-9952410, upper=6109036    )
checkmate::assert_integer(  ds0$edb_service_id             , any.missing=T , lower=-96530139, upper=162750550 )
checkmate::assert_character(ds0$date_start                 , any.missing=F , pattern="^.{10,10}$"             )
checkmate::assert_character(ds0$date_end                   , any.missing=T , pattern="^.{10,10}$"             )
checkmate::assert_integer(  ds0$spell_number               , any.missing=T , lower=1, upper=28                )
checkmate::assert_integer(  ds0$spell_bit_number           , any.missing=T , lower=1, upper=47                )
checkmate::assert_integer(  ds0$spell_bit_duration         , any.missing=T , lower=1, upper=300               )
checkmate::assert_character(ds0$hh_role                    , any.missing=T , pattern="^.{2,2}$"               )
checkmate::assert_numeric(  ds0$client_type_code           , any.missing=T , lower=11, upper=93               )
checkmate::assert_character(ds0$category_group             , any.missing=T , pattern="^.{3,16}$"              )
checkmate::assert_character(ds0$client_type                , any.missing=T , pattern="^.{8,85}$"              )
checkmate::assert_character(ds0$gender                     , any.missing=T , pattern="^.{1,7}$"               )
checkmate::assert_integer(  ds0$age                        , any.missing=T , lower=0, upper=118               )
checkmate::assert_character(ds0$marital_status             , any.missing=T , pattern="^.{6,10}$"              )
checkmate::assert_integer(  ds0$total_dependent_count      , any.missing=T , lower=0, upper=12                )
checkmate::assert_character(ds0$pt_code                    , any.missing=T , pattern="^.{2,4}$"               )
checkmate::assert_character(ds0$sc_code                    , any.missing=T , pattern="^.{2,8}$"               )
checkmate::assert_character(ds0$st_code                    , any.missing=T , pattern="^.{2,7}$"               )
checkmate::assert_character(ds0$training_program_type_code , any.missing=T , pattern="^.{3,7}$"               )
checkmate::assert_character(ds0$assessment_type            , any.missing=T , pattern="^.{3,27}$"              )
checkmate::assert_character(ds0$service_type_name          , any.missing=T , pattern="^.{22,24}$"             )
checkmate::assert_character(ds0$program_class0             , any.missing=F , pattern="^.{8,17}$"              )
checkmate::assert_character(ds0$program_class1             , any.missing=F , pattern="^.{4,18}$"              )
checkmate::assert_character(ds0$program_class2             , any.missing=F , pattern="^.{3,27}$"              )
checkmate::assert_character(ds0$program_class3             , any.missing=F , pattern="^.{3,85}$"              )
checkmate::assert_character(ds0$program_type               , any.missing=T , pattern="^.{16,42}$"             )
checkmate::assert_character(ds0$service_category           , any.missing=T , pattern="^.{8,25}$"              )
checkmate::assert_character(ds0$service_type               , any.missing=T , pattern="^.{7,47}$"              )
checkmate::assert_character(ds0$pc0                        , any.missing=F , pattern="^.{2,2}$"               )
checkmate::assert_character(ds0$pc1                        , any.missing=F , pattern="^.{2,4}$"               )
checkmate::assert_character(ds0$pc2                        , any.missing=F , pattern="^.{2,4}$"               )
checkmate::assert_character(ds0$pc3                        , any.missing=F , pattern="^.{3,22}$"              )
checkmate::assert_character(ds0$asmt_type                  , any.missing=T , pattern="^.{2,3}$"               )
checkmate::assert_character(ds0$fs_type                    , any.missing=T , pattern="^.{3,4}$"               )
checkmate::assert_factor(   ds0$program_group              , any.missing=F                                    )

# If a database already exists, this single function uploads to a SQL Server database.
OuhscMunge::upload_sqls_odbc(
  d             = ds0,
  schema_name   = "P20250520",         # Or config$schema_name,
  table_name    = "SERVICE_EVENT_V01",
  dsn_name      = "RESEARCH_PROJECT_CACHE_UAT", # Or config$dsn_qqqqq,
  # timezone      = config$time_zone_local, # Uncomment if uploading non-UTC datetimes
  clear_table   = T, # drops all the rows
  create_table  = T # if T will overwrite manual adjustment of field format
) # write time here


file_path <- paste0("./data-private/derived/",basename(local_root),"/0-ellis-taxonomy.parquet")
ds0_taxonomy %>% arrow::write_parquet(file_path)
ds0_taxonomy <- arrow::read_parquet(file_path)
rm(file_path)

# skimr::skim(ds0 %>% select(date_start, date_end))
# ---- tweak-data-1 -------------------------
# reference_date <- as.Date("2025-04-05")
# ds1_event <- 
#   ds0_event %>% 
#   mutate(
#     last_month = date_start >= (reference_date %m-% months(1)) & date_start <= reference_date,
#     last_year  = date_start >= (reference_date %m-% years(1))  & date_start <= reference_date,
#     year = year(date_start)
#   ) %>% 
#   # add info from Civida
#   left_join(
#     ds_civida %>% select(person_oid, study_role, head_spouse, relation4 ) %>% 
#       distinct() %>% drop_na(person_oid)
#   ) %>% 
#   filter(relation4 %in% c("Head of Household","Spouse")) 
# 
# ds1_event %>% 
#   group_by(study_role,pc0, pc1, pc2) %>% 
#   summarize(
#     row_count = n()
#     ,event_count  = n_distinct(edb_service_id)
#     ,oid_count = n_distinct(person_oid)
#     ,.groups = "drop"
#   ) %>% print_all() 

# ---- analysis-below -------------------------------------

# ds2_tenant %>% group_by(tenant_status) %>% summarize(hh_count = n_distinct(tenant))
