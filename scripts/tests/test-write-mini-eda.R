# Test: write_mini_eda_json end-to-end smoke test

# Load helper functions from scripts
source("./scripts/silent-mini-eda.R")

# Create a small test dataframe and assign to global env
test_df <- data.frame(
  id = 1:10,
  group = rep(c("A","B"), 5),
  value = rnorm(10),
  date = as.Date('2020-01-01') + 0:9,
  stringsAsFactors = FALSE
)
assign("test_df_for_mini_eda", test_df, envir = .GlobalEnv)

# Run silent mini-EDA
eda_res <- silent_mini_eda("test_df_for_mini_eda", include_samples = TRUE)

# Attempt to write to temp directory under project root
out_path <- write_mini_eda_json(eda_res, script_dir = "./", local_folder = "tmp-local-ai-context-test", overwrite = TRUE)

cat("Wrote test JSON to:", out_path, "\n")

# Validate JSON exists and can be read back
if (!file.exists(out_path)) stop("Test JSON file was not found at: ", out_path)

library(jsonlite)
read_back <- jsonlite::read_json(out_path)

if (is.null(read_back$structure$dataset_name) || read_back$structure$dataset_name != "test_df_for_mini_eda") {
  stop("Read back JSON did not contain expected dataset name")
}

cat("Test passed: mini-EDA JSON written and validated\n")
