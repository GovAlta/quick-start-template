# eda-1 Workflow Guide: .R + .qmd Development Pattern

> **AI Guidelines**: All graphs in this script should be optimized for letter-size paper, defaulting to half-page portrait orientation (8.5 × 5.5 inches). Follow Alberta's Corporate Visual Identity guidelines for colors (see `scripts/graphing/graph-presets.R`).

This is an example file. Change the content to match your project.

## Overview

This directory implements a **dual-file workflow** for exploratory data analysis following the FIDES framework:

- **`eda-1.R`**: Analytical development layer (experimentation & refinement)
- **`eda-1.qmd`**: Publication layer (polished reporting & documentation)

## 🔄 Development Workflow

### **🎯 Key Protocol: R Script vs Quarto Printing**
- **R Script**: Save plots to disk with `ggsave()` - NO `print()` commands
- **Quarto**: Use `print(plot_object)` in chunks for HTML publication  
- This forces deliberate consideration of physical dimensions during development

### 1. **Develop in R Script First**
Work interactively in `eda-1.R`:
```r
# Add new analysis chunks with clear labels
# ---- g2 ----------------------------------------
# Car performance by transmission type
mtcars %>%
  ggplot(aes(x = wt, y = mpg, color = factor(am))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  # ... develop your visualization
```

### 2. **Test and Refine Interactively**
- Run chunks line-by-line in VS Code R extension
- Iterate on data transformations and visualizations
- Save plots to `prints/` folder for review
- Use enhanced `httpgd` integration (see template for robust setup)
- Test with Alberta color palettes from `graph-presets.R`

### 3. **Publish to Quarto When Ready**
When you're satisfied with a chunk in the R script:

```qmd
### Car Performance Analysis

```{r}
#| label: g2
#| code-summary: Weight vs MPG by transmission type
#| code-fold: false
#| eval: true
#| cache: true
#| fig-cap: "Relationship between weight and fuel efficiency"
```
```

## 📁 Directory Structure

```
analysis/eda-1/
├── eda-1.R           # Development & experimentation layer
├── eda-1.qmd         # Publication & reporting layer  
├── workflow-guide.md # This guide
├── style-guide.md    # Conventions for reporting & graphing
├── data-local/       # Local outputs and intermediate files
└── prints/           # Saved plots and figures
```

## 🎯 Enhanced Chunk Naming Convention

Use consistent, meaningful chunk labels that work across both files:

### **Graph Families & Data Preparation**
- **`g1`, `g2`, `g3`...**: Single graphs/visualizations
- **`g21`, `g22`, `g23`...**: Graph family variants (all g2x belong to family g2)
- **`g2-data-prep`**: Data preparation chunk preceding graph family g2

### **Other Analysis Components**
- **`t1`, `t2`, `t3`...**: Tables/summaries  
- **`m1`, `m2`, `m3`...**: Models/statistical analysis
- **`tweak-data-N`**: Data transformations
- **`inspect-data-N`**: Data exploration

### **Graph Naming Best Practice**
Each graph object should be named with clear descriptive suffix:
```r
# ---- g1 -----------------------------------------------------
g1_performance_by_transmission <- mtcars %>% 
  ggplot(aes(x = wt, y = mpg)) + # ...

# ---- g2-data-prep -------------------------------------------
# Prepare data for transmission comparison family (g2x)
g2_summary_data <- mtcars %>%
  group_by(am, vs) %>%
  summarise(avg_mpg = mean(mpg), .groups = "drop")

# ---- g21 ----------------------------------------------------
g21_transmission_boxplot <- g2_summary_data %>% # ...

# ---- g22 ----------------------------------------------------  
g22_transmission_scatter <- g2_summary_data %>% # ...
```

## 🔗 Data Integration & Visual Identity

### **Alberta Corporate Visual Identity**
Always source color palettes and theme settings:

```r
# ---- load-sources --------------------------------------------------------
source("./scripts/graphing/graph-presets.R") # Alberta corporate colors

# Available palettes:
# - abcol: Main Alberta corporate colors  
# - binary_colors: High contrast colorblind-safe
# - acru_colors_9: Qualitative 9-category palette
```

