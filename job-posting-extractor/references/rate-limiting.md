# Rate Limiting & Politeness

## Default rules

| Rule | Value |
|---|---|
| Delay between requests | 2–5 seconds (randomize) |
| Retry on 429/503 | 3 attempts, exponential backoff (5s, 15s, 45s) |
| Concurrent requests | 1 (sequential pages) |
| User-Agent | Identify as `JobPostingExtractor/1.0` with contact info if possible |

## robots.txt

Before fetching from a new site, check `robots.txt`:

- Respect `Disallow` rules for the paths you are crawling.
- Read `Crawl-delay` directive if present and use the larger of that or the default delay.
- Cache `robots.txt` per session (no need to fetch for every page of the same site).

## Caching

- Cache each fetched page in memory for the session keyed by URL.
- If the same URL appears (e.g. pagination loop lands on same page), reuse cached response — do not re-fetch.
- Log cache hits to avoid confusion.

## Detecting login walls

Some sites return a login page with HTTP 200 instead of 401. Detect these by checking the response HTML for:
- Page title or heading containing "Sign in", "Log in", "Sign in to continue"
- Form fields for username/email and password
- Absence of expected job content markers (job title, job description container)
- Redirect to a known login domain (`/login`, `/auth`, `auth.` subdomain)

If any of these are detected, the fetch failed due to auth. Report to the user and suggest: providing a saved HTML file, using a headless browser with their session, or providing an API key.

## Error handling

| Response | Action |
|---|---|
| 200 OK | Parse and continue |
| 301/302 | Follow redirect (max 5 hops) |
| 401/403 | Log auth failure, skip site, report to user |
| 404 | Log and skip (job removed or expired) |
| 429 | Wait `Retry-After` header or exponential backoff, then retry |
| 5xx | Retry once after 10s, then skip and report |
| Timeout | Increase timeout once (30s → 60s), retry once, then skip |
