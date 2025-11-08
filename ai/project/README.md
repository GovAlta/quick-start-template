# Project Context Directory (Template)

Generic project-level context directory for R/Python mixed analysis repositories.

## Directory Structure

```
./ai/project/
├── README.md        # Overview (this file)
├── mission.md       # Project mission/objectives/goals
├── method.md        # Methodology, analytical approach, reproducibility standards
└── glossary.md      # Shared terminology and domain definitions
```

## Purpose

Centralize foundational context so persona activation (e.g. `activate_project_manager()`) can automatically load strategic material (mission, method, glossary) while technical personas stay minimal.

## Usage Patterns

```r
activate_project_manager()  # Loads mission/method/glossary automatically
activate_developer()        # Minimal context for focused implementation
add_context_file('ai/project/mission.md')     # Manually add just mission
add_context_file('ai/project/glossary.md')    # Add terminology support
show_context_status()                         # Inspect what is loaded
```

## Maintenance Triggers

- Scope or objectives change → update `mission.md`
- Methodological refinement → update `method.md`
- New domain terms introduced → extend `glossary.md`
- Cross-team onboarding improvements → adjust this `README.md`

## Relationship to Other Directories

- `philosophy/` holds general, reusable methodological essays (project-agnostic)
- `analysis/` holds implementation-specific workflows (scripts, notebooks, Quarto)
- `ai/personas/` defines role-specific behavioral prompts that optionally pull from this directory

## Next Steps (Template Consumers)

1. Fill out `mission.md` with concise objectives and success metrics.
2. Document analytical standards and reproducibility steps in `method.md`.
3. Seed `glossary.md` with at least 10 core domain terms.
4. Activate `activate_project_manager()` and confirm automatic context loading.

---
*Template initialized: $(date)*