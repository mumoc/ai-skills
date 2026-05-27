---
name: fetch-page
model_tier: fast
---

# Fetch Page

Given a URL from `configure-source`, fetch HTML for downstream parsing.

## Process

1. **Robots.txt.** Fetch once per domain per session. Respect `Disallow` and `Crawl-delay`.
2. **Rate limit.** Wait configured delay since last request to this domain. See `references/rate-limiting.md`.
3. **Choose fetch method:**

   | Scenario | Approach |
   |---|---|
   | Server-rendered (most sites) | HTTP GET with browser-like headers |
   | Client-rendered | Headless browser or API intercept |
   | Auth-required | Headless browser with user session, saved HTML, or API intercept |

4. **Verify response.** Check for login page (title "Sign in", login forms, absent job content). Reject if caught.
5. **Return** HTML string + metadata.

## Output

```json
{"source_id": "...", "url": "...", "fetched_at": "...", "http_status": 200, "html": "<!DOCTYPE html>...", "next_page_url": null}
```
