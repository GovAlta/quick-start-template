# Quick Start Template for AI-Augmented Reproducible Research

> [No one beginning a data science project should start from a blinking cursor.](https://towardsdatascience.com/better-collaborative-data-science-d2006b9c0d39) <br/>...Templatization is a best practice for things like using common directory structure across projects...<br/> -[Megan Risdal](https://towardsdatascience.com/@meganrisdal) Kaggle Product Lead.

This template provides a comprehensive foundation for **AI-augmented reproducible research projects**. It combines the best practices of reproducible research with cutting-edge AI support infrastructure, enabling researchers to leverage AI assistance while maintaining scientific rigor.

## 🚀 **What's New: AI Support System v1.0.0**

This template now includes a **complete AI Support System** with:

- **🎭 12 Specialized AI Personas** - Expert assistants for different research roles (Developer, Data Engineer, Research Scientist, etc.)
- **🧠 Intelligent Memory System** - Maintains project context and decision history
- **🔄 Dynamic Context Management** - Seamless switching between AI assistants based on your current needs
- **🧪 Comprehensive Testing** - Validation framework ensuring system reliability
- **📋 VSCode Integration** - One-click access to AI personas and project tools

## 🎯 **Perfect For**

- **Mixed-language research projects** (R, Python, SQL, etc.)
- **Reproducible data analysis** with AI augmentation
- **Collaborative research teams** needing consistent AI assistance
- **Academic and government research** where reproducibility is critical
- **Projects requiring multiple analytical perspectives** (technical, strategic, domain-specific)

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
   ```r
   # In R console
   install.packages(c("yaml", "config", "jsonlite"))
   ```

## Step 2: AI Support System Setup

4. **Initialize AI System**
   - **In VS Code**: `Ctrl+Shift+P` → "Tasks: Run Task" → "Show AI Context Status"
   - **In R Console**: 
   ```r
   source('ai/scripts/ai-migration-toolkit.R')
   show_context_status()
   ```

5. **Customize Your Project**
   - Edit `ai/mission.md` - Define your research goals
   - Edit `ai/method.md` - Describe your methodology  
   - Edit `ai/glossary.md` - Add domain-specific terms
   - Update `config.yml` - Set project-specific configurations

6. **Test the System**
   - **In VS Code**: Run "Test AI Support System" task
   - **In R Console**: 
   ```r
   source('ai/scripts/tests/run-all-tests.R')
   ```

## 🎭 Using AI Personas

The template includes 11 specialized AI personas, each optimized for different research tasks:

### **Core Personas**
- **🔧 Developer** - Technical infrastructure and reproducible code
- **📊 Project Manager** - Strategic oversight and coordination
- **🔬 Research Scientist** - Statistical analysis and methodology

### **Specialized Personas**  
- **⚡ Data Engineer** - Data pipelines and quality assurance
- **🚀 DevOps Engineer** - Deployment and operational excellence
- **🎨 Frontend Architect** - User interfaces and visualization
- **💡 Prompt Engineer** - AI optimization and prompt design
- **📝 Reporter** - Analysis communication and storytelling

### **Quick Persona Switching**

**In VS Code:**
- `Ctrl+Shift+P` → "Tasks: Run Task" → "Activate [Persona Name] Persona"

**In R Console:**
```r
source('ai/scripts/ai-migration-toolkit.R')

# Technical focus (minimal context)
activate_developer()

# Strategic oversight (full project context)  
activate_project_manager()

# Data-focused analysis
activate_data_engineer()

# Statistical methodology
activate_research_scientist()
```

## 🧠 Memory System

The template includes an intelligent memory system that maintains project continuity:

- **`ai/memory-human.md`** - Your decisions and reasoning
- **`ai/memory-ai.md`** - AI-maintained technical status  
- **`ai/memory-hub.md`** - Navigation center
- **`ai/memory-guide.md`** - Usage instructions

### **Memory Commands**
```r
# Check memory status
source('ai/scripts/ai-memory-functions.R')
memory_status()

# Quick memory check with intent detection
ai_memory_check()
```

## 📋 Project Structure

This template follows reproducible research best practices:
