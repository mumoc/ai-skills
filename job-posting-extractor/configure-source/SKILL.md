---
name: configure-source
model_tier: fast
---

# Configure Source

Identify target sites and produce a config for `fetch-page`.

## Process

1. **Accept input.** Board name, career page URL, search query, or URL list.
2. **Classify.** Known board (LinkedIn, Indeed, Greenhouse, Lever, Workday) → use `references/site-patterns.md`. Company page → detect ATS (greenhouse.io, jobs.lever.co, wd5.myworkdayjobs.com). Unknown → flag for manual selector discovery.
3. **Flag auth/rendering.** Per site:

   | Site | Auth | Rendering |
   |---|---|---|
   | LinkedIn search | No | Server-rendered (HTTP GET) |
   | LinkedIn detail | No | Server-rendered (HTTP GET) |
   | Indeed | Partial | Server-rendered (may redirect to login) |
   | Greenhouse/Lever/Workday | No | Server-rendered (HTTP GET) |

4. **Set pagination.** Next-page URL pattern per site.

## Output

```json
{"sources": [{"id": "acme", "site": "greenhouse", "listing_url": "https://...", "pagination": "?page={n}"}]}
```

Passthrough to `fetch-page`. One entry per source.
