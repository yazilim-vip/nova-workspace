# OpenClaw Channels

OpenClaw supports 23+ chat channels through a unified gateway architecture. Each channel connects via the gateway using REST APIs, WebSockets, or webhooks.

## Supported Channels

| Channel | Protocol | Setup Complexity | Notes |
|---------|----------|-----------------|-------|
| Discord | WebSocket | Medium | DMs + guild channels, components v2, voice |
| Slack | WebSocket/HTTP | Medium | Socket mode or HTTP with signing secret |
| Telegram | Polling/Webhook | Easy | Simplest setup — just a bot token |
| WhatsApp | Local bridge | Medium | QR pairing, maintains local state |
| Microsoft Teams | Webhook | Medium | Bot Framework integration |
| Google Chat | Webhook | Medium | Service account auth |
| Mattermost | WebSocket | Medium | Self-hosted chat support |
| Matrix | WebSocket | Medium | E2E encryption support |
| Signal | Local bridge | Medium | Phone number required |
| iMessage | CLI bridge | Hard | macOS only, via BlueBubbles or native CLI |
| IRC | TCP | Easy | NickServ support, Twitch compatible |
| Nostr | WebSocket | Easy | Decentralized protocol |
| LINE | Webhook | Medium | Japan-focused messenger |
| Feishu/Lark | Webhook | Medium | Chinese enterprise messenger |
| WebChat | HTTP | Easy | Embeddable web widget |
| Voice Call | WebRTC | Medium | Plivo/Twilio integration |

## Common Configuration Pattern

All channels share these configuration fields:

```json5
{
  channels: {
    "<channel_name>": {
      enabled: true,                    // enable/disable channel
      dmPolicy: "pairing",             // pairing | allowlist | open | disabled
      allowFrom: [],                    // user IDs allowed for DMs
      groupPolicy: "allowlist",         // allowlist | open | disabled
      historyLimit: 50,                 // messages loaded for context
      replyToMode: "off",              // off | first | all | batched
      streaming: "off",                 // off | partial | block | progress
      textChunkLimit: 4000,             // max chars per message
      chunkMode: "length",             // length | newline
      mediaMaxMb: 50,                   // max media file size
      configWrites: true,               // allow config changes from channel
    }
  }
}
```

## DM Policies

| Policy | Behavior |
|--------|----------|
| `pairing` | Unknown senders get a one-time code; message not processed until approved |
| `allowlist` | Only users in `allowFrom` list can DM |
| `open` | Accept all DMs (requires `allowFrom: ["*"]`) |
| `disabled` | Block all inbound DMs |

## Group Policies

| Policy | Behavior |
|--------|----------|
| `allowlist` | Only configured groups/guilds/rooms allowed |
| `open` | Bypass group allowlists (mention gating still applies) |
| `disabled` | Block all group messages |

## Streaming Modes

| Mode | Behavior |
|------|----------|
| `off` | Full response sent after generation completes |
| `partial` | Single message edited as tokens arrive |
| `block` | Draft-sized chunks emitted progressively |
| `progress` | Platform-specific (maps to `partial` on Discord) |

## Reply Threading

| Mode | Behavior |
|------|----------|
| `off` | No implicit reply threading; explicit reply tags still honored |
| `first` | Native reply attached to first outbound message |
| `all` | Native reply on every message |
| `batched` | Only for debounced message batches |

## Channel-Specific Features

### Discord-Specific
- Components v2 (buttons, selects, modals)
- Voice channels (join/leave/status)
- Forum channel support
- Thread-bound sessions for subagents
- Role-based agent routing
- Slash commands
- Exec approval buttons

### Slack-Specific
- Socket mode or HTTP with signing secret
- Slash commands
- Thread history scoping
- Native streaming support

### Telegram-Specific
- Webhook or polling mode
- Custom commands
- SOCKS5 proxy support
- Link preview control

## Multi-Channel Notes

- An agent can be connected to multiple channels simultaneously
- Messages route deterministically: replies go back through the originating channel
- Pairing is per-channel — approving Discord DM does not grant Slack access
- Session keys include channel context for isolation
