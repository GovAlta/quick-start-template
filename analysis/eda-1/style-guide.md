# EDA Style Guide: Professional R + Quarto Workflows

> **Companion to workflow-guide.md** - This document captures advanced styling conventions and professional practices for analytical scripts.

## 🎨 **Alberta Corporate Visual Identity**

### **Color Palette Integration**
Always source the standardized color palette:

```r
# ---- load-sources --------------------------------------------------------
source("./scripts/graphing/graph-presets.R") # Alberta corporate colors
```

**Available Palettes:**
- **`abcol`**: Main Alberta corporate colors (grey, magenta, brown, green, blue, yellow)
- **`binary_colors`**: High contrast colorblind-safe palette  
- **`acru_colors_9`**: Qualitative 9-category printer-friendly palette
- **`pal_direction_significance`**: For model effects visualization

**Usage Example:**
```r
ggplot(data, aes(x = var1, y = var2, fill = category)) +
  geom_col() +
  scale_fill_manual(values = abcol[c("blue", "green", "magenta")]) +
  theme_minimal()
```

### **Print Optimization Standards**
- **Default dimensions**: 8.5 × 5.5 inches (letter-size half-page portrait)
- **DPI**: 300 for publication quality
- **File format**: PNG for presentations, PDF for print
- **Text sizing**: Optimized for readability when printed

```r
ggsave(paste0(prints_folder, "g21_analysis_name.png"), 
       plot_object, width = 8.5, height = 5.5, dpi = 300)
```

## 📋 **Script Structure & Documentation**

### **Header Standards**
Include AI guidelines and context at script top:

```r
# AI guidelines
# All graphs in this script are intended to be printed out on letter-size paper, 
# by default on a half-page in portrait orientation (8.5 x 5.5 inches), unless 
# specified otherwise. Optimize for viewing in this mode and adapt to HTML documents.

# Context files for AI copilot:
# ./path/to/relevant/reference.R
# ./data-public/metadata/data-dictionary.md
```

### **Package Loading Best Practice**
Use conditional loading with informative messages:

```r
# ---- load-packages -----------------------------------------------------------
library(magrittr)  # pipes
library(ggplot2)   # graphs
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling

# Specialized packages with conditional loading
if (requireNamespace("ComplexUpset", quietly = TRUE)) {
  library(ComplexUpset)
} else {
  message("ComplexUpset not available - will use UpSetR as fallback")
}
```

### **VS Code Integration Setup**
Robust httpgd integration for interactive plotting:

```r
# ---- httpgd (VS Code interactive plots) ------------------------------------
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

## 🗂️ **Directory Management**

### **Enhanced Directory Setup**
Auto-create all necessary directories:

```r
# ---- declare-globals ---------------------------------------------------------
local_root <- "./analysis/eda-N/"
local_data <- paste0(local_root, "data-local/")        # Intermediate files
prints_folder <- paste0(local_root, "prints/")         # Plot exports
data_private_derived <- "./data-private/derived/eda-N/" # Final outputs

# Auto-create directories (idempotent)
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}
```

### **Local Functions Integration**
Keep analysis-specific functions in dedicated file:

```r
# ---- declare-functions -------------------------------------------------------
base::source(paste0(local_root, "local-functions.R")) # analysis-specific functions
```

## 📊 **Advanced Graph Family Patterns**

### **R Script vs Quarto Printing Protocol**
**R Script Behavior:**
- Create plot objects and save to disk with `ggsave()`
- NO `print()` commands in R script - forces dimension awareness
- Focus on physical output specifications during development

**Quarto Document Behavior:**
- Use `print(plot_object)` in chunks for HTML publication
- Leverage `read_chunk()` to reference R script chunks
- Optimize for web display while maintaining print quality

### **Data Preparation Chunk Pattern**
Always precede graph families with dedicated data preparation:

```r
# ---- g2-data-prep -------------------------------------------
# Prepare data for vehicle performance comparison family (g2x)
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

# Helper function for consistent label formatting
format_count_label <- function(count) {
  ifelse(count < 1000, 
         as.character(count),
         paste0(round(count/1000, 1), "K"))
}
```

### **Graph Family Implementation**
Create systematic variants that share data preparation:

```r
# ---- g21 ----------------------------------------------------
# Performance overview: bar chart comparison
g21_performance_bars <- performance_summary %>%
  ggplot(aes(x = transmission, y = avg_mpg, fill = engine)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = abcol[c("blue", "green")]) +
  labs(
    title = "Average Fuel Efficiency by Transmission Type",
    subtitle = "Comparison across engine configurations",
    x = "Transmission Type",
    y = "Average MPG"
  ) +
  theme_minimal()

