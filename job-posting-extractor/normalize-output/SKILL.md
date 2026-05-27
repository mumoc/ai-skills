---
name: normalize-output
model_tier: balanced
---

# Normalize Output

Clean and validate extracted fields against `references/output-schema.md`.

## Process

1. **Text.** Trim whitespace, collapse excessive newlines, decode HTML entities.
2. **Dates.** Convert to ISO 8601 (YYYY-MM-DD). Resolve relative ("3 days ago" → offset from `fetched_at`).
3. **Salary.** Parse "$150K-$200K" or "€80k" → numeric min/max + currency (ISO 4217).
4. **Seniority.** Map to enum: `entry`/`junior`/`mid`/`senior`/`lead`/`executive`.
5. **Skills.** If empty but description has tech terms, extract by keyword match.
6. **Validate.** Required fields must be non-null. Block if any required field is null without a documented extraction note.

## Output

Same shape as `parse-listing` output with added `_validation` block:

```json
{"_validation": {"passed": true, "missing_required": [], "warnings": []}}
```
