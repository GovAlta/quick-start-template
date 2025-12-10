# EDA Style Guide: Exploratory Data Analysis Development Patterns

> **AI Context**: This guide covers systematic exploratory data analysis using R + Quarto workflows. All graphs default to 8.5 × 5.5 inches (letter-size half-page portrait) for print optimization. Reference files: `./scripts/graphing/graph-presets.R`, `./data-public/metadata/`, analysis-specific `local-functions.R`.

## 🔄 The Dual-File Development Pattern

### **Core Workflow: .R Script + .qmd Document**

Example: `./analysis/eda-1/` R + QMD pair

**R Script (`eda-1.R`)**: Your analytical laboratory
- Interactive development and experimentation
- Iterative refinement of visualizations
- Save plots to disk with `ggsave()` - **no `print()` commands**
- Focus on physical output specifications during development

**Quarto Document (`eda-1.qmd`)**: Your publication layer
- Polished reporting with narrative context
- Use `print(plot_object)` in chunks for HTML rendering
- Document your analytical reasoning and findings
- Optimized for communication and sharing

### **Why This Split Matters**

This separation forces deliberate consideration of **physical dimensions** during development. When you use `ggsave()` in the R script, you must think about how the graph will actually be viewed and used. The Quarto document then presents these thoughtfully-crafted visualizations with appropriate context.

```r
# In R script - deliberate about physical output to be more human-friendly
ggsave(paste0(prints_folder, "g21_performance_comparison.png"), 
       g21_plot, width = 8.5, height = 5.5, dpi = 300)
# No print() here - focus on the saved artifact
```

```qmd
<!-- In Quarto - focus on communication -->
```{r g21}
#| fig-cap: "Performance varies significantly by transmission type"
print(g21_plot)  # Print for HTML rendering
```


## 📊 Graph Families: The Heart of Systematic EDA

### **Understanding Graph Families Through Data Ancestry**

A **graph family** is a collection of visualizations that share a common data preparation step. The shared "data ancestor" defined in a `data-prep` chunk serves as a conceptual anchor - a mnemonic for remembering what question or idea this family explores.

Individual graphs within a family may transform the data further for their specific purposes, but they all build from the same foundational dataset that represents a particular analytical perspective.

### **Family Pattern Structure**

```r
# ---- g2-data-prep -------------------------------------------
# Prepare data for vehicle performance exploration family (g2x)
# This data ancestor represents: "How does performance vary by design choices?"
performance_summary <- mtcars %>%
  group_by(am, vs) %>%
  summarise(
    avg_mpg = mean(mpg),
    avg_hp = mean(hp),
    count = n(),
    .groups = "drop"
  ) %>%
  mutate(
    transmission = factor(am, labels = c("Automatic", "Manual")),
    engine = factor(vs, labels = c("V-shaped", "Straight"))
  )

# ---- g21 ----------------------------------------------------
# Family member: Overview comparison using prepared summary
g21_performance_bars <- performance_summary %>%
  ggplot(aes(x = transmission, y = avg_mpg, fill = engine)) +
  geom_col(position = "dodge") +
  labs(title = "Average Fuel Efficiency by Design Choices")

# ---- g21a ---------------------------------------------------
# Slight variation: Same idea but focus on sample size awareness
g21a_performance_bars_weighted <- performance_summary %>%
  ggplot(aes(x = transmission, y = avg_mpg, fill = engine)) +
  geom_col(position = "dodge", alpha = 0.8) +
  geom_text(aes(label = paste0("n=", count)), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 3) +
  labs(title = "Average Fuel Efficiency by Design Choices",
       subtitle = "Sample sizes shown for interpretation context") +
  ylim(0, max(performance_summary$avg_mpg) * 1.1)

