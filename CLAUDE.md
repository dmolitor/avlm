# CLAUDE.md

## Essential Project Background

`avlm` is an R package implementing anytime-valid statistical methods for linear regression models.

- `resources/anytime-valid-inference-in-linear-models.tex` is the full Latex source code
for the paper upon which all the code in the package is based. Any methodological or implementation
questions should always be guided back to this paper.

## Dependency Manager

This project uses `renv`. Use `renv` for all dependency and environment management:

```r
renv::install()                        # Install dependencies
renv::install(pkg); renv::snapshot()   # Add a dependency to the lockfile
```

## Code Architecture and Instructions

The package code lives in `R`.

IMPORTANT: All code we add should have corresponding unit tests developed by the `testthat` package.
These unit tests should meet one of two standards: (1) if the code does a non-deterministic process
(i.e. we can't just confirm that it's output matches a given quantity) the unit tests should
confirm that it's behavior matches expected behavior; (2) if the code is deterministic, the unit
tests should confirm that it matches expected behavior AND that the output is as expected.

After adding new code, you MUST ALWAYS run all unit tests and fix any resulting errors before
proceeding.

## Git instructions

Never use git unless explicitly instructed/asked by me. When instructed,
all changes should be made to the `dev` branch unless I explicity tell you
another branch.