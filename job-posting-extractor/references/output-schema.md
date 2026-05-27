# Output Schema — Job Posting

Every extracted job posting is a JSON object conforming to this schema.
Fields with `?` are optional (extract if present, omit if absent).

```json
{
  "title": "Senior Software Engineer",
  "company": "Acme Corp",
  "company_url": "https://acme.com",
  "location": "San Francisco, CA",
  "description": "We are looking for...",
  "salary_min": 150000,
  "salary_max": 200000,
  "currency": "USD",
  "seniority": "senior",
  "skills": ["Go", "Kubernetes", "PostgreSQL"],
  "posted_date": "2026-05-20",
  "application_deadline": "2026-06-20",
  "source_url": "https://boards.greenhouse.io/acme/jobs/123",
  "source_site": "greenhouse"
}
```

## Field definitions

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | string | yes | Job title as listed |
| `company` | string | yes | Employer name |
| `company_url` | string | no | Employer website URL |
| `location` | string | yes | Physical location or "Remote" |
| `description` | string | yes | Full job description text |
| `salary_min` | number | no | Minimum salary (annual, unless specified) |
| `salary_max` | number | no | Maximum salary |
| `currency` | string | no | ISO 4217 currency code (USD, EUR, GBP, etc.) |
| `seniority` | string | no | One of: `entry`, `junior`, `mid`, `senior`, `lead`, `executive` |
| `skills` | array[string] | no | Listed skills/technologies |
| `posted_date` | string | yes | ISO 8601 date (YYYY-MM-DD) |
| `application_deadline` | string | no | ISO 8601 date or null |
| `source_url` | string | yes | Direct URL to the posting |
| `source_site` | string | yes | Identifier: `linkedin`, `indeed`, `greenhouse`, `lever`, `workday`, `company_careers` |

## Output container

All postings are written to a single JSON file: `output/jobs.json`.

**If the file exists**, read it, append new postings, and overwrite. This enables incremental accumulation across multiple search sessions and sources (LinkedIn, Greenhouse, etc.).

```json
{
  "_meta": {
    "extracted_at": "2026-05-26T10:30:00Z",
    "schema_version": "1.0",
    "query": "ruby on rails developer",
    "sites": ["linkedin", "greenhouse"],
    "total_postings": 42
  },
  "postings": [
    { "title": "...", "company": "...", ... },
    { "title": "...", "company": "...", ... }
  ]
}
```

| Meta field | Type | Description |
|---|---|---|
| `extracted_at` | string | ISO 8601 timestamp of the latest extraction run |
| `schema_version` | string | Schema version for compatibility checks |
| `query` | string | The search query used (e.g. "ruby on rails developer") |
| `sites` | array[string] | Job sites searched (`linkedin`, `greenhouse`, `indeed`, etc.) |
| `total_postings` | number | Total count of postings in the array |
