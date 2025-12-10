# nolint start 
# AI agents must consult ./analysis/eda-1/eda-style-guide.md before making changes to this file.
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
library(janitor)  # tidy data
library(testit)   # For asserting conditions meet expected patterns.
library(fs)       # file system operations
# ---- httpgd (VS Code interactive plots) ------------------------------------
# If the httpgd package is installed, try to start it so VS Code R extension
# can display interactive plots. This is optional and wrapped in tryCatch so
# the script still runs when httpgd is absent or fails to start.
if (requireNamespace("httpgd", quietly = TRUE)) {
	tryCatch({
		# Attempt to start httpgd server (API may vary by version); quiet on success
		if (is.function(httpgd::hgd)) {
			httpgd::hgd()
		} else if (is.function(httpgd::httpgd)) {
			httpgd::httpgd()
		} else {
			# Generic call attempt; will be caught if function not found
			httpgd::hgd()
		}
		message("httpgd started (if available). Configure your VS Code R extension to use it for plots.")
	}, error = function(e) {
		message("httpgd detected but failed to start: ", conditionMessage(e))
	})
} else {
	message("httpgd not installed. To enable interactive plotting in VS Code, install httpgd (binary recommended on Windows) or use other devices (svg/png).")
}

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./analysis/eda-1/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/eda-1/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}
# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level

# ---- load-data --------------------------------------

# Load built-in datasets for template demonstration
# In a real project, replace this with your data loading logic:
# - Database connections using connect_books_db() or similar functions
# - CSV/Excel file imports using read.csv(), readxl::read_xlsx(), etc.
# - API data pulls using httr2, jsonlite, etc.

# MAIN DATASET: ds0 - Original data (the foundation of our analysis)
ds0 <- mtcars
ds0$car_name <- rownames(mtcars)  # Add car names as a column
ds0$transmission <- factor(ds0$am, labels = c("Automatic", "Manual"))
ds0$engine_type <- factor(ds0$vs, labels = c("V-shaped", "Straight"))

message("📊 Data loaded:")
message("  - ds0 (original): mtcars with ", nrow(ds0), " observations")
message("  - Additional datasets will be prepared in analysis chunks")

# Optional: Use silent-mini-eda to get an overview of the main dataset
# source("./scripts/silent-mini-eda.R")
# silent_mini_eda("ds_year")

# ---- tweak-data-0 -------------------------------------
# Any additional data cleaning or transformation would go here

# ---- inspect-data-0 -------------------------------------
# Basic structure of loaded datasets
cat("📊 Data Overview:\n")
cat("  - ds0 (original):", nrow(ds0), "observations of", ncol(ds0), "variables\n")
cat("  - Ready for analysis and derived dataset creation\n")

# ---- inspect-data-1 -------------------------------------
# Quick glimpse of the original data structure (ds0)
cat("\n📋 DS0 Structure (Original Data):\n")
ds0 %>% glimpse()
# ---- inspect-data-2 -------------------------------------
# Summary of key variables from ds0
cat("\n📋 DS0 Key Variables Summary:\n")
ds0 %>% 
  select(mpg, hp, wt, cyl, transmission) %>%
  summary() %>%
  print()

# ---- g1 -----------------------------------------------------
# Visualization using original data (ds0) - individual vehicle relationships
g1_weight_vs_mpg <- ds0 %>%
  ggplot(aes(x = wt, y = mpg, color = factor(cyl), size = hp)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = "gray30", linetype = "dashed") +
  scale_color_manual(
    values = c("4" = "steelblue", "6" = "forestgreen", "8" = "firebrick"),
    name = "Cylinders"
  ) +
  scale_size_continuous(name = "Horsepower", range = c(2, 6)) +
  labs(
    title = "Vehicle Weight vs Fuel Efficiency",
    subtitle = "Original data (ds0) - individual vehicle observations", 
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon (MPG)"
  ) +
  theme_minimal()

# Save to prints folder (following template protocol)
ggsave(paste0(prints_folder, "g1_weight_vs_mpg.png"), 
       g1_weight_vs_mpg, width = 8.5, height = 5.5, dpi = 300)
# Note: R script saves to disk - print() added for Quarto display
print(g1_weight_vs_mpg)
# ---- g2-data-prep -------------------------------------------
# Prepare data for g2 visualization - cylinder performance summary
g2_data <- ds0 %>%
  group_by(cyl) %>%
  summarise(
    # Key performance averages by cylinder count
    avg_hp = mean(hp, na.rm = TRUE),
    avg_mpg = mean(mpg, na.rm = TRUE),
    avg_wt = mean(wt, na.rm = TRUE),
    avg_disp = mean(disp, na.rm = TRUE),
    
    # Count of cars in each cylinder group
    n_cars = n(),
    
    # Additional context
    min_hp = min(hp),
    max_hp = max(hp),
    min_mpg = min(mpg),
    max_mpg = max(mpg),
    
    .groups = "drop"
  ) %>%
  arrange(cyl)

message("📊 g2_data prepared: ", nrow(g2_data), " cylinder groups")

# ---- g2 -----------------------------------------------------
# Visualization using g2_data - cylinder performance summary
g2_cylinder_performance <- g2_data %>%
  ggplot(aes(x = factor(cyl), y = avg_hp, fill = factor(cyl))) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = paste0(round(avg_hp, 0), " hp")), 
            vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("4" = "steelblue", "6" = "forestgreen", "8" = "firebrick")) +
  labs(
    title = "Average Horsepower by Cylinder Count",
    subtitle = "Data from g2_data - aggregated performance metrics", 
    x = "Number of Cylinders",
    y = "Average Horsepower",
    fill = "Cylinders"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Save to prints folder (following template protocol)
ggsave(paste0(prints_folder, "g2_cylinder_performance.png"), 
       g2_cylinder_performance, width = 8.5, height = 5.5, dpi = 300)
# Note: R script saves to disk - print() added for Quarto display
print(g2_cylinder_performance)

# ---- g21 ----------------------------------------------------
# Family member: Alternative view of cylinder data - MPG focus instead of HP
g21_cylinder_mpg <- g2_data %>%
  ggplot(aes(x = factor(cyl), y = avg_mpg, fill = factor(cyl))) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = paste0(round(avg_mpg, 1), " mpg")), 
            vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("4" = "steelblue", "6" = "forestgreen", "8" = "firebrick")) +
  labs(
    title = "Average Fuel Efficiency by Cylinder Count",
    subtitle = "Same g2_data, different performance metric focus", 
    x = "Number of Cylinders",
    y = "Average Miles per Gallon (MPG)",
    fill = "Cylinders"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Save to prints folder (R script protocol - no print() here)
ggsave(paste0(prints_folder, "g21_cylinder_mpg.png"), 
       g21_cylinder_mpg, width = 8.5, height = 5.5, dpi = 300)

# nolint end