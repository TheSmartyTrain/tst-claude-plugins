# tst-claude-plugins

TST's shared Claude Code plugins, published as the `tst-tools` marketplace. Owned by the Development Authority; every change is a reviewed pull request, because a change here reaches every Claude user at TST.

## tst-build

| Piece | What it does | Status |
|---|---|---|
| `/tst-build:new-tool` | The intake conversation: understand, look around, data and risk, decide tier and home, hand off with `brief.md` and an intake issue | v0.2.1 |
| `/tst-build:promote` | The stage gate: move a prototype out of `prototypes/`, or raise a tool's tier, with the approval issue first and the code move after | v0.2 |
| `/tst-build:retire` | Retire a tool: redirect old links, remove code, functions and routes, and delete or return its data with a person's explicit yes | v0.2 |
| `scripts/check-path.sh` | Blocks new paths with spaces and non-kebab-case top-level folders | Built; **off** until stage 2 |
| `scripts/check-personal-data.js` | Blocks writing content that looks like real personal data | Built; **off** until stage 2 |
| `templates/github/ISSUE_TEMPLATE/new-tool.yml` | The intake issue form, copied into each code repository | Ready to copy |

The hooks ship as `hooks.example.json`. Stage 2 (step 4.8 of `docs/governance/implementation-plan.md` in tst-internal) renames it to `hooks/hooks.json` after a week of local testing; from then on every user sees a one-time approval prompt for them.

## Install for yourself

```bash
claude plugin marketplace add TheSmartyTrain/tst-claude-plugins
claude plugin install tst-build@tst-tools
```

Organisation-wide installation is through Claude's managed settings (step 4.6).

## The Claude app (web, desktop, phone and Cowork)

The same skills run in Claude chat and Cowork. There they can't run commands or see a copy of the repositories, so each skill says what to do instead: the conversation is the same, and it stops once the intake (or promotion) issue is open, for someone with Claude Code to build from. Hooks don't run in chat.

`bash tools/package.sh` writes the uploads to `dist/` (CI runs it on every pull request, so a broken package fails the check):

- **One zip per skill** (`tst-build-new-tool-<version>.zip` and so on), for Organization settings > Plugins & skills > Add. The skill upload takes exactly one `SKILL.md` per zip and refuses a plugin manifest, so the plugin can't go in this way as one file. Uploaded like this, the skills are `/new-tool`, `/promote` and `/retire`.
- **The whole plugin** (`tst-build-plugin-<version>.zip`), for the plugin upload, if it accepts it.

Before uploading, check Organization settings > Policy has both "Cloud code execution and file creation" and "Skills" on; skills don't load without code execution. An upload is a snapshot: after each release merged here, a Development Authority member uploads the new zips. Sources: [Provision skills for your organisation](https://support.claude.com/en/articles/13119606-provision-and-manage-skills-for-your-organization), [Use plugins in Claude](https://support.claude.com/en/articles/13837440-use-plugins-in-claude). Never put a secret, a client name or any personal data in this repository.