### **Enhanced Directory Setup**
```r
# ---- declare-globals -----------------------------------------------------
local_root <- "./analysis/eda-1/"
local_data <- paste0(local_root, "data-local/") 
prints_folder <- paste0(local_root, "prints/")
data_private_derived <- "./data-private/derived/eda-1/"

# Auto-create directories
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}
```

### **Local Functions Integration**
```r
# ---- declare-functions ---------------------------------------------------
base::source(paste0(local_root,"local-functions.R")) # analysis-specific functions
```

## 💡 Best Practices

### R Script Development
1. **Use chunk labels** that match between .R and .qmd files
2. **Follow Alberta visual identity** - always source `graph-presets.R`
3. **Optimize for print** - default to 8.5 × 5.5 inch dimensions
4. **Use graph families** - create g2-data-prep before g21, g22, etc.
5. **Save intermediate results** to `data-local/` if computationally expensive
6. **Export key plots** to `prints/` folder for documentation
7. **Comment generously** - explain your analytical thinking
8. **Test iteratively** - run chunks interactively before committing

### Quarto Publication
1. **Add context** - explain what each visualization shows
2. **Use meaningful captions** with `fig-cap` 
3. **Control code visibility** with `code-fold` appropriately
4. **Cache expensive operations** with `cache: true`
5. **Write for your audience** - assume non-technical readers
6. **Include AI guidelines** at script top for context

### Development Environment
1. **Enable httpgd** for interactive VS Code plotting (see template)
2. **Create local-functions.R** for analysis-specific helper functions
3. **Document context files** in script comments for AI assistance
4. **Use robust package loading** with conditional library calls

## 🚀 Getting Started

1. **Setup environment** - source `graph-presets.R` and enable `httpgd`
2. **Open both files** in VS Code side-by-side
3. **Start in eda-1.R** - run the data loading chunks
4. **Develop your first graph** in the `g1` section using Alberta colors
5. **Test interactively** with VS Code R extension
6. **Save plots** to `prints/` folder (optimized for 8.5 × 5.5 inches)
7. **Add corresponding chunk** to eda-1.qmd
8. **Render the Quarto report** to see the published result

## 📊 Example Development Cycle

```r
# In eda-1.R - develop new analysis with graph family pattern

# ---- g2-data-prep -----------------------------------
# Prepare data for car performance comparison family
car_summary <- mtcars %>%
  group_by(am, vs) %>%
  summarise(
    avg_mpg = mean(mpg),
    avg_hp = mean(hp),
    count = n(),
    .groups = "drop"
  )

# ---- g21 --------------------------------------------
# First variant: boxplot comparison
g21_transmission_mpg <- car_summary %>%
  ggplot(aes(x = factor(am), y = avg_mpg, fill = factor(vs))) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = abcol[c("blue", "green")]) + # Alberta colors
  theme_minimal()

ggsave(paste0(prints_folder, "g21_transmission_mpg.png"), 
       g21_transmission_mpg, width = 8.5, height = 5.5, dpi = 300)
# Note: R script saves to disk only - NO print(g21_transmission_mpg) here

# ---- g22 --------------------------------------------  
# Second variant: scatter plot
g22_performance_scatter <- mtcars %>%
  ggplot(aes(x = wt, y = mpg, color = factor(am))) +
  geom_point() +
  scale_color_manual(values = abcol[c("magenta", "brown")]) + # Alberta colors
  theme_minimal()

ggsave(paste0(prints_folder, "g22_performance_scatter.png"), 
       g22_performance_scatter, width = 8.5, height = 5.5, dpi = 300)
# Note: R script saves to disk only - NO print(g22_performance_scatter) here
```

```qmd
<!-- In eda-1.qmd - publish when ready -->
### Car Performance Analysis

#### Fuel Efficiency by Transmission Type

```{r}
#| label: g21
#| code-summary: Average MPG by transmission and engine type
#| fig-cap: "Fuel efficiency comparison across transmission types"
print(g21_transmission_mpg)  # Print for HTML output
```

#### Weight vs Efficiency Relationship

```{r}
#| label: g22
#| code-summary: Scatter plot of weight vs MPG
#| fig-cap: "Relationship between car weight and fuel efficiency"
```
```

This enhanced workflow ensures **analytical rigor** in the R script while producing **polished, professional documentation** following Alberta's visual identity standards in the Quarto report. Graph families enable systematic exploration while maintaining consistency and organization.
