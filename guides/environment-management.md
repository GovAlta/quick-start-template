# Environment Management Guide

This guide explains the different approaches for managing R package dependencies in this project, helping you choose the right method for your needs.

## 🎯 **Quick Decision Guide**

| Your Situation | Recommended Approach | Command |
|----------------|---------------------|---------|
| **Learning/prototyping** | Enhanced CSV | `Rscript utility/enhanced-install-packages.R` |
| **Template customization** | Enhanced CSV | Modify `utility/package-dependency-list.csv` |
| **Publishing research** | renv | `Rscript utility/init-renv.R` |
| **Team collaboration** | renv | `renv::restore()` after git clone |
| **Cross-language work** | Conda | `conda env create -f environment.yml` |
| **Deployment/production** | Docker | See deployment guides |

## 📊 **Detailed Comparison**

### Enhanced CSV System (Default) ⭐

**Best for:** Templates, learning, rapid development, flexibility

**Pros:**
- ✅ Lightweight and transparent
- ✅ Easy to customize packages per project
- ✅ Version constraints available (min/max/exact)
- ✅ Beginner-friendly
- ✅ Template-compatible
- ✅ Fast setup

**Cons:**
- ❌ Not fully deterministic (sub-dependencies can vary)
- ❌ No automatic dependency discovery
- ❌ Manual package list maintenance

**Usage:**
```r
# Install with latest versions
Rscript utility/enhanced-install-packages.R

# Or use original script (backward compatible)
Rscript utility/install-packages.R
```

**CSV Format:**
```csv
package_name,install,on_cran,github_username,min_version,max_version,exact_version,description
dplyr,TRUE,TRUE,,1.0.0,,,Essential data manipulation
ggplot2,TRUE,TRUE,,,3.4.0,Specific version for compatibility
tidyr,TRUE,TRUE,,1.2.0,1.3.0,,Within version range
OuhscMunge,TRUE,FALSE,OuhscBbmc,,,Custom package utilities
```

### renv (Optional) 🔒

**Best for:** Published research, strict collaboration, archival

**Pros:**
- ✅ **Exact reproducibility** - locks all package versions and dependencies
- ✅ **Project isolation** - each project has its own package library
- ✅ **Industry standard** - widely adopted in R community
- ✅ **Automatic** - discovers dependencies from your code
- ✅ **Cross-platform** - works on Windows, Mac, Linux

**Cons:**
- ❌ **Heavier setup** - larger files, more complexity
- ❌ **Less flexible** - harder to update individual packages
- ❌ **Template friction** - renv.lock files can be intimidating
- ❌ **Startup time** - project initialization takes longer

**Usage:**
```r
# Initialize renv (one-time setup)
Rscript utility/init-renv.R

# Daily workflow
renv::status()    # Check environment
renv::restore()   # Restore packages from renv.lock
renv::snapshot()  # Update renv.lock with new packages
```

### Conda/Mamba 🐍

**Best for:** Cross-language projects (R + Python), system dependencies

**Pros:**
- ✅ **Cross-language** - manages R, Python, system libraries
- ✅ **System dependencies** - handles complex binary dependencies
- ✅ **Fast solver** - mamba provides rapid dependency resolution
- ✅ **Reproducible** - locks all package versions
- ✅ **Isolated environments** - complete separation

**Cons:**
- ❌ **Additional tooling** - requires conda/mamba installation
- ❌ **Learning curve** - different command set
- ❌ **R ecosystem** - not as R-native as renv
- ❌ **File size** - environment files can be large

**Usage:**
```bash
# Create environment
conda env create -f environment.yml

# Activate environment
conda activate quick-start-template

# Update environment
conda env update -f environment.yml
```

## 🚀 **Migration Paths**

### From CSV to renv

```r
# 1. Current CSV system working? Great!
Rscript utility/enhanced-install-packages.R

# 2. Initialize renv (uses your current packages)
Rscript utility/init-renv.R

# 3. Commit renv.lock to git
git add renv.lock .Rprofile renv/
git commit -m "Add renv for reproducibility"
```

### From renv back to CSV

```r
# 1. Deactivate renv
renv::deactivate()

# 2. Remove renv files (optional)
unlink("renv", recursive = TRUE)
file.remove(".Rprofile", "renv.lock")

# 3. Use CSV system
Rscript utility/enhanced-install-packages.R
```

### Adding Conda Support

```bash
# 1. Install miniconda/mamba
# 2. Create environment from our template
conda env create -f environment.yml

# 3. Activate and work
conda activate quick-start-template
```

## 🔧 **Troubleshooting**

### Package Installation Issues

```r
# Check what's failing
Rscript scripts/check-setup.R

# Force reinstall problematic package
install.packages("problematic_package", force = TRUE)

# Check package versions
sapply(c("dplyr", "ggplot2"), packageVersion)
```

### renv Issues

```r
# Reset renv cache
renv::purge()

# Rebuild from scratch
renv::restore(clean = TRUE)

# Check renv status
renv::diagnostics()
```

### Version Conflicts

```r
# See what's installed
installed.packages()[, c("Package", "Version")]

# Check specific constraints
source("utility/enhanced-install-packages.R")
# Will report version conflicts
```

## 📋 **Best Practices**

### For Template Developers

- ✅ Use **CSV system** for maximum flexibility
- ✅ Provide **renv option** for users who need it
- ✅ Test on **multiple platforms**
- ✅ Document **version requirements** clearly

### For Research Projects

- ✅ Start with **CSV system** for development
- ✅ Switch to **renv** before publication
- ✅ **Version control** your environment files
- ✅ Test **restoration** on clean machines

### For Teams

- ✅ **Decide together** on approach (CSV vs renv)
- ✅ **Document** your choice in README
- ✅ **Test** new member onboarding regularly
- ✅ **Update** dependencies together

## 🆘 **Getting Help**

1. **Check setup:** `Rscript scripts/check-setup.R`
2. **Review this guide:** Key decision points above
3. **Ask team members:** Document your team's preferred approach
4. **GitHub issues:** For template-specific problems

## 📚 **Additional Resources**

- [renv documentation](https://rstudio.github.io/renv/)
- [Conda documentation](https://docs.conda.io/)
- [R Package Management Best Practices](https://r-pkgs.org/)
- [Reproducible Research with R](https://bookdown.org/)