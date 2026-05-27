---
name: write-results
model_tier: fast
---

# Write Results

Accumulate validated postings from `normalize-output` into `output/jobs.json`. Orchestrates the search→detail loop.

## Process

### 0. Check input shape
- `listings[]` with `_needs_detail_fetch: true` → search results, enter iteration loop.
- Single object → detail page, append directly.

### 1. Iteration loop (search → detail)

For each listing in `listings`:
1. **Cache check** — skip if `source_url` already fetched this session.
2. **Fetch** → `fetch-page` with rate limiting.
3. **Parse** → `parse-listing`.
4. **Normalize** → `normalize-output`.
5. **Accumulate** → append to in-memory array.
6. **Report** → `+ Title — Company (site, page N card M)`.

After all cards on current page:
7. **Pagination** — if `_page_meta.next_page_url`, fetch → parse → accumulate next page. Repeat until done.

### 2. Write to disk

1. Target: `output/jobs.json`.
2. If exists, load existing `postings` array. Otherwise start empty.
3. Append new postings. Deduplicate by `source_url`.
4. Set meta: `extracted_at`, `schema_version`, `query`, `sites` (deduplicated from postings), `total_postings`.
5. Pretty-print (2-space indent).

### 3. Final report

```
✓ output/jobs.json — 42 postings (linkedin: 38, greenhouse: 4)
```
