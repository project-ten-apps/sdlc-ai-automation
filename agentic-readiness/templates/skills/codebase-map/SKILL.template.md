---
name: codebase-map
description: Use after large changes in {{PROJECT_NAME}} to rebuild the codebase knowledge graph with graphify and refresh the module map in AGENTS.md.
---

# Codebase map (graphify)

Output in {{DOC_LANGUAGE}}; summary in {{CHAT_LANGUAGE}}. {{COMMIT_RULE}}
The map is built with graphify; never hand-write the graph.

## When

After a feature or refactor that adds or moves modules, screens, APIs or data models; or when `graphify-out/` is older than the last big merge.

## Steps

1. Run graphify on the repository root (as a skill, `/graphify .` or `/graphify . --update`, or via its CLI). Output goes to `graphify-out/` (gitignored or excluded). Exclude build outputs, caches, generated code and secret files. Check graphify usage via Context7 or its README if unsure.
2. Read `graphify-out/GRAPH_REPORT.md`: modules, key classes, dependencies, hot spots (high fan-in/fan-out), cycles.
3. Update AGENTS.md: module map, where things live, key flows, commands, conventions. Keep it short; link to `GRAPH_REPORT.md` for detail.
4. Compare with the previous report; list notable changes (new modules, new cycles, growing hot spots) as tech-debt notes.
5. Report: what changed in the map, what was updated in AGENTS.md, risks spotted.

## Rules

- Never put secrets or full keys into the map or AGENTS.md.
- If graphify is unavailable, say so and stop; do not substitute a hand-written graph.