# ---- g22 ----------------------------------------------------
# Family member: Detailed individual-level exploration
g22_performance_scatter <- mtcars %>%  # Further transforms the original data
  left_join(performance_summary, by = c("am", "vs")) %>%
  ggplot(aes(x = wt, y = mpg, color = transmission)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Individual Vehicle Performance Patterns")
```

### **Examples of Different Family Approaches**

#### **Family Type 1: Geometric Exploration**
Different ways of visualizing the same conceptual question:

```r
# ---- g3-data-prep -------------------------------------------
# Data ancestor: "What are the patterns in fuel efficiency distribution?"
efficiency_patterns <- mtcars %>%
  mutate(
    efficiency_category = case_when(
      mpg > 25 ~ "High",
      mpg > 15 ~ "Medium", 
      TRUE ~ "Low"
    )
  )

# ---- g31 ----------------------------------------------------
# Histogram view of the distribution
g31_efficiency_histogram <- efficiency_patterns %>%
  ggplot(aes(x = mpg, fill = efficiency_category)) +
  geom_histogram(bins = 12)

# ---- g32 ----------------------------------------------------  
# Boxplot view by categories
g32_efficiency_boxplot <- efficiency_patterns %>%
  ggplot(aes(x = efficiency_category, y = mpg)) +
  geom_boxplot() +
  geom_jitter(width = 0.2, alpha = 0.6)
```

#### **Family Type 2: Assumption Exploration**
Same visualization structure, different analytical assumptions:

```r
# ---- g4-data-prep -------------------------------------------
# Data ancestor: "How do we categorize performance relationships?"
baseline_performance <- mtcars %>%
  mutate(performance_ratio = hp / wt)

# ---- g41 ----------------------------------------------------
# Linear assumption about performance relationship
g41_linear_performance <- baseline_performance %>%
  ggplot(aes(x = wt, y = hp, color = factor(am))) +
  geom_point() +
  geom_smooth(method = "lm")  # Linear assumption

# ---- g42 ----------------------------------------------------
# Non-linear assumption about the same relationship  
g42_nonlinear_performance <- baseline_performance %>%
  ggplot(aes(x = wt, y = hp, color = factor(am))) +
  geom_point() +
  geom_smooth(method = "loess")  # Non-linear assumption
```

### **Naming Convention Logic**

- **`g1`, `g2`, `g3`...**: Individual graphs or family identifiers
- **`g21`, `g22`, `g23`...**: Members of family g2 (all share g2-data-prep ancestor)
- **`g2-data-prep`**: Data preparation chunk for family g2
- **`t1`, `t2`...**: Tables and summaries
- **`m1`, `m2`...**: Models and statistical analyses

The numbering system creates logical groupings while allowing flexibility for exploration within each conceptual area.

## 🎨 Visual Standards & Professional Output

### **Color Palette Integration**

```r
# ---- load-sources --------------------------------------------------------
source("./scripts/graphing/graph-presets.R") # Standardized color palettes
```

**Available palettes for consistent styling:**
- `abcol`: Corporate color palette (grey, magenta, brown, green, blue, yellow)
- `binary_colors`: High contrast, colorblind-safe options
- `acru_colors_9`: Qualitative 9-category palette for complex groupings

**Usage in practice:**
```r
# Subtle integration - use when colors matter for communication
ggplot(data, aes(x = var1, y = var2, fill = category)) +
  geom_col() +
  scale_fill_manual(values = abcol[c("blue", "green", "magenta")]) +
  theme_minimal()
```

### **Print Optimization Standards**

**Default specifications for physical output:**
- **Dimensions**: 8.5 × 5.5 inches (letter-size half-page portrait)
- **Resolution**: 300 DPI for publication quality
- **Format**: PNG for presentations, consider PDF for print

```r
ggsave(paste0(prints_folder, "g21_analysis_name.png"), 
       plot_object, width = 8.5, height = 5.5, dpi = 300)
```

**Why these dimensions:** Half-page portrait fits well in documents while remaining readable. The consistent sizing enables predictable layout planning.


## 🔧 Environment of the Report Document

### **Directory Structure & Management**

```r
# ---- declare-globals ---------------------------------------------------------
local_root <- "./analysis/eda-1/"
local_data <- paste0(local_root, "data-local/")        # Intermediate files
prints_folder <- paste0(local_root, "prints/")         # Plot exports
data_private_derived <- "./data-private/derived/eda-1/" # Final outputs

# Auto-create directories (idempotent operations)
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}
```

**Why these directories matter:**
- `data-local/`: Intermediate processing files that don't need version control
- `prints/`: High-quality plot exports for review and documentation
- `data-private/derived/`: Analysis-ready datasets for restricted access data

### **Package Loading with Defensive Programming**

```r
# ---- load-packages ----------------------------------------------------------
library(magrittr)  # pipes
library(ggplot2)   # graphs
library(dplyr)     # data wrangling
library(tidyr)     # data reshaping

