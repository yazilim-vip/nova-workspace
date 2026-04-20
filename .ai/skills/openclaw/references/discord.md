# Discord Integration

Comprehensive reference for configuring OpenClaw's Discord channel.

## Setup Steps

### 1. Create Discord Application and Bot
- Go to Discord Developer Portal, create new application
- Add a bot, set username to your preferred agent name

### 2. Enable Required Intents
In Bot settings, enable:
- **Message Content Intent** (mandatory)
- **Server Members Intent** (recommended — for role allowlists and name-to-ID matching)
- **Presence Intent** (optional — only for presence updates)

### 3. Obtain Bot Token
Bot page → Reset Token → save securely

### 4. Generate OAuth2 Invite URL
OAuth2 → URL Generator:
- Scopes: `bot`, `applications.commands`
- Bot Permissions: View Channels, Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions

### 5. Collect IDs
Enable Developer Mode (User Settings → Advanced → Developer Mode).
- Server ID: right-click server icon
- User ID: right-click your avatar

### 6. Configure OpenClaw

```json5
{
  channels: {
    discord: {
      enabled: true,
      token: {
        "ref-source": "env",
        "ref-id": "DISCORD_BOT_TOKEN"
      },
      dmPolicy: "pairing",
      groupPolicy: "allowlist",
      guilds: {
        "YOUR_SERVER_ID": {
          requireMention: true,
          users: ["YOUR_USER_ID"]
        }
      }
    }
  }
}
```

### 7. Complete Pairing
DM the bot → receive pairing code → approve via:
- CLI: `openclaw pairing approve discord <CODE>`
- Control UI
- Another paired channel: "Approve this Discord pairing code: `<CODE>`"

Codes expire after 1 hour.

## Full Configuration Reference

```json5
{
  channels: {
    discord: {
      // Core
      enabled: true,                          // boolean
      token: "...",                           // string or ref object
      mediaMaxMb: 100,                        // number (default: 100)

      // Access Control
      dmPolicy: "pairing",                    // pairing | allowlist | open | disabled
      allowFrom: ["user_id"],                 // user IDs for DM allowlist
      groupPolicy: "allowlist",               // allowlist | open | disabled
      allowBots: false,                       // boolean | "mentions"

      // DM Settings
      dm: {
        enabled: true,                        // boolean
        groupEnabled: false,                  // boolean
        groupChannels: [],                    // channel IDs for group DMs
      },

      // Guild Configuration
      guilds: {
        "SERVER_ID": {
          slug: "my-server",                  // optional friendly name
          requireMention: true,               // boolean
          ignoreOtherMentions: false,         // boolean — drop messages mentioning others but not bot
          reactionNotifications: "own",       // off | own | all | allowlist
          users: ["USER_ID"],                 // user ID allowlist
          roles: ["ROLE_ID"],                 // role ID allowlist (users OR roles must match)
          channels: {                         // optional channel-level overrides
            "CHANNEL_ID": {
              allow: true,
              requireMention: true,
            }
          },
          skills: [],                         // guild-specific skills
          systemPrompt: "",                   // guild-specific system prompt
        }
      },

      // Message Handling
      historyLimit: 20,                       // number (default: 20)
      dmHistoryLimit: null,                   // number — override for DMs
      textChunkLimit: 2000,                   // number (default: 2000)
      chunkMode: "length",                    // length | newline
      maxLinesPerMessage: 17,                 // number (default: 17)
      replyToMode: "off",                     // off | first | all | batched

      // Streaming
      streaming: "off",                       // off | partial | block | progress
      draftChunk: {                           // block mode settings
        minChars: 200,
        maxChars: 800,
        breakPreference: "paragraph",
      },

      // UI Components
      ui: {
        components: {
          accentColor: "#5865F2",             // hex color
        }
      },

      // Thread Bindings
      threadBindings: {
        enabled: true,
        idleHours: 24,
        maxAgeHours: 0,                       // 0 = no max
        spawnSubagentSessions: false,
      },

      // Voice
      voice: {
        enabled: true,
        autoJoin: [{ guildId: "...", channelId: "..." }],
        daveEncryption: true,
        decryptionFailureTolerance: 24,
        tts: {
          provider: "openai",
          openai: { voice: "alloy" },
        },
      },

      // Exec Approvals
      execApprovals: {
        enabled: true,
        approvers: [],                        // falls back to commands.ownerAllowFrom
        target: "dm",                         // dm | channel | both
      },

      // Slash Commands
      commands: {
        native: "auto",                       // auto | true | false
      },

      // Actions (tool permissions)
      actions: {
        reactions: true,                      // default: enabled
        messages: true,
        threads: true,
        pins: true,
        polls: true,
        search: true,
        memberInfo: true,
        roleInfo: true,
        channelInfo: true,
        channels: true,
        voiceStatus: true,
        events: true,
        stickers: true,
        emojiUploads: true,
        stickerUploads: true,
        permissions: true,
        roles: false,                         // default: disabled
        moderation: false,                    // default: disabled
        presence: false,                      // default: disabled
      },

      // Presence
      status: "online",                       // online | idle | dnd
      activity: "Focus time",
      activityType: 4,                        // 0=Playing 1=Streaming 2=Listening 3=Watching 4=Custom 5=Competing
      autoPresence: {
        enabled: true,
        intervalMs: 30000,
        minUpdateIntervalMs: 15000,
      },

      // Performance
      retry: { attempts: 3, minDelayMs: 1000, maxDelayMs: 30000, jitter: true },

      // Networking
      proxy: "http://proxy.example:8080",     // HTTP(S) proxy for Discord WebSocket
      configWrites: true,                     // allow config changes from Discord
    }
  }
}
```

