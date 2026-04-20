---
name: openclaw
description: Configure and deploy OpenClaw AI gateway. Use when setting up OpenClaw channels (Discord, Slack, Telegram), model providers (Ollama, Anthropic, OpenAI), writing openclaw.json gateway configuration, deploying to Kubernetes, or writing agent instructions.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "unstable"
---

# OpenClaw

> **Status: Unstable** — Gateway startup issues resolved via Docker Compose testing (OOM, config validation). K8s manifests updated but not yet verified on a real cluster. Key requirement: the gateway needs `NODE_OPTIONS=--max-old-space-size=4096` (4GB V8 heap) because it transpiles 100+ TypeScript extensions via jiti at startup. Expect 2–4 minute cold start.

Configure and deploy [OpenClaw](https://docs.openclaw.ai) — an AI assistant platform that connects language models to 23+ chat channels through a unified gateway. Triggers are in the frontmatter description above.

## References

| File | Description |
|------|-------------|
| [overview.md](references/overview.md) | Architecture, prerequisites, key concepts |
| [gateway-config.md](references/gateway-config.md) | Full `openclaw.json` schema reference |
| [channels.md](references/channels.md) | All 23+ supported channels, policies, streaming |
| [discord.md](references/discord.md) | Complete Discord setup, config, components, voice |
| [providers.md](references/providers.md) | Model provider configs — Ollama, Anthropic, OpenAI, Google |
| [tools.md](references/tools.md) | Built-in tools, profiles, groups, allow/deny |
| [agents-sessions.md](references/agents-sessions.md) | Agent definitions, session scoping, multi-agent routing |
| [kubernetes.md](references/kubernetes.md) | K8s deployment, security, ingress, FluxCD, Kind |

## Key rules

- Never hardcode secrets — use env var refs or secret managers
- Always use `api: "ollama"` for Ollama providers (never `/v1` endpoint)
- Default to security-hardened pod specs for Kubernetes deployments
- Use placeholder values in examples (`YOUR_SERVER_ID`, `your-domain.example.com`)
- Follow OpenClaw's JSON5 format for `openclaw.json` examples
- Keep reference files in sync with upstream OpenClaw documentation

## Known issues and gotchas

- **OOM at startup**: The gateway transpiles 100+ TypeScript extensions via jiti at runtime. Default V8 heap (2GB) is insufficient — set `NODE_OPTIONS=--max-old-space-size=4096`. Without this, the process crashes with "JavaScript heap out of memory".
- **Slow cold start**: First startup takes 2–4 minutes for jiti transpilation. K8s probes must use `startupProbe` with high `failureThreshold` (30+) to avoid restart loops.
- **Config format**: Gateway settings live under `gateway.*` (not top-level `host`/`port`). Bind address uses `gateway.bind` with values: `auto`, `lan`, `loopback`, `custom`, `tailnet` — not raw IPs like `0.0.0.0`.
- **Config rewrite**: OpenClaw rewrites `openclaw.json` at startup to add `meta`, `plugins`, and `gateway.auth.token` fields. In K8s, mount config via init container to a writable PVC, not a read-only ConfigMap subPath. The init container must only seed config if it doesn't exist yet (`[ -f openclaw.json ] || cp ...`), otherwise OpenClaw detects a config diff on restart and enters an infinite restart loop.
- **Discord token ref**: Use `{"ref-source": "env", "ref-id": "DISCORD_BOT_TOKEN"}` — do NOT include `"ref-provider"` field (causes validation error).
- **Model entries require `name`**: Each entry in `models.providers.*.models[]` must have both `id` and `name` fields.
- **`readOnlyRootFilesystem: true`** is NOT compatible — the gateway writes to `/tmp/jiti/` for transpilation cache and to `~/.openclaw/` for config rewrites. Set to `false`.

## Assets

- [Kubernetes deployment](assets/k8s/) — Kustomize manifests for K8s with Discord + Ollama Cloud
