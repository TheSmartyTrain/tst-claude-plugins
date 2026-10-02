---
name: retire
description: Retire a TST tool, page, prototype or client site safely, deleting the data it holds and keeping old links working for a while. Use when someone says a tool is no longer needed, an engagement has ended, "take this down", "delete the old version", "we've moved it to tst.network", or when a prototype has passed its 90-day review date. Covers the data, the links, the functions and route rules, and the record.
---

# Retire a tool

Retiring a tool well means three things: the data it collected is deleted (or returned to the client), people with old links aren't left with a broken page, and nothing it used, such as functions, route rules, settings or credentials, is left running. Most of the people you talk to are not software engineers.

## Rules for the whole conversation

- **Ask one question at a time.** Use plain English, say "TST", write in British English and never use em-dashes.
- **Don't delete anything until step 3.** Deleting data is the one step that can't be undone, so it needs a person's explicit "yes" with the details in front of them.

## Step 1: What is being retired

1. Find the tool's folder, its `brief.md` and its intake issue, if they exist.
2. List everything that belongs to it:
   - **pages:** the folder, plus any copies elsewhere (search for its name)
   - **API functions:** in ProductionSite, `api/<name>*` and anything its pages `fetch('/api/...')`
   - **route rules:** in `staticwebapp.config.json`
   - **data stores:**
     - Postgres tables (its `schema.sql`, its `*_DB_URL`)
     - Firebase paths (its project ID and the paths its code writes)
     - Blob containers
   - **app settings and credentials** only it uses: setting names in its function code that no other function reads
   - **links to it** from other pages (`git grep -n "<folder name>"`)
3. Show the person the list and ask whether anything is missing.

## Step 2: The data

For each data store, ask:
1. Is any of this a client's data? If so, the contract decides: it may have to be returned to the client, not just deleted. Flag it for Sam Green and stop until he confirms what the contract requires.
2. Does anyone still need any of it (a final report, an export the client asked for)? If yes, who will hold the export, where, and until when?
3. Is there a promise in the tool's privacy notice about deletion? Follow it.

Write the answers into a short **retirement note** at the top of the tool's `brief.md`, or a new `retirement.md` if there's no brief: what was retired, when, what data existed, and what happened to each part.

## Step 3: Do it, in this order

1. **Redirect old links.** Add a 301 redirect in `staticwebapp.config.json` from the old path to wherever the person should now go: a replacement tool, a short "this has closed" page, or the home page. Keep it for at least 90 days, or 12 months for anything clients used. In ProductionSite, a route with a space in it uses a literal space, never `%20` (see its CLAUDE.md).
2. **Remove the code:** the folder, its API functions, and its route rules (apart from the redirect).
3. **Data.** Only with the person's explicit "yes" for each store, and only for data that step 2 cleared:
   - **Postgres:** write the `DROP TABLE` or `DELETE` statements into the PR description for a person to run by hand. Never run SQL against a production database yourself.
   - **Firebase:** list the paths to remove and ask the project owner to delete them in the console, or with the cleanup script pattern in `tools/hive-firebase/`.
   - **Blob storage:** the container name, for the owner to delete.
4. **Settings and credentials** only this tool used: list them in the PR description for the Static Web App owner to delete, and the issuer to revoke.
5. **Open a draft pull request** with the retirement note and the checklist. Comment on the intake issue with a link, and close it once the PR merges.

## Things to watch for

- **Shared code.** A function or file another tool also uses must stay. Search before removing anything.
- **Moved, not retired.** If the tool moved to tst.network, the redirect points there, and the data may be moving rather than being deleted. Check `docs/migration-to-tst-internal.md` in ProductionSite.
- **History.** Removing a file from the repository doesn't remove it from git history. If the tool held personal data in files, say so in the retirement note: history clean-up is a Development Authority decision.
