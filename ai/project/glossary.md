# Glossary

Core terms for standardizing project communication.

---

## Data Pipeline Terminology

### Pattern
A reusable solution template for common data pipeline tasks. Patterns define the structure, philosophy, and constraints for a category of operations. Examples: Ferry Pattern, Ellis Pattern.

### Lane
A specific implementation instance of a pattern within a project. Lanes are numbered to indicate approximate execution order. Examples: `0-ferry-IS.R`, `1-ellis-customer.R`, `3-ferry-LMTA.R`.

### Ferry Pattern
Data transport pattern that moves data between storage locations with minimal/zero semantic transformation. Like a "cargo ship" - carries data intact. 
- **Allowed**: SQL filtering, SQL aggregation, column selection
- **Forbidden**: Column renaming, factor recoding, business logic
- **Input**: External databases, APIs, flat files
- **Output**: CACHE database (staging schema), parquet backup

### Ellis Pattern
Data transformation pattern that creates clean, analysis-ready datasets. Named after Ellis Island - the immigration processing center where arrivals are inspected, documented, and standardized before entry.
- **Required**: Name standardization, factor recoding, data type verification, missing data handling, derived variables
- **Includes**: Minimal EDA for validation (not extensive exploration)
- **Input**: CACHE staging (ferry output), flat files, parquet
- **Output**: CACHE database (project schema), WAREHOUSE archive, parquet files
- **Documentation**: Generates CACHE-manifest.md

---

## Storage Layers

### CACHE
Intermediate database storage - the last stop before analysis. Contains multiple schemas:
- **Staging schema** (`{project}_staging` or `_TEST`): Ferry deposits raw data here
- **Project schema** (`P{YYYYMMDD}`): Ellis writes analysis-ready data here
- Both Ferry and Ellis write to CACHE, but to different schemas with different purposes.

### WAREHOUSE
Long-term archival database storage. Only Ellis writes here after data pipelines are stabilized and verified. Used for reproducibility and historical preservation.

---

## Schema Naming Conventions

### `_TEST`
Reserved for pattern demonstrations and ad-hoc testing. Not for production project data.

### `P{YYYYMMDD}`
Project schema naming convention. Date represents project launch or data snapshot date.
Example: `P20250120` for a project launched January 20, 2025.

### `P{YYYYMMDD}_staging`
Optional staging schema within a project namespace for Ferry outputs before Ellis processing.

---

## General Terms

### Artifact
Any generated output (report, model, dataset) subject to version control.

### Seed
Fixed value used to initialize pseudo-random processes for reproducibility.

### Persona
A role-specific instruction set shaping AI assistant behavior.

### Memory Entry
A logged observation or decision stored in project memory files.

### CACHE-manifest
Documentation file (`./data-public/metadata/CACHE-manifest.md`) describing analysis-ready datasets produced by Ellis pattern. Includes data structure, transformations applied, factor taxonomies, and usage notes.

### INPUT-manifest
Documentation file (`./data-public/metadata/INPUT-manifest.md`) describing raw input data before Ferry/Ellis processing.

---
*Expand with domain-specific terminology as project evolves.*