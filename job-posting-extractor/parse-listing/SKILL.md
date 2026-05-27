---
name: parse-listing
model_tier: balanced
---

# Parse Listing

Given HTML from `fetch-page`, extract fields per `references/output-schema.md`.

## Process

### 0. Classify page

| Type | Markers | Action |
|---|---|---|
| **Search results** | Multiple cards, result count, no single description | Extract each card → mark all `_needs_detail_fetch: true` |
| **Detail page** | Single title + description + apply button, possible JSON-LD | Extract full listing |

### 1. Search results

Extract per card: title, company, location, source_url, posted_date. Return `{listings: [...], _page_meta: {type: "search_results", estimated_total, page, next_page_url, results_on_page}}`. Each listing has `_needs_detail_fetch: true`.

Use selectors from `references/site-patterns.md`.

### 2. Detail page

1. **JSON-LD.** `script[type="application/ld+json"]` with `JobPosting` schema → parse directly (most reliable).
2. **Selectors.** Apply `references/site-patterns.md` per `source_site`.

   For LinkedIn: description → `div.description__text.description__text--rich > section.show-more-less-html > div.show-more-less-html__markup`. Strip HTML (convert `<br>` → newline, `<li>` → bullet). Criteria → `ul.description__job-criteria-list` items by position (seniority, employment type, job function, industries).

3. **Fallback.** Open Graph meta, common class names for unknown sites.
4. **Null + note.** Every field either populated or `null` with reason in `_extraction_notes`.

## Output

Shape per `references/output-schema.md` with `_extraction_notes`.
