# Quick Guide to Causal Inference in Social Sciences

## Introduction
Causal inference in social sciences differs significantly from "harder" sciences due to the complexity and variability of human behavior and social contexts. This guide synthesizes key concepts from three versions of the cheat sheet to provide a detailed yet accessible overview for novices.

---

## Key Concepts

### Unit Variation
Unlike molecules in physical sciences, people are not identical. A rule developed for one group may not hold for another due to differences in characteristics and contexts. This is known as **generalizability**.

### Control of Conditions (Known Confounders)
In physical sciences, laboratory conditions (e.g., temperature, humidity) can be controlled. In social sciences, controlling social contexts (e.g., recession, migration, policy) is much harder. Rules developed under specific conditions may not apply when these conditions change.

### Causality
Causality is a special type of relationship between two variables (e.g., jogging and salary). Demonstrating causality requires ruling out all other possible explanations for an observed fact. For example, if joggers have higher salaries than non-joggers, we cannot immediately claim jogging causes higher salaries because other factors (e.g., age, education, marital status) might influence salary.

---

## Methods for Establishing Causality

### Random Assignment
Randomization is the gold standard for controlling unknown confounders. By randomly assigning individuals to treatment and control groups, we ensure that confounders are balanced on average. However, randomization is often impossible or unethical in social sciences (e.g., instructing people to smoke).

### Quasi-Experiments
When randomization is not feasible, quasi-experiments are used. These involve approximating matched groups by finding cases in existing data that are similar on all relevant known confounders. This process is called **group balance**.

### Propensity Score Matching (PSM)
PSM is a statistical technique that condenses all known confounders into a single number (propensity score). Cases are then sorted into treatment and control groups based on this score. When groups are balanced, differences in outcomes can be attributed to the treatment variable.

---

## Logical Tools for Causal Inference

### Mill's Canons
Mill's Canons provide a conceptual foundation for causal inference:

#### Method of Differences
- A B C D occur together with w x y z
- B C D occur together with x y z
- Therefore, A is the cause of w

#### Method of Agreement
- A B C D --> w x y z
- A E F G --> w t u v
- Therefore, A is the cause of w

#### Method of Concomitant Variation
- A B C occur together with x y z
- A' B C results in x' y z
- Therefore, A and x are causally connected

---

## Addressing Threats to Validity
To confidently claim causality, researchers must address threats to validity by ruling out alternative explanations. This involves:
- Ensuring group balance
- Assessing the quality of matching in PSM
- Considering the flow of time (e.g., avoiding "after that, therefore because of it" fallacy)

---

## Practical Applications

### Example: Jogging and Salary
1. **Random Assignment**: Recruit a random group and assign half to jog and half not to jog.
2. **Quasi-Experiment**: Match joggers and non-joggers on age, education, and marital status.
3. **PSM**: Use propensity scores to balance groups and measure salary differences.

### Example: Gender and Salary
Random assignment is impossible for gender. Instead, researchers use PSM to create balanced groups and attribute salary differences to gender.

---

## Conclusion
Causal inference in social sciences is challenging but achievable through careful design and analysis. By understanding key concepts, methods, and logical tools, researchers can make robust claims about causality.