ggsave(paste0(prints_folder, "g21_performance_bars.png"), 
       g21_performance_bars, width = 8.5, height = 5.5, dpi = 300)
# Note: R script saves to disk only - no print() command here

# ---- g22 ----------------------------------------------------
# Performance detail: scatter plot with trend lines
g22_performance_scatter <- mtcars %>%
  ggplot(aes(x = wt, y = mpg, color = factor(am))) +
  geom_point(size = 2) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_manual(
    values = abcol[c("magenta", "brown")],
    labels = c("Automatic", "Manual"),
    name = "Transmission"
  ) +
  labs(
    title = "Weight vs Fuel Efficiency Relationship",
    subtitle = "Linear trends by transmission type",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  ) +
  theme_minimal()

ggsave(paste0(prints_folder, "g22_performance_scatter.png"), 
       g22_performance_scatter, width = 8.5, height = 5.5, dpi = 300)
```

### **Consistent Object Naming**
Use descriptive names that indicate both graph number and content:

```r
g1_overview_distribution
g21_performance_bars
g22_performance_scatter  
g3_model_diagnostics
```

## 🔧 **Local Functions Best Practices**

### **Function Documentation Template**
Use roxygen2-style documentation in `local-functions.R`:

```r
#' Display Summary Statistics with Formatting
#' 
#' Creates formatted summary tables for multiple variables with
#' consistent styling for HTML or terminal output
#' 
#' @param data Data frame. The dataset to summarize
#' @param vars Character vector. Variable names to include  
#' @param publishing_in Character. Output format: "terminal" or "html"
#' @return Prints formatted summary table
display_summary_stats <- function(data, vars, publishing_in = "terminal") {
  # Function implementation here...
}
```

### **Package Dependencies in Functions**
Include defensive package checking:

```r
# Ensure required packages are available
if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("dplyr package is required for local functions")
}
if (!requireNamespace("knitr", quietly = TRUE)) {
  stop("knitr package is required for local functions")  
}
```

## 📝 **Quarto Integration Standards**

### **Chunk Options Template**
Use consistent chunk options across analyses:

````qmd
```{r g21}
#| label: g21-performance-bars
#| code-summary: Display performance comparison bar chart
print(g21_performance_bars)  # Print for HTML output
```

**Template for all chunk types:**
```{r}
#| label: chunk-name
#| code-summary: Brief description of chunk purpose
#| echo: true/false
#| results: show/hide
#| message: false
#| warning: false
#| cache: true
#| fig-cap: "Descriptive figure caption"
#| fig-width: 8.5
#| fig-height: 5.5
#| code-fold: true/false
```
````

### **Figure Sizing Standards**
Match R script output dimensions:

```qmd
opts_chunk$set(
  fig.width = 8.5,    # inches - matches ggsave width
  fig.height = 5.5,   # inches - matches ggsave height  
  fig.path = 'figure-png-iso/',
  out.width = "960px" # HTML display optimization
)
```

## 🚀 **Professional Workflow Checklist**

### **Before Starting Analysis**
- [ ] Source `graph-presets.R` for Alberta colors
- [ ] Enable `httpgd` for VS Code integration
- [ ] Create all necessary directories
- [ ] Set up `local-functions.R` if needed
- [ ] Add AI guidelines header to R script

### **During Development**  
- [ ] Use graph family pattern (g2-data-prep → g21, g22, etc.)
- [ ] Test chunks interactively in VS Code
- [ ] Save plots to `prints/` with `ggsave()` - NO `print()` in R script
- [ ] Use `print(plot_object)` only in Quarto chunks for HTML output
- [ ] Follow Alberta color palette guidelines
- [ ] Document context files for AI assistance

### **Before Publishing**
- [ ] Verify all graphs use appropriate Alberta colors
- [ ] Check print dimensions are optimized (8.5 × 5.5 inches)
- [ ] Ensure graph objects have descriptive names
- [ ] Test Quarto rendering with `read_chunk()` integration
- [ ] Validate local functions work with conditional packages

### **Narrative Structure Principle**
Structure documents as a dialogue between analyst and reader. Each chunk should:

One chunk = one idea = one question = one answer = one visualization or table

---

**Style Guide Version**: 1.0.0  
**Compatible with**: Grapher Persona, Alberta Corporate Visual Identity  
**Last Updated**: 2025-01-26



