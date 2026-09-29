# AI Tool Usage Log

This project was built in an iterative, step-by-step collaboration with an AI coding assistant (Claude, via Claude Code). The workflow for nearly every step was the same loop:

1. Ask the assistant for the next concrete step (backend model, endpoint, service, frontend page, etc.), including exact file contents and shell commands.
2. Run the commands/apply the file changes myself.
3. Run the test suite (or load the page in the browser) and paste the actual output back.
4. If something failed, paste the exact error (console output, RSpec failure, screenshot) rather than a paraphrase, and get a root-cause fix before moving to the next step.
5. Commit at each meaningful checkpoint, with a message describing that specific change — not one commit at the end.

## High-level instruction given to the assistant

> "Guide me step by step to build this application, including commits."

Followed by an explicit decision to keep the assistant in "guide, don't execute" mode: the assistant proposed exact commands and code; I ran everything myself in my own terminal/editor and reported results back.

## Representative debugging prompts used along the way

- "why migrations only not model?" — asked for the reasoning behind a specific tooling choice, not just the command.
- Pasted a full RSpec failure (`NoMethodError: undefined method 'build'`) verbatim to get the actual root cause (FactoryBot's syntax methods weren't included in RSpec config) instead of a guess.
- Pasted a full stack trace (`ArgumentError: unknown keyword: quirks_mode`) to diagnose a Rails/json-gem version incompatibility.
- Pasted browser console screenshots (CORS errors, "Invalid hook call", TypeScript overload errors) directly, which let the assistant distinguish a real code bug from an environment/tooling issue (wrong working directory during `npm install`, Vite's dev-port auto-increment, a stale Vite transform cache) in each case, rather than guessing.
- Asked "if we are already using faker why do we need to seed data?" — a conceptual question about the difference between data *generation* and data *persistence*, answered before continuing rather than proceeding on a misunderstanding.

## What the assistant was asked to avoid
- Executing commands or making commits on my behalf — every step was proposed as commands/code for me to run myself.
- Skipping straight to a fix without identifying the actual root cause (used repeatedly during the environment/tooling issues, where the first hypothesis wasn't always right).