# Specialized packages with graceful fallbacks
if (requireNamespace("ComplexUpset", quietly = TRUE)) {
  library(ComplexUpset)
} else {
  message("ComplexUpset not available - using UpSetR as fallback")
  library(UpSetR)
}
```

The defensive loading pattern prevents script failures while providing clear information about missing capabilities.

### **VS Code Integration Setup**

If you can install Rtools on your machine, you can use the `httpgd` package for interactive plotting in VS Code:
```r
# ---- httpgd (VS Code interactive plots) ------------------------------------
#  Note that unless, you can install Rtools on your machine, httpgd will not function correctly. 
if (requireNamespace("httpgd", quietly = TRUE)) {
  tryCatch({
    if (is.function(httpgd::hgd)) {
      httpgd::hgd()
    } else if (is.function(httpgd::httpgd)) {
      httpgd::httpgd()
    } else {
      httpgd::hgd()  # Generic attempt
    }
    message("httpgd started. Configure VS Code R extension to use it for plots.")
  }, error = function(e) {
    message("httpgd detected but failed to start: ", conditionMessage(e))
  })
} else {
  message("httpgd not installed. Install with: install.packages('httpgd')")
}
```
However, we recommend the approach of hardcoding the physicla dimensions of all visualization during their development, defaulting to 8.5 × 5.5 inches optimizing for being printed on letter-size paper in portrait orientation.

## 🛠️ Local Functions & Code Organization

### **Analysis-Specific Functions**

Create `local-functions.R` for analysis-specific helpers, so your primary R script (e.g. eda-1.R) remains of manageable length:

```r
# ---- declare-functions -------------------------------------------------------
base::source(paste0(local_root, "local-functions.R")) # analysis-specific functions
```

**Example local function with documentation:**
```r
#' Format Summary Statistics for Display
#' 
#' Creates consistent summary formatting across visualizations
#' 
#' @param data Data frame to summarize
#' @param group_vars Character vector of grouping variables
#' @param numeric_vars Character vector of variables to summarize
#' @return Data frame with formatted summary statistics
create_summary_table <- function(data, group_vars, numeric_vars) {
  # Implementation with error checking and consistent formatting
}
```

### **Script Structure Template**

```r
# AI Guidelines: All graphs optimized for 8.5 × 5.5 inch print output
# Context files: ./scripts/graphing/graph-presets.R, ./local-functions.R

# ---- load-packages -----------------------------------------------------------
# Core analytical packages

# ---- load-sources -----------------------------------------------------------  
# Standardized functions and themes

# ---- declare-globals ---------------------------------------------------------
# Directory paths and configuration

# ---- declare-functions -------------------------------------------------------
# Analysis-specific helper functions

# ---- load-data ---------------------------------------------------------------
# Data import and initial processing

# ---- tweak-data-1 -----------------------------------------------------------
# General data transformations

# ---- g1-data-prep -----------------------------------------------------------
# Data preparation for first conceptual exploration

# ---- g1 ---------------------------------------------------------------------- 
# First visualization or visualization family

# ---- g2-data-prep -----------------------------------------------------------
# Data preparation for second conceptual exploration  

# ---- g21 ---------------------------------------------------------------------
# First member of second family

