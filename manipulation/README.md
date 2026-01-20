# `manipulation/` Directory

Files in this directory manipulate/groom/munge the project data.

They typically intake raw data from `./data-public/raw` and/or `./data-private/raw` and transform them into tidy objects, which would be convenient to place into literate scripts (e.g. `.Rmd` or `.qmd`) for exploration and annotation. For example, consider a simple project described in [RAnalysisSkeleton](https://github.com/wibeasley/RAnalysisSkeleton), featuring the ubiquitous `cars` data set:

![](images/flow-skeleton-car.png)

The script `./manipulation/car-ellis.R` digests a raw `.csv` file from `./data-public/raw` and creates a clean data object `car.rds`, so-called *analysis-ready rectangle*. This object becomes the starting point for the literate script `./analysis/car-report-1/car-report-1.Rmd` which renders a self-contained document `car-report-1.hmtl` , the deliverable in this simple project. In this case, the [ellis and scribe patterns](https://ouhscbbmc.github.io/data-science-practices-1/patterns.html) are combined in the single script.

Please follow these [instructions](https://github.com/wibeasley/RAnalysisSkeleton#establishing-a-workstation-for-analysis) to execute the entire pipline of the RAnalysisSkeleton repo and examine `./analysis/car-report-1/car-report-1.html` for examples of code syntax for most basic tasks in data analysis. This template is useful for simple, one-off projects, like a straightforward information request with a quick turn-over.

However, a more realistic project involves multiple data sources and may call for separate tidy data sets to accommodate the specific requirement of a given task (e.g. feed into a statistical model vs serve as a data source for a dashboard). Consider the following example in which 20 children who live across three different counties are measured each year for 10 years on some physical and cognitive abilities to study their growth and to estimate how county characteristics (which are also measured each year) influence children's physical and mental growth.

![](images/flow-skeleton-02.png)

We may want to explore county-level characteristics (`te.rds`) separtely from person-level characteristics (`mlm.rds`), hence two different rectangles, optimized for each task.

The resulting "derived" datasets produce less friction when analyzing. By centralizing most (and ideally all) of the manipulation code in one place, it's easier to determine how the data was changed before analyzing. It also reduces duplication of manipulation code, so analyses in different files are more consistent and understandable.

# GOA example 

It might be easier to think in terms of an example more relevant to our substantive focus:

![](images/flow-skeleton.png)

---

# Ferry and Ellis Patterns: Philosophy and Implementation Guide

This directory contains two core data manipulation patterns that form the backbone of reproducible research data pipelines: **Ferry** and **Ellis**. These patterns provide structured, scalable approaches to data transport and transformation.

## Pattern Philosophy

### Ferry Pattern: Data Transport (`ferry-lane-example.R`)

**Metaphor**: A ferry transports cargo between shores without altering the contents.

**Purpose**: Move raw data from operational sources (WAREHOUSE, APIs, files) to research staging areas (CACHE) with minimal transformation—only what's necessary for technical transport.

**Core Principles**:
- **Fidelity**: Preserve source data structure and values
- **Documentation**: Log data lineage and transport metadata
- **Reliability**: Robust error handling and validation
- **Efficiency**: Optimize for data volume and frequency

**Permitted Transformations** (technical only):
- Character encoding fixes (UTF-8 conversion)
- Column name sanitization (spaces → underscores)
- Data type coercion for database compatibility
- Timestamp injection for tracking

**Forbidden Transformations** (semantic/analytical):
- Factor recoding or categorical standardization
- Derived variables or calculated fields
- Missing data imputation
- Aggregation or filtering based on business logic

**Output**: Raw or minimally-processed staging data ready for Ellis transformation.

### Ellis Pattern: Data Transformation (`ellis-lane-example.R`)

**Metaphor**: Ellis Island processed immigrants—inspecting, documenting, standardizing—before entry into the new system.

**Purpose**: Transform staged data into clean, analysis-ready datasets with complete documentation and quality validation.

**Core Principles**:
- **Quality**: Comprehensive validation and integrity checks
- **Standardization**: Apply taxonomies, naming conventions, data types
- **Reproducibility**: All transformations scripted and version-controlled
- **Documentation**: Generate complete data dictionaries (CACHE-manifest)

**Required Transformations**:
1. **Column Name Standardization**: `janitor::clean_names()` for consistency
2. **Factor Recoding**: Apply project taxonomies with explicit level definitions
3. **Data Type Verification**: Ensure numerics, dates, characters are properly typed
4. **Missing Data Handling**: Explicit NA treatment, imputation rules documented
5. **Derived Variables**: Create analytical variables with clear formulas
6. **EDA-Informed Validation**: Minimal exploration to verify transformations

**Output**: Analysis-ready datasets saved to:
- CACHE database (project schema)
- Parquet files (`./data-private/derived/ellis/`)
- CACHE-manifest.md (comprehensive data dictionary)

---

## AI Implementation Instructions

### When to Use Each Pattern

**Use Ferry** when:
- Connecting to new operational data sources (databases, APIs, file shares)
- Data structure matches analytical needs (minimal transformation required)
- Focus is on reliable, repeatable data extraction
- Building initial data pipeline infrastructure

**Use Ellis** when:
- Raw data requires semantic transformation for analysis
- Multiple sources need standardization to common taxonomy
- Data quality issues need systematic correction
- Complete data documentation (data dictionary) is required
- Preparing datasets for statistical analysis or reporting

**Use Both** (typical workflow):
1. **Ferry**: Transport from WAREHOUSE → CACHE staging schema
2. **Ellis**: Transform from CACHE staging → CACHE project schema (analysis-ready)

### Adapting Patterns to Real Project Lanes

#### Ferry Lane Adaptation

When implementing a new ferry lane (e.g., `1-ferry-customer-data.R`):

1. **Naming**: `{order}-ferry-{domain}.R` (e.g., `1-ferry-IS.R`, `2-ferry-eligibility.R`)

2. **Source Configuration**:
   - **Database**: Configure DSN in `config.yml`, use ODBC connection
   - **API**: Use `httr2` or similar, store credentials in environment variables
   - **Files**: Document expected file location, naming convention, format

3. **Technical Transformations Only**:
   ```r
   # ✅ ALLOWED (technical)
   ds <- ds %>%
     mutate(
       # Fix encoding
       across(where(is.character), ~iconv(., to = "UTF-8")),
       # Sanitize column names
       .before = 1
     ) %>%
     janitor::clean_names() %>%
     mutate(
       # Add transport metadata
       ferry_timestamp = Sys.time(),
       ferry_source = "WAREHOUSE._SOURCE.table_name"
     )
   
   # ❌ FORBIDDEN (semantic)
   # transmission = factor(am, levels = c(0,1), labels = c("Auto", "Manual"))
   # efficiency = case_when(mpg >= 25 ~ "High", ...)
   ```

4. **Quality Checks**:
   - Row count verification (expected vs actual)
   - Required column presence validation
   - Data type consistency checks
   - Log discrepancies, don't silently fix semantic issues

5. **Output Destinations**:
   - Primary: CACHE database (staging schema like `_TEST` or `STG_{YYYYMMDD}`)
   - Backup: Parquet files in `./data-private/derived/ferry/`

#### Ellis Lane Adaptation

When implementing a new ellis lane (e.g., `3-ellis-combined.R`):

1. **Naming**: `{order}-ellis-{domain}.R` (e.g., `3-ellis-IS.R`, `5-ellis-combined.R`)

2. **Source**: Always consume from Ferry output (CACHE staging) or raw files

3. **Transformation Sequence** (maintain this order):
   ```r
   # Step 1: Column names
   ds1 <- ds0 %>% janitor::clean_names()
   
   # Step 2: Factor recoding (apply project taxonomy)
   ds2 <- ds1 %>%
     mutate(
       status = factor(status_code, 
                      levels = c(1, 2, 3),
                      labels = c("Active", "Inactive", "Pending"))
     )
   
   # Step 3: Derived variables
   ds3 <- ds2 %>%
     mutate(
       tenure_years = as.numeric(difftime(exit_date, start_date, units = "days")) / 365.25,
       age_group = cut(age, breaks = c(0, 18, 35, 55, 100),
                      labels = c("Youth", "Young Adult", "Middle Age", "Senior"))
     )
   
   # Step 4: Missing data handling
   ds4 <- ds3 %>%
     mutate(
       income = replace_na(income, median(income, na.rm = TRUE))
     )
   
   # Step 5: Data type verification
   ds_clean <- ds4 %>%
     mutate(
       across(c(amount, salary), as.numeric),
       across(ends_with("_date"), lubridate::ymd)
     )
   ```

4. **Validation Requirements**:
   - Factor distributions: `summarize_factors(ds_clean)` (print to console)
   - Numeric summaries: `summary(select(ds_clean, key_vars))`
   - Diagnostic plots: Save to `./manipulation/ellis-prints/`
   - Missing data report: `summarize_missing(ds_clean)`

5. **Output Destinations**:
   - CACHE database: Project schema (e.g., `P{YYYYMMDD}.table_name`)
   - Parquet: `./data-private/derived/ellis/{table_name}_analysis_ready.parquet`
   - **CACHE-manifest.md**: Generate comprehensive data dictionary (invoke AI)

6. **CACHE-manifest Generation**:
   After Ellis completion, invoke AI with this prompt:
   ```
   Generate CACHE-manifest.md for this Ellis output. Include:
   - Dataset name, location (CACHE table + parquet path)
   - Source data lineage (Ferry origin)
   - Record count and column inventory with descriptions
   - All transformations applied (factors, derived vars, data types)
   - Factor level definitions (complete taxonomy)
   - Data quality metrics (missing values, validation results)
   - Usage notes for downstream analysts
   - Generation timestamp and script reference
   
   Target: ./data-public/metadata/CACHE-manifest.md
   ```

### Multi-Source Integration Pattern

For projects combining multiple data sources:

```r
# 1-ferry-source-A.R → CACHE.STG.source_a
# 2-ferry-source-B.R → CACHE.STG.source_b
# 3-ferry-source-C.R → CACHE.STG.source_c
# ↓
# 4-ellis-source-A.R → CACHE.P{YYYYMMDD}.source_a_clean
# 5-ellis-source-B.R → CACHE.P{YYYYMMDD}.source_b_clean  
# 6-ellis-source-C.R → CACHE.P{YYYYMMDD}.source_c_clean
# ↓
# 7-ellis-combined.R → CACHE.P{YYYYMMDD}.analysis_ready
#   (joins, harmonizes, creates final analytical dataset)
```

### Error Handling and Logging

Both patterns should include:
```r
# Timing
script_start <- Sys.time()

# Error handling example
tryCatch({
  ds <- DBI::dbGetQuery(cnn, sql)
}, error = function(e) {
  cat("❌ ERROR:", conditionMessage(e), "\n")
  cat("   SQL:", sql, "\n")
  stop("Ferry failed: database query error")
})

# Completion logging
script_duration <- difftime(Sys.time(), script_start, units = "secs")
cat("\n✅ Completed in", round(as.numeric(script_duration), 1), "seconds\n")
```

### Integration with flow.R

Lane scripts should be orchestrated through `flow.R`:
```r
# flow.R excerpt
source("./manipulation/1-ferry-warehouse-extract.R")
source("./manipulation/2-ellis-clean-transform.R")
source("./analysis/eda-1/eda-1.R")  # consumes Ellis output
```

---

## Quick Reference

| Aspect | Ferry | Ellis |
|--------|-------|-------|
| **Purpose** | Transport raw data | Transform to analysis-ready |
| **Input** | WAREHOUSE, APIs, files | CACHE staging, raw files |
| **Output** | CACHE staging, parquet backup | CACHE project schema, parquet, CACHE-manifest |
| **Transformations** | Technical only | Semantic + analytical |
| **Documentation** | Transport log | Complete data dictionary |
| **Quality Focus** | Transmission integrity | Data content quality |
| **Naming** | `{n}-ferry-{domain}.R` | `{n}-ellis-{domain}.R` |

---

## Example Workflows

**Simple Project** (single source):
```
WAREHOUSE.dbo.customers 
  → ferry-customers.R → CACHE._TEST.customers_raw
  → ellis-customers.R → CACHE._TEST.customers_clean + CACHE-manifest.md
```

**Complex Project** (multiple sources, integration):
```
Source A → ferry → staging → ellis → clean_a ↘
Source B → ferry → staging → ellis → clean_b  → combined_analysis_ready
Source C → ferry → staging → ellis → clean_c ↗
```

This pattern system ensures:
- **Reproducibility**: All data lineage is scripted and documented
- **Quality**: Systematic validation at each stage
- **Transparency**: Clear separation of technical vs semantic transformations
- **Scalability**: Patterns work for simple and complex projects
- **Collaboration**: Standardized approach across team members
