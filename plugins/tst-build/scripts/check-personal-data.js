#!/usr/bin/env node
// PreToolUse hook for Write and Edit (stage 2; see hooks.example.json).
// Blocks writing content that looks like real personal data: more than five
// distinct non-placeholder email addresses, a UK mobile number, or a field name
// that only real records carry. The patterns follow ProductionSite's
// tools/check-inline-data.js, so a file this lets through also passes CI there.
// Exit 2 blocks the tool call and shows stderr to Claude.
let raw = '';
process.stdin.on('data', d => (raw += d)).on('end', () => {
  let input;
  try { input = JSON.parse(raw); } catch { process.exit(0); }
  const t = input.tool_input || {};
  const text = [t.content, t.new_string].filter(Boolean).join('\n');
  if (!text) process.exit(0);

  const PLACEHOLDER = /@(example\.(com|org|net)|test\.com|localhost)$|^(name|user|someone|you|first\.last|firstname\.lastname|noreply|no-reply)@/i;
  const emails = new Set(
    (text.match(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/g) || [])
      .map(e => e.toLowerCase())
      .filter(e => !PLACEHOLDER.test(e))
  );
  const mobile = /(?<![\d.])(?:\+44\s?7\d{3}|07\d{3})[\s-]?\d{6}(?!\d)/.test(text);
  const sensitive = /["']?(passport|ethnicity|reasonable_adjustments|national_insurance|ni_number|date_of_birth|dob|emergency_contact|home_address)["']?\s*[:=]/i.exec(text);

  const problems = [];
  if (emails.size > 5) problems.push(`${emails.size} distinct email addresses`);
  if (mobile) problems.push('a UK mobile number');
  if (sensitive) problems.push(`a "${sensitive[1]}" field`);
  if (!problems.length) process.exit(0);

  console.error(
    `TST standard: this looks like real personal data (${problems.join(', ')}). ` +
    'Real records never go into a file in git or a served page. Use synthetic examples ' +
    '(name@example.com, made-up names), or keep the data behind an authenticated API. ' +
    'If this really is synthetic, change the addresses to @example.com.'
  );
  process.exit(2);
});