# ---- g22 ---------------------------------------------------------------------
# Second member of second family
```

## 🔍 Quarto Integration Patterns

### **Chunk Configuration Standards**

```qmd
```{r g21}
#| label: g21-performance-comparison
#| code-summary: "Average performance by transmission type" 
#| echo: true
#| message: false
#| warning: false
#| cache: true
#| fig-cap: "Performance varies significantly across transmission types"
#| fig-width: 8.5
#| fig-height: 5.5
print(g21_performance_bars)
```
```

**Key chunk options explained:**
- `cache: true`: Avoid re-running expensive computations
- `fig-width/fig-height`: Match ggsave dimensions for consistency
- `code-summary`: Helpful hover text in rendered output
- `fig-cap`: Descriptive captions that explain the insight

### **Narrative Structure Principle**

**One chunk = One idea = One question = One answer = One visualization**

Each analytical chunk should address a specific question or test a particular hypothesis. This creates a clear narrative flow and makes it easy for readers to follow your reasoning.

## 🚀 Development Workflow in Practice

### **Interactive Development Cycle**

1. **Start in R script** - work interactively with chunks
2. **Develop data-prep chunk** - establish the conceptual foundation
3. **Create family members** - explore different aspects systematically  
4. **Save plots to prints/** - review physical output quality
5. **Add to Quarto when ready** - document findings with narrative context
6. **Iterate based on insights** - let discoveries guide next exploration

### **Professional Quality Checklist**

**Before publishing analysis:**
- [ ] All graph families have clear data-prep ancestors
- [ ] Plot dimensions optimized for intended use (default 8.5 × 5.5)
- [ ] Color choices support communication (subtle corporate palette integration)
- [ ] Chunk names follow logical family structure
- [ ] Local functions documented with purpose and usage
- [ ] Quarto chunks include meaningful captions and context

**Code quality standards:**
- [ ] Defensive package loading with helpful error messages
- [ ] Directory creation is idempotent 
- [ ] Graph objects have descriptive names (`g21_performance_comparison`)
- [ ] Comments explain analytical reasoning, not just code mechanics

## 💡 Advanced Patterns

### **When to Create New Graph Families**

Start a new family (g3, g4, etc.) when you're exploring a fundamentally different question or analytical perspective that requires different data preparation. The data-prep chunk serves as your conceptual bookmark for what this family investigates.

**Same family:** Different geoms, faceting approaches, or visual arrangements of the same conceptual question.

**New family:** Different assumptions about the data, different questions, or different analytical perspectives.

### **Computational Efficiency Patterns**

```r
# Save expensive computations to local_data/
expensive_result_path <- paste0(local_data, "complex_analysis_result.rds")
if (!file.exists(expensive_result_path)) {
  expensive_result <- complex_computation(large_dataset)
  saveRDS(expensive_result, expensive_result_path)
} else {
  expensive_result <- readRDS(expensive_result_path)
}
```

Cache computationally expensive operations to `local_data/` for faster iteration during development.

### **Cross-Family Integration**

Sometimes insights from one family inform another. Document these connections:

```r
# ---- g3-data-prep -------------------------------------------
# Building on insights from g2 family about transmission differences
# Now exploring: "How do those differences manifest in real-world usage?"
usage_patterns <- baseline_data %>%
  filter(mpg > median(mpg)) %>%  # Focus on efficient vehicles from g2 insights
  # ... further analysis
```

## 🎯 Summary: Systematic Exploration

This style guide supports **reproducible curiosity** - structuring exploratory analysis so that both humans and AI can understand the analytical reasoning. The graph family pattern, with its shared data ancestors, provides a systematic way to investigate ideas while maintaining clear organization and communication.

The dual-file workflow ensures that exploration remains rigorous (R script) while communication stays clear (Quarto document). Together, these patterns enable confident, professional exploratory data analysis that serves both discovery and documentation purposes.

---
**Version**: 1.0.0  
**Context**: Data Engineer persona, systematic EDA methodology  
**Updated**: 2025-01-26