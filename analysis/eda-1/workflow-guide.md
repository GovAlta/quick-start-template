# eda-1 Workflow Guide: .R + .qmd Development Pattern

This is an example file. Change the content to match your project.

## Overview

This directory implements a **dual-file workflow** for exploratory data analysis following the FIDES framework:

- **`eda-1.R`**: Analytical development layer (experimentation & refinement)
- **`eda-1.qmd`**: Publication layer (polished reporting & documentation)

## 🔄 Development Workflow

### 1. **Develop in R Script First**
Work interactively in `eda-1.R`:
```r
# Add new analysis chunks with clear labels
# ---- g2 ----------------------------------------
# Language trends analysis
ds_language %>%
  filter(measure == "title_count") %>%
  filter(language %in% c("Українська", "Російська")) %>%
  ggplot(aes(x = year, y = value, color = language)) +
  geom_line() +
  # ... develop your visualization
```

### 2. **Test and Refine Interactively**
- Run chunks line-by-line in VS Code R extension
- Iterate on data transformations and visualizations
- Save plots to `prints/` folder for review
- Use `httpgd` for interactive plotting in VS Code

### 3. **Publish to Quarto When Ready**
When you're satisfied with a chunk in the R script:

```qmd
### Language Publishing Trends

```{r}
#| label: g2
#| code-summary: Ukrainian vs Russian language trends
#| code-fold: false
#| eval: true
#| cache: true
#| fig-cap: "Publishing trends by language over time"
```
```

## 📁 Directory Structure

```
analysis/eda-1/
├── eda-1.R           # Development & experimentation layer
├── eda-1.qmd         # Publication & reporting layer  
├── workflow-guide.md # This guide
├── data-local/       # Local outputs and intermediate files
└── prints/           # Saved plots and figures
```

## 🎯 Chunk Naming Convention

Use consistent, meaningful chunk labels that work across both files:

- **`g1`, `g2`, `g3`...**: Graphs/visualizations
- **`t1`, `t2`, `t3`...**: Tables/summaries  
- **`m1`, `m2`, `m3`...**: Models/statistical analysis
- **`tweak-data-N`**: Data transformations
- **`inspect-data-N`**: Data exploration

## 🔗 Data Integration

The workflow connects to the **Books of Ukraine analytical database**:

```r
# Loads analysis-ready tables in long format
db <- connect_books_db("main")
# Available tables: ds_year, ds_language, ds_geography, ds_genre, etc.
```

### Key Data Objects
- **`ds_year`**: Annual publication trends
- **`ds_language`**: Language-specific patterns (Ukrainian vs Russian)
- **`ds_geography`**: Regional/territorial analysis  
- **`ds_genre`**: Subject matter/genre trends

## 💡 Best Practices

### R Script Development
1. **Use chunk labels** that match between .R and .qmd files
2. **Save intermediate results** to `data-local/` if computationally expensive
3. **Export key plots** to `prints/` folder for documentation
4. **Comment generously** - explain your analytical thinking
5. **Test iteratively** - run chunks interactively before committing

### Quarto Publication
1. **Add context** - explain what each visualization shows
2. **Use meaningful captions** with `fig-cap` 
3. **Control code visibility** with `code-fold` appropriately
4. **Cache expensive operations** with `cache: true`
5. **Write for your audience** - assume non-technical readers

## 🚀 Getting Started

1. **Open both files** in VS Code side-by-side
2. **Start in eda-1.R** - run the data loading chunks
3. **Develop your first graph** in the `g1` section
4. **Test interactively** until you're satisfied
5. **Add corresponding chunk** to eda-1.qmd
6. **Render the Quarto report** to see the published result

## 📊 Example Development Cycle

```r
# In eda-1.R - develop new analysis
# ---- g2 ----------------------------------------
# Regional publishing inequality
top_regions <- ds_geography %>%
  filter(measure == "title_count") %>%
  group_by(geography) %>%
  summarise(total = sum(value)) %>%
  top_n(10, total)

g2 <- ds_geography %>%
  filter(geography %in% top_regions$geography) %>%
  # ... continue development
```

```qmd
<!-- In eda-1.qmd - publish when ready -->
### Regional Publishing Centers

```{r}
#| label: g2
#| code-summary: Top publishing regions in Ukraine
#| fig-cap: "Leading oblasts and cities by publication volume"
```
```

This workflow ensures **analytical rigor** in the R script while producing **polished documentation** in the Quarto report.
