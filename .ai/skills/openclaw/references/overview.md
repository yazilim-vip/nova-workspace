# OpenClaw Overview

OpenClaw is an AI assistant platform that connects language models to chat channels (Discord, Slack, Telegram, etc.) through a unified gateway architecture.

## Architecture

```
┌─────────────────────────────────┐
│  Chat Channels                  │
│  Discord, Slack, Telegram, ...  │
├─────────────────────────────────┤
│  OpenClaw Gateway               │
│  Message routing, auth, config  │
├─────────────────────────────────┤
│  Agent Runtime                  │
│  Tools, skills, sessions        │
├─────────────────────────────────┤
│  Model Providers                │
│  Anthropic, OpenAI, Ollama, ... │
└─────────────────────────────────┘
```

- **Gateway** — central hub that owns channel connections, routes messages, manages sessions
- **Agents** — AI personalities defined by model, skills, tools, and system prompts (`AGENTS.md`)
- **Channels** — bidirectional integrations with chat platforms (23+ supported)
- **Tools** — capabilities agents can invoke (exec, browser, web search, file ops, messaging)
- **Skills** — markdown files injected into system prompts for domain knowledge
- **Plugins** — packages combining tools, skills, and integrations

## Prerequisites

- Node.js 24 (or 22.14+)
- API key from at least one model provider
- For channels: platform-specific bot tokens or credentials

## Installation

```bash
# macOS/Linux
curl -fsSL https://install.openclaw.ai | bash

# Run onboarding
openclaw onboard --install-daemon
```

Gateway runs on port **18789** by default.

## Configuration

Primary config file: `~/.openclaw/openclaw.json` (JSON5 format — comments and trailing commas allowed).

Key environment variables:
- `OPENCLAW_HOME` — base directory (default: `~/.openclaw`)
- `OPENCLAW_STATE_DIR` — state storage
- `OPENCLAW_CONFIG_PATH` — override config file location

## Key Concepts

### Hub-and-Spoke Model
The gateway is the central router. All channels connect through it. Messages from any channel can reach any agent. Agents reply through the originating channel.

### Session Scoping
Conversations are isolated by session keys. DMs, guild channels, and threads each get distinct sessions. Session scope is configurable (per-sender, global, per-peer, etc.).

### Pairing
Safety mechanism requiring explicit owner approval before unknown users can interact. Used for DM access and node joining. Pairing codes are 8 chars, expire after 1 hour, max 3 pending per channel.

### Security Model
- DM and group access controlled via policies (pairing, allowlist, open, disabled)
- Mention gating in group chats
- Tool access controlled via allow/deny lists
- Exec approvals for command execution
- Sandbox support (Docker, SSH) for isolated execution
