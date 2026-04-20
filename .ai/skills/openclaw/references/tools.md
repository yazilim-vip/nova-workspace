# OpenClaw Tools

Tools are typed functions that agents can invoke. OpenClaw provides built-in tools organized into groups.

## Built-in Tools

| Tool | Description |
|------|-------------|
| `exec` / `process` | Run shell commands, manage background processes |
| `browser` | Control Chromium (navigate, click, screenshot) |
| `web_search` / `x_search` | Search the web or X posts |
| `web_fetch` | Fetch and process web page content |
| `code_execution` | Sandboxed Python analysis |
| `read` / `write` / `edit` | File operations |
| `apply_patch` | Apply unified diffs |
| `message` | Send messages across channels |
| `image` / `image_generate` | Image analysis and generation |
| `music_generate` | Music generation |
| `video_generate` | Video generation |
| `tts` | Text-to-speech |
| `memory_search` / `memory_get` | Long-term memory access |
| `sessions_spawn` | Sub-agent session management |

## Three-Layer Architecture

1. **Tools** — typed functions agents invoke
2. **Skills** — markdown files injected into system prompts for domain knowledge
3. **Plugins** — packages combining tools, skills, and integrations

## Tool Profiles

Pre-configured allowlists:

| Profile | Includes |
|---------|----------|
| `full` | All tools |
| `coding` | File ops, exec, web search |
| `messaging` | Message, channels |
| `minimal` | Read-only, no exec |

## Tool Groups

Shorthand references for permission management:

| Group | Tools |
|-------|-------|
| `group:runtime` | exec, process |
| `group:fs` | read, write, edit, apply_patch |
| `group:sessions` | Session management tools |
| `group:memory` | Memory tools |
| `group:web` | web_search, web_fetch |
| `group:ui` | browser, canvas |
| `group:automation` | cron, gateway |
| `group:messaging` | message |
| `group:media` | image, image_generate, video_generate, tts |
| `group:openclaw` | All built-in tools |

## Configuration

```json5
{
  tools: {
    // Profile baseline
    profile: "full",                          // minimal | coding | messaging | full

    // Fine-grained control (deny takes precedence over allow)
    allow: ["exec", "group:fs", "message"],
    deny: ["browser"],

    // Per-provider overrides
    byProvider: {
      "ollama/llama3.3": {
        profile: "coding",
        deny: ["exec"],
      }
    },

    // Elevated execution (requires approval)
    elevated: {
      enabled: false,
      allowFrom: {
        discord: ["USER_ID"],
      },
    },

    // Exec settings
    exec: {
      backgroundMs: 10000,                   // timeout before backgrounding
      timeoutSec: 1800,                       // hard timeout (30 min)
      cleanupMs: 1800000,                     // cleanup delay
      notifyOnExit: true,
      applyPatch: {
        enabled: true,
        allowModels: [],                      // restrict to specific models
      },
    },

    // Loop detection
    loopDetection: {
      enabled: true,
      historySize: 30,
      warningThreshold: 10,
      criticalThreshold: 20,
      globalCircuitBreakerThreshold: 30,
    },

    // Web tools
    web: {
      search: {
        enabled: true,
        maxResults: 10,
        timeoutSeconds: 30,
        cacheTtlMinutes: 15,
      },
      fetch: {
        enabled: true,
        maxChars: 50000,
        timeoutSeconds: 30,
        cacheTtlMinutes: 15,
        maxRedirects: 5,
      },
    },

    // Media tools
    media: {
      concurrency: 2,
      audio: { enabled: true },
      video: { enabled: true },
    },

    // Agent-to-agent communication
    agentToAgent: {
      enabled: true,
      allow: [],                              // restrict which agents can be called
    },

    // Session tools
    sessions: {
      visibility: "self",                     // self | tree | agent | all
    },

    // Experimental
    experimental: {
      planTool: false,
    },
  }
}
```

## Per-Agent Tool Overrides

```json5
{
  agents: {
    list: [
      {
        id: "restricted-agent",
        tools: {
          profile: "minimal",
          allow: ["read", "message"],
          deny: ["exec", "browser"],
          elevated: ["write"],                // require approval for these
        }
      }
    ]
  }
}
```
