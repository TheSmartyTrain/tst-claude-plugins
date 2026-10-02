---
name: promote
description: Move a TST prototype out of prototypes/ (or raise any tool's tier) so it can use real data, a data store, an /api function or an outside service. Use when someone says their prototype is ready for real users or real data, wants to "make it live", "connect it to the database", "add a survey that saves answers", "use Claude/OpenAI/ElevenLabs in it", or when ProductionSite's check-inline-data.js fails with "Prototypes may not store data or call outside services". Walks through what the higher tier needs, opens the approval issue, and only then moves the code.
---

# Promote a tool to a higher tier

A prototype may hold no real personal data and call nothing outside the browser (decision D10). Promoting it is the stage gate: the point at which TST decides a tool may handle real data, and what it must have in place first. You are walking the person through that gate. Most of the people you talk to are not software engineers.

## Rules for the whole conversation

- **Ask one question at a time.** Use plain English, and say "TST", never "The Smarty Train". Write in British English and never use em-dashes.
- **Don't move or change any code until step 4 says you can.** The approval comes first.
- **Never put real personal data in any file,** in the repository or anywhere else. Use synthetic examples.

## Where you are running

If you can't run commands or see a copy of the repository (Claude chat on the web, desktop or phone), do steps 1 to 3 as normal, reading the brief and intake issue through the GitHub connector or asking the person to paste them. In step 4, open the promotion issue with the GitHub connector if it can; otherwise give the person the text and the link. **Then stop.** Moving the code needs someone with Claude Code once the label is on; say so.

## Step 1: Find the tool and its record

1. Find the tool's folder and its `brief.md`. In ProductionSite a prototype is `prototypes/<slug>/`.
2. Find its intake issue. Search the repository's issues for `Intake: <name>` or the `intake` label (`gh issue list --label intake --state all`).
3. Read both, and tell the person in two sentences what the brief says the tool is for.

If there is no `brief.md`, run the `new-tool` conversation (`/tst-build:new-tool` in Claude Code) first and come back.

## Step 2: What changes

Ask, one at a time. Skip any the brief already answers and that the person confirms are still true.

1. What will it now do that it doesn't today? (Save answers, show people's names, call an AI, email people...)
2. Exactly which details about people will it collect or show? Push for the least that does the job.
3. Is it for a client? If so, are we doing this **for** the client with their people's information (TST is the *processor*), or for TST's own purposes (TST is the *controller*)?
4. How long does each kind of information need to be kept, and what happens to it then?
5. Which outside services will see it? (Anthropic, OpenAI, ElevenLabs, Firebase, HubSpot, DeepL...)
6. Could it involve health, disability or reasonable adjustments, ethnicity, religion, sexuality, trade union membership, children, salary or HR records?

## Step 3: Decide the new tier and what it needs

Use the same table as the `new-tool` skill.

| Tier | When | Approval |
|---|---|---|
| **1, internal** | TST staff only | One Development Authority member |
| **2, client-facing** | Clients, the public, or anyone outside TST | One member; **Sam Green must approve** if a client's people's data is involved |
| **3, high risk** | Any answer to step 2 question 6 is yes, or AI processes people's personal data, or a client contract restricts the data | Two members; Sam Green must be one if client data is involved; a DPIA is needed |

Then list what the new tier needs before go-live, as a checklist the person can follow.

- **Tier 1:**
  - lives in tst-internal, not ProductionSite
  - follows that repository's standard access shape (`docs/platform/access-control-redesign.md` §12)
- **Tier 2:**
  - a privacy notice on the page that collects anything (the ECO survey's notice is the model)
  - a retention period for each kind of data
  - a deletion job that enforces it
  - every outside service named in the notice
  - every `/api` function gated, or deliberately carved out as anonymous with a reason
- **Tier 3:** everything in tier 2, plus:
  - a DPIA
  - sensitive fields kept apart and every read of them logged
  - Sam Green's confirmation that the client contract covers the processing

Tell the person the tier, why, and the checklist. Ask if anything you've assumed is wrong.

## Step 4: Ask for approval, then move

1. **Open a promotion issue** titled `Promote: <name> to tier <N>`, with the label `intake`. Use the body below, filled in. Use `gh issue create` or the GitHub tools you have; if neither works, give the person the text and the issue link.

   ```markdown
   Promotes <name> (intake issue #<n>) from <old tier> to tier <N>.

   ## What changes
   <step 2, question 1>

   ## Data
   - About people: <what>
   - Least needed: <what was trimmed>
   - Controller: <TST / the client, TST is processor>
   - Kept for: <period per kind of data, and why>
   - Outside services: <list>
   - High-risk categories: <list, or none>

   ## Before go-live
   <the checklist from step 3, as - [ ] items>
   ```

2. **Tell the person who must approve it.** Approval is a Development Authority member adding the `approved:tier-<N>` label.

3. **Only once that label is on the issue:** move the code out of `prototypes/` to its new home (a kebab-case folder in ProductionSite, or a new tool in tst-internal), update `brief.md` with the new tier and a link to the promotion issue, and open a **draft** pull request that references the issue. The checklist items go in the PR description; tick only what the PR actually does. Never push to `main`.

If the person wants to go ahead before approval, explain that the prototype rule in ProductionSite's CI will fail the build anyway, and offer to draft the privacy notice, the retention period or the DPIA screening while they wait.
