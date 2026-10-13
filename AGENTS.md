# Aljam3 web application

Aljam3 serves Sharia students and Muslims generally. Improve daily reading, search and citation through consistency, simplicity, performance, accuracy, quality and accessibility. Compare real tasks with Shamela.com and Turath.io; don't assume another feature is inherently an improvement.

## Workflow and authority

- Read `mise.toml`, `bin/`, and `docs/automation.md` first. Use existing tasks and established patterns. Use simple English and resolve routine reversible choices from evidence; escalate material ambiguity or changed scope.
- Product automation follows `ieasybooks/aljam3-product`: CPO proposal → AliOsm's revision-bound approval → CTO → independent QA → CPO acceptance → CEO → delivery gate. Setup authorization is separate. An existing issue or a label is not product approval.
- Keep the approved issue, proposal revision and exact PR commits linked. Any scope change needs renewed owner approval; code/base changes need fresh role review. Agents may not change governance, grant themselves permissions, waive CI, merge directly or deploy from a workstation.
- Check official documentation when framework behavior is uncertain. Challenge the approach, test realistic failures, and review the final diff before reporting completion.

## Design and code

- Rails 8.1, Ruby 3.4.4, PostgreSQL, Meilisearch, Hotwire/Stimulus, Phlex and Tailwind 4 are the existing stack. Follow its conventions rather than importing MetalStraw's Vue/Inertia/Shards stack.
- Prefer simple, direct code, existing components and useful abstractions. Apply KISS, DRY, YAGNI, SOLID and test-first development where beneficial. Estimate a line budget and review material overruns.
- Keep controllers small and RESTful. Put domain rules with the domain; use services for orchestration, query objects for complex reads, and presentation logic in components. Check Active Record query count, indexes and realistic data volume.
- Follow existing colors, typography, spacing, icon and component patterns. Verify Arabic/RTL and mixed-direction strings, Urdu/English expansion, keyboard/focus, responsive layouts, themes and reduced motion where affected.
- Preserve exact quoted content, citations, edition/page metadata and attribution. Never silently normalize source text destructively. Scholarly/content changes require human review.
- `/api/v1` is consumed by installed desktop clients and external tools; preserve compatibility unless an approved migration explicitly covers those clients. Also consider the public MCP interface.

## Verification and isolated work

- Use a dedicated worktree. `mise run agent:setup` creates project-specific local services; `mise run agent:check` runs the non-mutating checks. The existing `mise lint` rewrites files and is not a verification command.
- Use `python3 bin/agent-workspace run …` for commands that touch databases/search. Never point a test, migration or reindex job at production or the developer's shared data. `agent:cleanup` removes only this workspace's Compose resources and preserves evidence files.
- Preserve the existing 100% line/branch coverage requirement. Write useful behavior/regression tests, reuse the existing FactoryBot/fixture conventions, and avoid pointless tests written solely for coverage. Treat tests as maintainable production code.
- QA covers correctness, security, performance, accessibility, localization, data integrity, regression, compatibility and experience. Use browser screenshots for UI work and measured baselines for performance claims. Explain anything not verified.
- Keep evidence and logs in ignored `tmp/agent-evidence/`, then attach durable, redacted summaries/artifacts to GitHub. Never expose secrets, user records or full copyrighted corpora.

## Scope, docs and PRs

- Fix the approved problem; propose unrelated refactoring separately. Favor codebase health over a workaround. Do not hard-wrap Markdown prose; keep comments minimal and useful.
- Commit/push/open PRs when explicitly requested or inside an owner-approved product cycle. Include the product issue and proposal revision, behavior change, validation, screenshots and rollout/rollback notes as relevant. Link every opened PR to T3 immediately.
- Propose repeated-mistake guidance through a reviewed governance PR. Don't silently relax these rules or product policy.

General guidance adapted from `milkstraw/MetalStraw/AGENTS.md` for this repository's stack and the owner's authorized automation workflow.
