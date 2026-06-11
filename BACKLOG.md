# Questboard Backlog

Use this file to collect bugs, fixes, polish, and feature ideas.

Items are grouped by estimated implementation/research effort in **tokens**, not wall-clock time.

## How to use

- Put each item in the bucket that best matches the expected total work.
- Prefer moving items between buckets as we learn more instead of over-explaining upfront.
- Keep entries short: one title, one problem/opportunity line, and optional notes.
- Prefix items with a status marker:
  - `[ ]` not started
  - `[-]` in progress
  - `[x]` done and ready to move into `CHANGES.md` or release notes

## Item template

```md
- [ ] Short title
  Type: bug | feature | polish | tech debt
  Why: one sentence on the problem or value
  Notes: optional constraints, affected files, or acceptance notes
```

## Tiny: `< 2k` tokens

Small copy changes, simple styling tweaks, one-file bug fixes, tiny config updates.

## Small: `2k - 8k` tokens

Contained UI improvements, focused bug fixes, simple logic changes, minor persistence or API work.

## Medium: `8k - 25k` tokens

Multi-file features, non-trivial state changes, migrations, moderate gameplay/system work, deeper testing.

## Large: `25k - 75k` tokens

Cross-cutting features, major UX flows, complex refactors, meaningful data-model changes, substantial QA.

## Epic: `75k+` tokens

Big initiatives that likely need design decisions, phased rollout, or breaking the work into multiple tickets.

## Parking Lot

Ideas worth remembering but still too vague to size confidently.

