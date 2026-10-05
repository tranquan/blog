---
name: q-research
description: Research a topic end to end and write a cited draft article for this knowledge base. Use when the user says "q-research", "/q-research <topic>", or asks to research, investigate or deep-dive a topic (e.g. "research how to build agentic AI"). Runs without asking for approval; keeps working files in .ai-workspace/ and writes the article to draft/.
---

# q-research

Research a topic, then write one draft article with a last-updated date and a source link on every paragraph that uses a source. Run all steps without stopping for approval. Only ask the user something if the topic is too vague to plan (e.g. a single word with several unrelated meanings).

## Step 0: Set up

1. Get today's date with `date +%F`. Use it as "today" in searches and in the article. Don't rely on your training cutoff for what is current.
2. Make a kebab-case slug from the topic (e.g. `how-to-build-agentic-ai`).
3. The workspace is `.ai-workspace/research/<slug>/`. If it already exists, read what's there and continue from it instead of starting over.

## Step 1: Plan

Write `plan.md` in the workspace:

- **Goal:** what the reader should understand or be able to do after reading.
- **Reader:** assume a software engineer who is new to this topic, unless the user said otherwise.
- **Diátaxis type:** pick the main one. Use explanation for "why" or "how it works", how-to for "how do I", reference for comparisons and lists, tutorial for learning by doing. One article may mix types, but give it one main type.
- **Sub-questions:** 3 to 5 that together answer the topic. Make each one specific enough to search for.
- **Effort:** a narrow question gets 1 to 2 sub-questions and no subagents (research it yourself). A broad topic gets 3 to 5 sub-questions with one subagent each.

## Step 2: Research

For a broad topic, start all subagents in a single message so they run at the same time. Use `subagent_type: "general-purpose"`, which has web search and web fetch. Give each one a full brief, because it can't see this conversation:

```
Research only. Write one file, nothing else.
Topic: <topic>. Today is <date>.
Your sub-question: <sub-question>
Why it matters: <how it fits the article goal>
Search broad first, then narrow. Prefer official docs, specs, papers, source repos, and
write-ups by the people who built the thing. Use Context7 for library and framework docs.
Read each page you cite. Never cite a page you didn't open.
Write your findings to <absolute workspace path>/findings-<n>.md in the format below.
Return only a 3-line summary and the file path.
```

Each findings file uses this format, one block per claim:

```markdown
## <Claim in one sentence>
- Source: [<page title>](<url>)
- Tier: 1 | 2 | 3
- Published/updated: <date if shown, else "unknown">
- Quote: "<short exact text copied from the page, 5 to 15 words>"
- Notes: <context, caveats, disagreements>
```

Source tiers:
- **Tier 1:** official docs, specs, papers, source code, the maker's own engineering blog.
- **Tier 2:** well-known practitioners, conference talks, reputable publications.
- **Tier 3:** forums, aggregator posts, unsigned content. Use only to point toward Tier 1 or 2 sources, or mark the claim as weakly supported.

## Step 3: Merge and check gaps

1. Read all findings files. Write `sources.md` with every source used, its tier, and its date.
2. Write `gaps.md` listing:
   - sub-questions with no Tier 1 or Tier 2 source
   - claims where sources disagree
   - information that may be out of date (older than about 12 months, for fast-moving topics)
3. If there are serious gaps, run one more research round for those only. Don't do more than one extra round.

## Step 4: Write the article

Write `draft/<slug>.md`. Never write to `content/`; the user moves drafts there by hand.

```markdown
---
tags:
  - <tag>
---

# <Title>

*Last updated: <YYYY-MM-DD>*

<Intro: what this covers and who it's for, in 2 to 3 sentences.>

## <Section>

<Paragraph that uses a source.> ([<Source title>](<url>#:~:text=<encoded quote>))

...

## Sources

- [<Source title>](<url>) — <one line on what it covers>
```

Rules:
- **Last updated line:** right below the H1, using today's date. If you revise an existing draft later, change this date.
- **Paragraph links:** every paragraph that states facts from a source, or builds on a source's idea, ends with a link to that source. If a paragraph uses several sources, link each one. Paragraphs that are only your own synthesis or transitions don't need a link.
- **Deep links:** point each link at the exact passage using a URL text fragment: `<url>#:~:text=<quote>`. Take the quote from the `Quote:` line in the findings, keep it to 4 to 10 words, and percent-encode it (space `%20`, comma `%2C`, hyphen `%2D`, ampersand `%26`). If the page has a heading anchor near the passage (e.g. `#memory`), use that instead when you have no exact quote. If you have neither, link to the plain URL.
- **Structure:** follow the Diátaxis type from the plan. Explanation uses concepts, reasons and trade-offs. How-to uses numbered steps toward one goal. Reference uses tables and lists. Tutorial uses a guided path with a working result.
- **Honesty:** say where sources disagree or where support is weak. Don't present Tier 3 claims as settled.
- Put a "Sources" list at the end with every linked source.

## Step 5: Verify

Before reporting back, check that:
- every link in the article appears in `sources.md`, and every source was actually opened during research
- each linked paragraph says what its source says (compare against the findings file)
- the "Last updated" line is present and uses today's date

Fix anything that fails.

## Step 6: Report

Tell the user, in a few lines:
- the draft path
- the number of sources, and how many are Tier 1
- the main gaps or disagreements that remain
- the workspace path, if they want the raw findings
