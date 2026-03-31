# Kimi Math Chat

![Demo](demo.gif)


- edit: coming off the spray of Ruby on Rails is one of the most productive languges so I started experimenting with like yeah

A Rails chat app that uses Kimi LLMs (via NVIDIA NIM) to solve math problems, then automatically verifies every mathematical expression in the response using SymPy and Wolfram Alpha.

## How it works

1. User asks a math question
2. Kimi model streams a step-by-step solution back in real-time (via Turbo)
3. `MathDetectorService` extracts LaTeX and equation expressions from the response
4. Each expression is verified in parallel by two backends:
   - **SymPy** — algebraic simplification, LaTeX output, step-by-step derivation (Python)
   - **Wolfram Alpha** — structured result pods (via a Rust native extension or HTTP fallback)
5. Verification status (passed/failed/error) updates live in the UI

## Stack

- **Ruby 4.0 / Rails 8.1** — Hotwire (Turbo + Stimulus), Propshaft, Importmap
- **Tailwind CSS v4** — via tailwindcss-rails
- **SQLite** — primary + Solid Queue/Cable/Cache databases
- **Kimi models** — `kimi-k2-instruct`, `kimi-k2.5`, `kimi-k2-thinking` (NVIDIA API, OpenAI-compatible)
- **SymPy** — Python verification backend
- **Wolfram Alpha** — Rust extension (`wolfram_ext/`) built with Magnus
- **Langfuse** — LLM observability tracing

## Setup

```bash
bundle install
bin/rails db:prepare
bin/dev
```

Requires environment variables:
- `NVIDIA_API_KEY` — for Kimi model access
- `WOLFRAM_APP_ID` — for Wolfram Alpha verification
- `LANGFUSE_PUBLIC_KEY` / `LANGFUSE_SECRET_KEY` — (optional) observability

## Models

| Model | Description |
|-------|-------------|
| Conversation | Chat session, user-selectable model |
| Message | system/user/assistant roles |
| Verification | Per-expression, per-verifier status tracking |
