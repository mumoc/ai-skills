# MCP Setup

MCP server configs are tracked in `global/settings.json` and symlinked to `~/.ai-skills/settings.json`
by `scripts/bootstrap.sh`. After bootstrapping, some servers require a one-time authentication
step per machine.

---

## GitHub

**Auth:** personal access token via env var — no interactive step needed.

Set this in your shell profile:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN=your-token-here
```

Token needs `repo` and `read:org` scopes at minimum.

---

## Atlassian (Jira + Confluence)

**Auth:** OAuth 2.1 — browser-based, one-time per machine. No API token or env var needed.

On first use, AI Agent will open a browser window for Atlassian login. After you approve
access, the session token is stored locally and reused automatically.

**To trigger the login flow manually:**

```bash
npx -y mcp-remote https://mcp.atlassian.com/v1/mcp
```

The token is stored at `~/.mcp-auth` (managed by `mcp-remote`). It is not committed to this repo.

**Scope:** grants access to all Jira and Confluence sites associated with your Atlassian account.
If you need to re-authenticate (expired session, new account), delete `~/.mcp-auth` and restart
AI Agent.
