# Site Patterns — Known Selectors & URLs

Add entries here as you discover patterns for new sites.

## Greenhouse

| Field | Pattern |
|---|---|
| Job listing URL | `https://boards.greenhouse.io/{company}/jobs/{id}` |
| Search URL | `https://boards.greenhouse.io/{company}` |
| Title | `h1[class*="title"], .job-title` |
| Location | `div[class*="location"]` |
| Description | `div[class*="content"], #content` |
| Posted date | Meta: `meta[property="article:published_time"]` |

## Lever

| Field | Pattern |
|---|---|
| Job listing URL | `https://jobs.lever.co/{company}/{id}` |
| Search URL | `https://jobs.lever.co/{company}` |
| Title | `h2[class*="title"]` |
| Description | `div[class*="description"]` |
| Posted date | `time[datetime]` attribute |

## LinkedIn — Search Results

Search pages are fully public, server-rendered. Cards contain all basic info.

| Field | Pattern |
|---|---|---|
| Search URL | `https://www.linkedin.com/jobs/search?keywords={query}&location={location}` |
| Pagination | `&start={n}` (25 results per page) |
| Card container | `div.base-search-card.job-search-card[data-entity-urn="urn:li:jobPosting:{id}"]` |
| Title | `h3.base-search-card__title` |
| Company | `h4.base-search-card__subtitle a.hidden-nested-link` |
| Location | `span.job-search-card__location` |
| Posted date (relative) | `time.job-search-card__listdate` or `time.job-search-card__listdate--new` |
| Posted date (absolute) | `time.job-search-card__listdate[datetime]` attribute |
| Detail URL | `a.base-card__full-link` href |
| Job ID | From `data-entity-urn` attribute (`urn:li:jobPosting:{id}`) or from detail URL path |

## LinkedIn — Detail Page

Detail pages are publicly accessible. Description and criteria (seniority, employment type) are **server-rendered** in the HTML. Salary may or may not be present. JSON-LD is employer-dependent.

| Field | Pattern | Notes |
|---|---|---|
| Job listing URL | `https://www.linkedin.com/jobs/view/{id}` | Also accepts `https://www.linkedin.com/jobs/view/{slug}-{id}` |
| Title | `h1.top-card-layout__title` | |
| Company | `a.topcard__org-name-link` | |
| Location | `span.topcard__flavor--bullet` | |
| Posted date | `span.posted-time-ago__text` | Relative text ("8 hours ago", "1 month ago"). No absolute datetime in server HTML. |
| Applicant count | `figcaption.num-applicants__caption` | |
| Description | `div.description__text.description__text--rich > section.show-more-less-html > div.show-more-less-html__markup` | Full HTML, includes `<br>`, `<ul>`, `<li>`, `<strong>` tags. Extract inner text by converting `<br>` to newlines and stripping remaining tags. |
| Seniority level | `ul.description__job-criteria-list li:first-child span.description__job-criteria-text--criteria` | One of: Entry level, Mid-Senior level, Director, Executive |
| Employment type | `ul.description__job-criteria-list li:nth-child(2) span.description__job-criteria-text--criteria` | Full-time, Part-time, Contract, Temporary, etc. |
| Job function | `ul.description__job-criteria-list li:nth-child(3) span.description__job-criteria-text--criteria` | |
| Industries | `ul.description__job-criteria-list li:nth-child(4) span.description__job-criteria-text--criteria` | |
| Salary | `span[class*="salary"]` or inline text | Not always present |
| Meta description | `meta[name="description"]` content | First ~150 chars, useful as fallback when full description block is missing |

## Indeed

| Field | Pattern |
|---|---|
| Job listing URL | `https://www.indeed.com/viewjob?jk={id}` |
| Search URL | `https://www.indeed.com/jobs?q={query}&l={location}` |
| Title | `h1[class*="jobsearch"]` |
| Company | `div[class*="company"]` |
| Location | `div[class*="location"]` |
| Description | `div[id*="jobDescriptionText"]` |
| Salary | `div[id*="salary"]` |

## Workday

| Field | Pattern |
|---|---|
| Job listing URL | `https://{company}.wd5.myworkdayjobs.com/{career-site}/job/{id}` |
| Search URL | `https://{company}.wd5.myworkdayjobs.com/{career-site}` |
| Title | `div[data-automation-id*="jobTitle"]` |
| Location | `div[data-automation-id*="jobLocation"]` |
| Description | `div[data-automation-id*="jobDescription"]` |

## General heuristics (fallback)

When the site is unknown, look for:

- JSON-LD structured data: `script[type="application/ld+json"]` — often contains the full job posting in schema.org/JobPosting format
- Open Graph meta: `meta[property="og:title"]`, `meta[property="og:description"]`
- Common class names: `job-title`, `job-description`, `posting-title`, `posting-description`
