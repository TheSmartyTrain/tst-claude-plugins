# tst-claude-plugins

TST's shared Claude Code plugins, published as the `tst-tools` marketplace. Owned by the Development Authority; every change is a reviewed pull request, because a change here reaches every Claude user at TST.

## tst-build

| Piece | What it does | Status |
|---|---|---|
| `/tst-build:new-tool` | The intake conversation: understand, look around, data and risk, decide tier and home, hand off with `brief.md` and an intake issue | v0.1 |
| `scripts/check-path.sh` | Blocks new paths with spaces and non-kebab-case top-level folders | Built; **off** until stage 2 |
| `scripts/check-personal-data.js` | Blocks writing content that looks like real personal data | Built; **off** until stage 2 |
| `templates/github/ISSUE_TEMPLATE/new-tool.yml` | The intake issue form, copied into each code repository | Ready to copy |

The hooks ship as `hooks.example.json`. Stage 2 (step 4.8 of `docs/governance/implementation-plan.md` in tst-internal) renames it to `hooks/hooks.json` after a week of local testing; from then on every user sees a one-time approval prompt for them.

## Install for yourself

```bash
claude plugin marketplace add TheSmartyTrain/tst-claude-plugins
claude plugin install tst-build@tst-tools
```

Organisation-wide installation is through Claude's managed settings (step 4.6). Never put a secret, a client name or any personal data in this repository.
