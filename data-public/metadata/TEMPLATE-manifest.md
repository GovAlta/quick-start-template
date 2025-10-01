# Data Manifest Template for AI Copilot

This template provides a standardized structure for creating INPUT and CACHE manifests for new data sources. It serves as a guide for AI Copilot when documenting data structures and relationships.

## Template Instructions

**When creating a new manifest:**
1. Replace placeholder text in `[BRACKETS]` with actual values
2. Remove sections that don't apply to your data source
3. Add domain-specific sections as needed
4. Ensure all tables have complete metadata guides
5. Include comprehensive linking information between tables

---

# [DATA SOURCE NAME] Manifest

[Brief description of the data source, its purpose, and scope. Explain how this data source fits into the broader research ecosystem and what specific research questions it addresses.]

While other data sources may be used in the project ([list other relevant sources]) as the need requires, the [DATA SOURCE NAME] was designed to [explain the specific purpose and value proposition].

# [DATA SOURCE NAME] Overview

[Provide a comprehensive description of the data source, including:]
- Main purpose and research applications
- Coverage period and scope
- Key entities and relationships
- Integration with other data sources

## Summary Table

| **Server**           | **Database**                       | **Table Name**            | **Purpose**                                                                | **Primary Key**        |
|----------------------|------------------------------------|----------------------------|----------------------------------------------------------------------------|------------------------|
| `[SERVER-NAME]`      | `[DATABASE-NAME]`                  | `[TABLE-NAME-1]`           | [Brief description of table purpose]                                      | `[PRIMARY-KEY-COLS]`   |
| `[SERVER-NAME]`      | `[DATABASE-NAME]`                  | `[TABLE-NAME-2]`           | [Brief description of table purpose]                                      | `[PRIMARY-KEY-COLS]`   |
| `[SERVER-NAME]`      | `[DATABASE-NAME]`                  | `[TABLE-NAME-3]`           | [Brief description of table purpose]                                      | `[PRIMARY-KEY-COLS]`   |

# [DOMAIN/CATEGORY NAME]

[If your data source has multiple domains/categories, create a section for each. Examples: Taxonomy, Financial Support, Assessment, Training, Client Demographics, etc.]

[Provide context about this domain, including:]
- How data is structured (e.g., one row per event, per month, per episode)
- Key business concepts and definitions
- Relationships between tables in this domain

## [TABLE-NAME] Table Metadata Guide for AI SQL Query Generation

### Table Overview
- **Database**: `[FULL-DATABASE-PATH]`
- **Table Name**: `[TABLE-NAME]`
- **Purpose**: [Detailed description of what this table contains and its role in research]
- **Coverage**: [Scope of data - time periods, populations, completeness]
- **Relationship**: [How this table relates to other tables - parent/child, lookup, etc.]

### Column Reference

#### [COLUMN GROUP 1 - e.g., Identifiers]
- **[COLUMN-NAME-1]**: [Description, data type, special notes]
- **[COLUMN-NAME-2]**: [Description, data type, special notes]
- **[COLUMN-NAME-3]**: [Description, data type, special notes]

#### [COLUMN GROUP 2 - e.g., Temporal Fields]
- **[COLUMN-NAME-4]**: [Description, data type, special notes]
- **[COLUMN-NAME-5]**: [Description, data type, special notes]

#### [COLUMN GROUP 3 - e.g., Classification Fields]
- **[COLUMN-NAME-6]**: [Description, data type, special notes]
- **[COLUMN-NAME-7]**: [Description, data type, special notes]

#### [COLUMN GROUP 4 - e.g., Demographics]
- **[COLUMN-NAME-8]**: [Description, data type, special notes]
- **[COLUMN-NAME-9]**: [Description, data type, special notes]

#### [COLUMN GROUP 5 - e.g., Geographic/Service Delivery]
- **[COLUMN-NAME-10]**: [Description, data type, special notes]
- **[COLUMN-NAME-11]**: [Description, data type, special notes]

#### [COLUMN GROUP 6 - e.g., Outcome/Status Fields]
- **[COLUMN-NAME-12]**: [Description, data type, special notes]
- **[COLUMN-NAME-13]**: [Description, data type, special notes]

### Key Business Rules for Queries
- **[RULE-1]**: [Description of important business rule]
- **[RULE-2]**: [Description of important business rule]
- **[RULE-3]**: [Description of important business rule]
- **[RULE-4]**: [Description of important business rule]
- **[RULE-5]**: [Description of important business rule]

### [CLASSIFICATION/HIERARCHY SECTION - if applicable]
[If the table contains classification systems or hierarchies, document them here]

#### [Category 1]
- **[Sub-category 1a]**: [Description]
- **[Sub-category 1b]**: [Description]

#### [Category 2]
- **[Sub-category 2a]**: [Description]
- **[Sub-category 2b]**: [Description]

### Linking Notes
- Use `[KEY-FIELD-1]` to link with [OTHER-TABLE-1], [OTHER-TABLE-2]
- Use `[KEY-FIELD-2]` to link with [OTHER-TABLE-3] for [specific purpose]
- Use `[KEY-FIELD-3]` to link with [OTHER-TABLE-4] when [specific condition]

### Usage Notes for AI Queries
- [Guidance on filtering strategies]
- [Notes on data quality or completeness issues]
- [Recommendations for common analysis patterns]
- [Warnings about potential pitfalls or misinterpretations]
- [Temporal considerations for longitudinal analysis]
- [Privacy or security considerations]

---

## [ADDITIONAL-TABLE] Table Metadata Guide for AI SQL Query Generation

[Repeat the table structure above for each additional table in your data source]

---

# Cross-Table Relationships and Integration

## Primary Linking Keys
- **[KEY-1]**: Links [TABLE-A] with [TABLE-B], [TABLE-C] for [purpose]
- **[KEY-2]**: Links [TABLE-D] with [TABLE-E] for [purpose]
- **[KEY-3]**: Cross-domain linking between [DOMAIN-1] and [DOMAIN-2]

## Data Quality Considerations
- **Completeness**: [Notes on data completeness across tables]
- **Consistency**: [Notes on consistency checks between related tables]
- **Temporal alignment**: [Notes on time-based relationships]

## Common Analysis Patterns
- **[PATTERN-1]**: [Description of common analytical approach]
- **[PATTERN-2]**: [Description of common analytical approach]
- **[PATTERN-3]**: [Description of common analytical approach]

# Research Applications

## Primary Use Cases
- **[USE-CASE-1]**: [Description of research application]
- **[USE-CASE-2]**: [Description of research application]
- **[USE-CASE-3]**: [Description of research application]

## Analytical Considerations
- **Sample sizes**: [Guidance on expected sample sizes for different analyses]
- **Time windows**: [Recommended time windows for different types of analysis]
- **Cohort definitions**: [Standard approaches for defining analytical cohorts]

## Integration with Other Data Sources
- **[OTHER-SOURCE-1]**: [How this data source integrates with other sources]
- **[OTHER-SOURCE-2]**: [Cross-validation opportunities]
- **[OTHER-SOURCE-3]**: [Complementary data for enriched analysis]

---

## AI Copilot Notes

**When using this manifest:**
1. Always verify table and column names against the actual database schema
2. Check data availability for the requested time period
3. Consider data privacy and access restrictions
4. Validate linking keys before performing joins
5. Test queries with small samples before running full analyses
6. Document any assumptions or limitations in your analysis

**Common query patterns to consider:**
- Temporal filtering for specific analysis periods
- Demographic stratification for equity analysis
- Geographic aggregation for regional insights
- Outcome tracking for longitudinal studies
- Cross-domain analysis for comprehensive client journeys
