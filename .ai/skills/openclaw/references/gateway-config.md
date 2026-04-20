# Gateway Configuration Reference

The primary configuration file is `openclaw.json` (JSON5 format). Located at `~/.openclaw/openclaw.json` by default.

## Top-Level Structure

```json5
{
  // Gateway server settings
  gateway: {
    bind: "loopback",                         // auto | lan | loopback | custom | tailnet
    port: 18789,                              // listen port
    auth: {
      mode: "token",                          // token | none
    },
  },

  // Channel integrations
  channels: { /* see channels.md, discord.md */ },

  // Agent definitions and defaults
  agents: { /* see agents-sessions.md */ },

  // Session management
  session: { /* see agents-sessions.md */ },

  // Model providers
  models: { /* see providers.md */ },

  // Tool configuration
  tools: { /* see tools.md */ },

  // Message handling
  messages: { /* see below */ },

  // Voice/talk settings
  talk: { /* see below */ },

  // Commands
  commands: { /* see below */ },

  // Automation
  hooks: {},
  cron: {},
}
```

## Messages Configuration

```json5
{
  messages: {
    responsePrefix: "auto",                   // string or "auto" (uses agent name)
    ackReaction: "👀",                        // emoji shown while processing
    ackReactionScope: "group-mentions",       // group-mentions | group-all | direct | all
    removeAckAfterReply: true,                // boolean

    statusReactions: {
      enabled: false,                         // boolean
    },

    // Message queue behavior
    queue: {
      mode: "collect",                        // collect | steer | followup | steer-backlog | steer+backlog | queue | interrupt
      debounceMs: 1000,                       // number
      cap: 20,                                // max queued messages
      drop: "old",                            // old | new | summarize
      byChannel: {},                          // per-channel mode overrides
    },

    // Inbound debouncing
    inbound: {
      debounceMs: 2000,                       // number
      byChannel: {},                          // per-channel overrides
    },

    // Group chat defaults
    groupChat: {
      historyLimit: 50,                       // messages loaded for context
    },

    // Text-to-speech
    tts: {
      auto: "off",                            // off | always | inbound | tagged
      mode: "final",                          // final | all
      provider: "openai",                     // elevenlabs | openai
      maxTextLength: 4000,
      timeoutMs: 30000,
      openai: {
        model: "tts-1",
        voice: "alloy",
      },
      elevenlabs: {
        voiceId: "...",
        modelId: "eleven_multilingual_v2",
      },
    },
  }
}
```

## Commands Configuration

```json5
{
  commands: {
    native: "auto",                           // auto | true | false — platform slash commands
    text: true,                               // text command parsing
    bash: false,                              // allow bash commands from chat
    bashForegroundMs: 2000,                   // foreground timeout for bash
    config: false,                            // allow config commands
    debug: false,                             // allow debug commands
    restart: false,                           // allow restart command
    allowFrom: {                              // per-channel owner allowlists
      discord: ["USER_ID"],
      telegram: ["tg:USER_ID"],
    },
    useAccessGroups: true,                    // boolean
  }
}
```

## Talk Configuration (Voice Mode)

```json5
{
  talk: {
    provider: "openai",                       // provider key
    silenceTimeoutMs: 3000,                   // platform-specific default
    interruptOnSpeech: true,                  // boolean
    providers: {
      openai: {
        voiceId: "alloy",
        modelId: "gpt-4o-realtime",
        outputFormat: "pcm16",
      }
    }
  }
}
```

## Channel Defaults

```json5
{
  channels: {
    defaults: {
      groupPolicy: "allowlist",               // default for all channels
      contextVisibility: "all",               // all | allowlist | allowlist_quote
      heartbeat: {
        showOk: true,
        showAlerts: true,
        useIndicator: false,
      },
    },
    modelByChannel: {                         // route specific channels to specific models
      "provider_name": {
        "CHANNEL_ID": "provider/model",
      }
    },
  }
}
```

## Environment Variable References

Sensitive fields support ref objects instead of inline values:

```json5
{
  token: {
    "ref-provider": "default",
    "ref-source": "env",                      // env | file | exec
    "ref-id": "DISCORD_BOT_TOKEN",            // env var name, file path, or command
  }
}
```

## Configuration Precedence

1. Per-account settings (e.g. `channels.discord.accounts.default.*`)
2. Channel-level settings (e.g. `channels.discord.*`)
3. Channel defaults (e.g. `channels.defaults.*`)
4. Global defaults
