# Agents and Sessions

## Agent Configuration

Agents are AI personalities defined by model, workspace, skills, tools, and behavior settings.

### Agent Defaults

```json5
{
  agents: {
    defaults: {
      // Workspace
      workspace: "~/.openclaw/workspace",
      repoRoot: null,                         // auto-detected if unset
      skipBootstrap: false,
      contextInjection: "always",             // always | continuation-skip
      bootstrapMaxChars: 20000,
      bootstrapTotalMaxChars: 150000,

      // Model
      model: "anthropic/claude-sonnet-4-20250514",  // string or { primary, fallbacks }
      imageModel: null,                       // separate model for image analysis
      imageGenerationModel: null,
      musicGenerationModel: null,
      videoGenerationModel: null,
      pdfModel: null,

      // Model parameters
      params: {
        temperature: null,
        maxTokens: null,
        cacheRetention: null,
      },

      // Behavior
      thinkingDefault: "off",                 // off | minimal | low | medium | high | xhigh | adaptive
      verboseDefault: "off",                  // off | on | full
      elevatedDefault: "off",                 // off | on | ask | full
      timeoutSeconds: 600,
      contextTokens: 200000,
      maxConcurrent: 3,
      mediaMaxMb: 5,
      userTimezone: null,                     // IANA timezone
      timeFormat: "auto",                     // auto | 12 | 24

      // Skills
      skills: [],                             // allowlist — empty means all allowed

      // Image handling
      imageMaxDimensionPx: 1200,
      pdfMaxBytesMb: 10,
      pdfMaxPages: 20,

      // Typing indicators
      typingMode: "thinking",                 // never | instant | thinking | message
      typingIntervalSeconds: 6,

      // Block streaming
      blockStreamingDefault: "off",           // on | off
      blockStreamingBreak: "text_end",        // text_end | message_end
      blockStreamingChunk: { minChars: 200, maxChars: 800 },
      humanDelay: { mode: "off" },            // off | natural | custom

      // Heartbeat
      heartbeat: {
        every: "30m",
        model: null,                          // use different model for heartbeat
        prompt: null,                         // custom heartbeat prompt
        target: "none",                       // none | channel_name
        to: null,                             // delivery target
      },

      // Compaction (context window management)
      compaction: {
        mode: "default",                      // default | safeguard
        timeoutSeconds: 900,
        reserveTokensFloor: 24000,
        model: null,                          // use different model for compaction
        notifyUser: false,
        memoryFlush: { enabled: false },
      },

      // Context pruning
      contextPruning: {
        mode: "off",                          // off | cache-ttl
        ttl: null,
        keepLastAssistants: 3,
      },

      // Sandbox
      sandbox: {
        mode: "off",                          // off | non-main | all
        backend: "docker",                    // docker | ssh | openshell
        scope: "agent",                       // agent | session | shared
        workspaceAccess: "none",              // none | ro | rw
      },
    }
  }
}
```

### Per-Agent Definitions

```json5
{
  agents: {
    list: [
      {
        id: "main",                           // required — stable identifier
        default: true,                        // make this the default agent
        name: "Assistant",
        workspace: "~/.openclaw/workspace",
        model: "anthropic/claude-sonnet-4-20250514",
        skills: [],
        tools: { profile: "full" },
        identity: {
          name: "Assistant",
          theme: "default",
          emoji: "🤖",
          avatar: null,
        },
        groupChat: {
          mentionPatterns: [],                // custom mention detection patterns
        },
      },
      {
        id: "coder",
        name: "Coder",
        model: "anthropic/claude-sonnet-4-20250514",
        workspace: "/path/to/project",
        tools: { profile: "coding" },
        sandbox: { mode: "all", backend: "docker" },
      },
    ]
  }
}
```

### Agent Runtime Types

```json5
{
  agents: {
    list: [
      {
        id: "remote-agent",
        runtime: {
          type: "acp",                        // default (local) or acp (remote)
          acp: {
            agent: "codex",
            backend: "acpx",
            mode: "persistent",               // persistent | ephemeral
            cwd: "/workspace/project",
          },
        },
      }
    ]
  }
}
```

## Session Configuration

Sessions isolate conversations. Each session has its own context, history, and agent state.

```json5
{
  session: {
    // Scoping
    scope: "per-sender",                      // per-sender | global
    dmScope: "main",                          // main | per-peer | per-channel-peer | per-account-channel-peer

    // Identity linking (map aliases to same identity)
    identityLinks: {
      "primary_user": ["discord:123", "telegram:456"],
    },

    // Auto-reset
    reset: {
      mode: "idle",                           // daily | idle
      atHour: 4,                              // for daily mode (UTC hour)
      idleMinutes: 60,                        // for idle mode
    },
    resetByType: {                            // per session type overrides
      thread: { mode: "idle", idleMinutes: 120 },
      direct: { mode: "idle", idleMinutes: 60 },
      group: { mode: "idle", idleMinutes: 30 },
    },
    resetTriggers: ["/reset", "/clear"],      // commands that reset session

    // Storage
    store: null,                              // file path for sessions.json

    // Thread bindings
    threadBindings: {
      enabled: true,
      idleHours: 24,
      maxAgeHours: 0,                         // 0 = no limit
    },

    // Agent-to-agent
    agentToAgent: {
      maxPingPongTurns: 10,                   // prevent infinite loops
    },

    // Forking
    parentForkMaxTokens: 100000,

    // Maintenance
    maintenance: {
      mode: "auto",
      pruneAfter: "7d",
      maxEntries: 1000,
      maxDiskBytes: 104857600,                // 100MB
    },

    // Send policy (control which messages agents can send)
    sendPolicy: {
      default: "allow",
      rules: [
        { action: "block", match: { channel: "discord", target: "channel:*" } },
      ],
    },
  }
}
```

## Session Key Format

Sessions are identified by composite keys:

| Context | Key Format |
|---------|------------|
| DM (default) | `agent:main:main` |
| DM (per-peer) | `agent:<agentId>:discord:dm:<userId>` |
| Guild channel | `agent:<agentId>:discord:channel:<channelId>` |
| Thread | `agent:<agentId>:discord:thread:<threadId>` |
| Slash command | `agent:<agentId>:discord:slash:<userId>` |

## Multi-Agent Routing

### Channel Bindings

Route different channels/guilds/roles to different agents:

```json5
{
  bindings: [
    {
      agentId: "opus",
      match: {
        channel: "discord",
        guildId: "SERVER_ID",
        roles: ["ROLE_ID"],
      },
    },
    {
      agentId: "sonnet",
      match: {
        channel: "discord",
        guildId: "SERVER_ID",
      },
    },
    {
      type: "acp",
      agentId: "codex",
      match: {
        channel: "discord",
        peer: { kind: "channel", id: "CHANNEL_ID" },
      },
    },
  ]
}
```

Evaluation order: peer/parent-peer → role-based → guild-only → default.

### Subagent Control

```json5
{
  agents: {
    list: [
      {
        id: "orchestrator",
        subagents: {
          allowAgents: ["coder", "researcher"],
          requireAgentId: true,
        }
      }
    ]
  }
}
```