## Multi-Account Support

```json5
{
  channels: {
    discord: {
      accounts: {
        default: {
          // inherits top-level discord config
          allowFrom: ["user_id"],
          ackReaction: "👀",
          eventQueue: { listenerTimeout: 120000 },
          inboundWorker: { runTimeoutMs: 1800000 },
        },
        secondary: {
          token: { "ref-source": "env", "ref-id": "DISCORD_BOT_TOKEN_2" },
          allowFrom: ["other_user_id"],
        }
      }
    }
  }
}
```

- `DISCORD_BOT_TOKEN` env only used for default account
- Per-account policy/retry settings from selected account
- Config token values win over env fallback

## Interactive Components

Supported blocks: `text`, `section`, `separator`, `actions`, `media-gallery`, `file`

```json5
{
  channel: "discord",
  action: "send",
  to: "channel:CHANNEL_ID",
  message: "Optional fallback text",
  components: {
    reusable: true,
    text: "Choose a path",
    blocks: [
      {
        type: "actions",
        buttons: [
          { label: "Approve", style: "success", allowedUsers: ["USER_ID"] },
          { label: "Decline", style: "danger" },
        ],
      },
      {
        type: "actions",
        select: {
          type: "string",                     // string | user | role | mentionable | channel
          placeholder: "Pick an option",
          options: [
            { label: "Option A", value: "a" },
            { label: "Option B", value: "b" },
          ],
        },
      },
    ],
    modal: {
      title: "Details",
      triggerLabel: "Open form",
      fields: [
        { type: "text", label: "Requester" },
        { type: "select", label: "Priority", options: [
          { label: "Low", value: "low" },
          { label: "High", value: "high" },
        ]},
      ],
    },
  },
}
```

Modal field types: `text`, `checkbox`, `radio`, `select`, `role-select`, `user-select` (max 5 fields).

## Forum Channels

```bash
# Auto-create thread (first non-empty line = title)
openclaw message send --channel discord \
  --target channel:<forumId> \
  --message "Topic title\nBody of the post"

# Explicit thread creation
openclaw message thread create --channel discord \
  --target channel:<forumId> \
  --thread-name "Topic title" --message "Body of the post"
```

## Thread Commands

- `/focus <target>` — bind thread to subagent/session
- `/unfocus` — remove binding
- `/agents` — show active runs and binding state
- `/session idle <duration|off>` — inactivity auto-unfocus
- `/session max-age <duration|off>` — hard max age

## Role-Based Agent Routing

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
  ],
}
```

Evaluated after peer/parent-peer bindings, before guild-only bindings.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Disallowed intents | Enable Message Content + Server Members intents, restart gateway |
| Guild messages blocked | Verify `groupPolicy`, guild allowlist, `requireMention` |
| DM pairing stuck | Check `dmPolicy` not `disabled`, verify pairing mode active |
| Bot-to-bot loops | Keep `allowBots: false` (default), or use `allowBots: "mentions"` |
| Long handler timeouts | Increase `listenerTimeout` and `inboundWorker.runTimeoutMs` |
| Voice decrypt failures | Keep `daveEncryption: true`, set `decryptionFailureTolerance: 24` |

## Security Notes

- Treat bot tokens as secrets — use env var refs, never inline
- Grant least-privilege Discord permissions
- Use IDs (not names/tags) in allowlists
- Only enable `dangerouslyAllowNameMatching` as break-glass
