# Model Providers

OpenClaw supports 50+ model providers. Providers are configured under `models.providers` in `openclaw.json`.

## Provider Configuration

```json5
{
  models: {
    mode: "merge",                            // merge | replace — merge adds to built-in, replace overrides all
    providers: {
      "provider_id": {
        baseUrl: "https://api.example.com",
        apiKey: "...",                         // or ref object for env/file/exec
        api: "openai-completions",            // API protocol
        auth: "bearer",                       // auth method
        authHeader: "Authorization",          // custom auth header
        models: [                             // explicit model list
          {
            id: "model-name",
            name: "Display Name",
            reasoning: false,
            contextWindow: 128000,
            // contextTokens: 128000,
            maxTokens: 4096,
            cost: { input: 0.001, output: 0.002 },
          }
        ],
        headers: {},                          // extra request headers
        request: {
          proxy: "http://proxy:8080",
          tls: { rejectUnauthorized: true },
        },
      }
    }
  }
}
```

## API Types

| API | Description |
|-----|-------------|
| `openai-completions` | OpenAI Chat Completions API |
| `openai-responses` | OpenAI Responses API |
| `anthropic-messages` | Anthropic Messages API |
| `google-generative-ai` | Google Generative AI API |
| `ollama` | Native Ollama API (recommended for Ollama) |

## Ollama Configuration

### Local Ollama

```json5
{
  models: {
    providers: {
      ollama: {
        baseUrl: "http://127.0.0.1:11434",
        apiKey: "ollama-local",               // any value works for local
        api: "ollama",
      }
    }
  },
  agents: {
    defaults: {
      model: "ollama/llama3.3"
    }
  }
}
```

### Ollama Cloud

```json5
{
  models: {
    providers: {
      ollama: {
        baseUrl: "https://ollama.com",
        api: "ollama",
        // apiKey from OLLAMA_API_KEY env var or ollama signin token
        models: [                              // required — explicit model list
          { id: "qwen3-coder:480b-cloud", name: "Qwen3 Coder 480B Cloud" },
        ],
      }
    }
  },
  agents: {
    defaults: {
      model: "ollama/qwen3-coder:480b-cloud"
    }
  }
}
```

Available cloud models:
- `qwen3-coder:480b-cloud`
- `gpt-oss:120b-cloud`
- `gpt-oss:20b-cloud`
- `deepseek-v3.1:671b-cloud`

**Important:** Do NOT add `/v1` to Ollama URLs. The `/v1` path uses OpenAI-compatible mode where tool calling is unreliable. Always set `api: "ollama"` to use the native `/api/chat` endpoint.

### Ollama Cloud Authentication

```bash
# Sign in to get a token
ollama signin

# Token stored at ~/.ollama/auth/token
# Use as OLLAMA_API_KEY environment variable
```

## Anthropic

```json5
{
  agents: {
    defaults: {
      model: "anthropic/claude-sonnet-4-20250514"
    }
  }
}
```

Environment variable: `ANTHROPIC_API_KEY`

## OpenAI

```json5
{
  agents: {
    defaults: {
      model: "openai/gpt-4o"
    }
  }
}
```

Environment variable: `OPENAI_API_KEY`

## Google

```json5
{
  agents: {
    defaults: {
      model: "google/gemini-2.5-pro"
    }
  }
}
```

Environment variable: `GEMINI_API_KEY`

## Model Selection Syntax

Reference models by `provider/model` format:

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "anthropic/claude-sonnet-4-20250514",
        fallbacks: ["openai/gpt-4o", "ollama/llama3.3"]
      }
    }
  }
}
```

## Provider-Specific Tool Rules

```json5
{
  tools: {
    byProvider: {
      "ollama/llama3.3": {
        profile: "minimal",
        deny: ["exec", "browser"],
      }
    }
  }
}
```
