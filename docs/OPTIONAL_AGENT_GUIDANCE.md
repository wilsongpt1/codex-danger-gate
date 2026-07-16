# Optional Agent Guidance

This optional `AGENTS.md` snippet asks Codex to request a separate confirmation before destructive actions that may not reach Danger Gate. It is a behavioral safeguard, not enforcement: an Agent can misunderstand or fail to follow prompt guidance, and the text cannot create a missing `PreToolUse` event.

The plugin does not install or modify global or project-level `AGENTS.md` files. Users may add this snippet themselves at the scope they choose.

```markdown
Before any destructive or irreversible action, state its target and material
effect and obtain the user's explicit, action-specific confirmation. This
applies to every tool route; sandbox approval is not confirmation. If the
target or material effect changes, confirm again.
```

Use `~/.codex/AGENTS.md` for a personal default across repositories, or a repository `AGENTS.md` for project-specific use. More specific project guidance can take precedence, so do not rely on this text as a security boundary.

The snippet is intentionally short and follows OpenAI's [GPT-5.6 prompting guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6): keep true safety invariants, define the approval boundary once, and avoid repeated process instructions. See [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) for instruction discovery and scope.
