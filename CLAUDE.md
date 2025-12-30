# Claude Code Instructions for nyschooldata

## Commit Message Guidelines
- Do NOT include "Generated with Claude Code" in commit messages
- Do NOT include "Co-Authored-By: Claude" in commit messages
- Do NOT mention Claude or AI assistance in PR descriptions

## Package Overview
This package fetches and processes school data from the New York State Education Department (NYSED).

## Key Data Concepts
- BEDS codes: 12-digit Basic Educational Data System identifiers
- ~1,087 school districts in New York
- NYC is a special case: single district (NYC DOE) with ~1,800 schools

## Data Sources
- Primary: https://data.nysed.gov/
- NYC-specific data may come from InfoHub
