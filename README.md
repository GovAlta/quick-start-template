# Quick Start Template

> [No one beginning a data science project should start from a blinking cursor.](https://towardsdatascience.com/better-collaborative-data-science-d2006b9c0d39) <br/>...Templatization is a best practice for things like using common directory structure across projects...<br/> -[Megan Risdal](https://towardsdatascience.com/@meganrisdal) Kaggle Product Lead.

This project contains the files and settings commonly used in analysis projects with R. A developer can start an analysis repository more quickly by copying these files. The purpose of each directory is described in its README file. Some aspects are more thoroughly described in [Collaborative Data Science Practices](https://ouhscbbmc.github.io/data-science-practices-1/).

> GOA Edition <br/> While aiming to replicate [RAnalysisSkeleton](https://github.com/wibeasley/RAnalysisSkeleton), the current repository flavours the template with analytic conventions specific to the Government of Alberta (GOA).

# Establishing a Workstation for Analysis

1.  Install and configure the needed software, as described in the [Workstation](https://ouhscbbmc.github.io/data-science-practices-1/workstation.html) chapter of [*Collaborative Data Science Practices*](https://ouhscbbmc.github.io/data-science-practices-1/). Select the programs to meet your needs, and if in doubt, cover the Required Installation section and then pick other tools as necessary.

2.  Download the repo to your local machine. One option is to [clone](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/cloning-a-repository) it.

3.  On your local machine, open the project in [RStudio](https://rstudio.com/products/rstudio/) by double-clicking [quick-start-template.Rproj](quick-start-template.Rproj) in the root of the downloaded repo.

4.  Install the packages needed for this repo. Within the RStudio console, execute these two lines. The first line installs a package. The second line inspects the repo's [DESCRIPTION](DESCRIPTION) file to identify and install the prerequisites.

    ``` r
    remotes::install_github(repo="OuhscBbmc/OuhscMunge")
    OuhscMunge::update_packages_addin()
    ```
