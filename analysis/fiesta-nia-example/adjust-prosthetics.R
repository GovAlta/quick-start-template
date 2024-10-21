# ---- load-packages -----------------------------------------------------------
library(tidyverse)
# ---- load-sources ------------------------------------------------------------
source("./scripts/common-functions.R")
# ---- declare-globals ---------------------------------------------------------
base_text_size <- 10
# ---- declare-functions -------------------------------------------------------
print_all <- function(d){ print(d,n=nrow(d) )}
# ---- load-data-0 -------------------------------------------------------------
ds0 <- mtcars
# ---- inspect-data-0 ----------------------------------------------------------
ds0 %>% glimpse()
ds0 %>% count(am)
# ---- tweak-data-1 ------------------------------------------------------------
ds1 <- 
  ds0 %>% 
  mutate(
    automatic_transmission = case_when(
      am == 0L ~ FALSE
      ,am == 1L ~ TRUE
    ) %>% as_factor()
  )
# ---- inspect-data-1 ----------------------------------------------------------
ds1 %>% count(automatic_transmission)

# ---- tweak-data-2 ------------------------------------------------------------
# ---- inspect-data-2 ----------------------------------------------------------

# ---- table-1 -----------------------------------------------------------------
ds1 %>% 
  tableone::CreateTableOne(data=.,strata = "automatic_transmission")
# ---- graph-1 -----------------------------------------------------------------
ds1 %>% 
  ggplot(aes(x=automatic_transmission)) +
  geom_bar()
# ---- graph-2 -----------------------------------------------------------------
ds1 %>% 
  ggplot(aes(x=mpg, y = hp, color = automatic_transmission)) +
  geom_point()
# ---- save-to-disk ------------------------------------------------------------
ds1 %>% 
  readr::write_csv("./data-private/derived/ds1.csv")


