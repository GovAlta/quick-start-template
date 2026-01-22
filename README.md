# Quick Start Template for AI-Augmented Reproducible Research

> [No one beginning a data science project should start from a blinking cursor.](https://towardsdatascience.com/better-collaborative-data-science-d2006b9c0d39) <br/>...Templatization is a best practice for things like using common directory structure across projects...<br/> -[Megan Risdal](https://towardsdatascience.com/@meganrisdal) Kaggle Product Lead.

This template provides a comprehensive foundation for **AI-augmented reproducible research projects**. It combines the best practices of reproducible research with  AI support infrastructure, which levereges generative LLMs and agent customization to construct and manage analytic pipelines. 

Refer to [RAnalysisSkeleton](https://github.com/wibeasley/RAnalysisSkeleton) for a deeper dive into reproducible research best practices.

## 🎭 AI Persona System

This project template includes 9 specialized AI personas, each optimized for different research tasks:

### **Core Personas**
- **🔧 Developer** - Technical infrastructure and reproducible code
- **📊 Project Manager** - Strategic oversight and coordination
- **🔬 Research Scientist** - Statistical analysis and methodology

### **Specialized Personas**  
- **💡 Prompt Engineer** - AI optimization and prompt design
- **⚡ Data Engineer** - Data pipelines and quality assurance
- **📈 Grapher** - Data visualization and display of informatioin
- **📝 Reporter** - Analysis communication and storytelling
- **🚀 DevOps Engineer** - Deployment and operational excellence
- **🎨 Frontend Architect** - User interfaces and visualization

You can switch between personas in VSCode:
- `Ctrl+Shift+P` → "Tasks: Run Task" → "Activate [Persona Name] Persona"  
- Instruct the chat agent to switch to the specific persona you name  

You can define persona's default context in `get_persona_configs()` function of `ai/scripts/dynamic-context-builder.R`:

```r
"project-manager" = list(
  file = "./ai/personas/project-manager.md",
  default_context = c("project/mission", "project/method", "project/glossary")
)
```

You can define what context files get a shortcut alias, so they can be integrated into the chat calls easily. See `get_file_map()` function in `ai/scripts/dynamic-context-builder.R`.



## 🧠 Memory System

The template includes an intelligent memory system that maintains project continuity:

- **`ai/memory/memory-human.md`** - Your decisions and reasoning, only humans can edit
- **`ai/memory/memory-ai.md`** - AI-maintained technical status, only AI can edit
- **`ai/memory/log/YYYY-MM-DD.md** - dedicated folder in which one file = one log entry. Helps to isolate large changes to a single file for easier tracking.

# 🚀 Quick Start Guide

## Step 1: Standard Setup

1. **Install Prerequisites**
   - [R (4.0+)](https://cran.r-project.org/)
   - [RStudio](https://rstudio.com/products/rstudio/) or [VS Code](https://code.visualstudio.com/)
   - [Git](https://git-scm.com/)
   - [Quarto](https://quarto.org/) (for reports)

2. **Clone and Open Project**
   ```bash
   git clone [your-repo-url]
   cd quick-start-template
   ```
   - Open `quick-start-template.Rproj` in RStudio, or
   - Open folder in VS Code

3. **Install R Dependencies** 
   
   **Choose your preferred approach** (see `docs/environment-management.md` for detailed comparison):

   **Option A: Enhanced CSV System (Default - Flexible)**
   ```r
   # Enhanced system with version constraints
   Rscript utility/enhanced-install-packages.R
   
   # Or original system (backward compatible)
   Rscript utility/install-packages.R
   ```
   
   **Option B: renv (Strict Reproducibility)**
   ```r
   # For exact reproducibility (research publication)
   Rscript utility/init-renv.R
   ```
   
   **Option C: Conda (Cross-Language Projects)**
   ```bash
   # For R + Python workflows
   conda env create -f environment.yml
   conda activate quick-start-template
   ```

## Step 2: AI Support System Setup

4. **Initialize AI System**
   - **In VS Code**: `Ctrl+Shift+P` → "Tasks: Run Task" → "Show AI Context Status"

5. **Assign the active persona**
   - In VS Code: `Ctrl+Shift+P` → "Tasks: Run Task" → "Activate [default] Persona"

5. **Customize Your Project**

Each personal could be customized by adding specific documents to the dynamic part of the copilot-instructions.md (Section 3). Some personas may have some documents loaded by default (e.g. Project Manager and Grapher load mission, method, and glossary). 

   - Edit `ai/mission.md` - What you wan to do: goals and deliverables
   - Edit `ai/method.md` - How you want to do it: tecniques and processes 
   - Edit `ai/glossary.md` - Encyclopedia of domain-specific terms
   - Update `config.yml` - To set project-specific configurations
