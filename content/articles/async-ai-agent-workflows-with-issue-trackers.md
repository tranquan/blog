---
tags:
  - ai-agents
  - workflow
  - github
---

# Running AI coding agents through an issue tracker

*Last updated: 2026-10-06*

This guide shows how to work with AI coding agents the way you work with a teammate on GitHub, Linear or Jira. You assign a task, the agent works on its own, you review now and then, you leave comments, and it picks them up and continues. It is for software engineers who have used an agent in their editor but not yet asynchronously, and it covers which tools do this today, where task memory lives, how comments reach the agent, where to put review checkpoints, and whether to build or buy.

## The loop

Every setup in this guide follows the same loop:

1. **Assign:** you turn a task into an issue and hand it to the agent (assignee, label or `@mention`).
2. **Plan (optional):** the agent proposes a plan and you approve or correct it.
3. **Work:** the agent works on a branch, unattended, and records progress.
4. **Review:** the agent opens a pull request (PR) with evidence that it works. You review.
5. **Feedback:** you comment. The agent reads the comments, pushes fixes and reports back.
6. **Merge:** a human merges.

The ticket is the unit of work, and the thread on it (issue, PR or agent session) is where you and the agent talk. The steps below fill in each part.

## Step 1: Choose where the conversation lives

The tools differ less in *whether* they can take a ticket and more in *where* you steer them afterwards. On GitHub, Copilot treats the issue as a hand-off only: once it is assigned, it will ignore later issue comments, and the conversation moves to the PR. ([Using GitHub Copilot cloud agent on GitHub](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/use-cloud-agent-on-github#:~:text=Copilot%20will%20not%20be%20aware%20of%2C%20and%20therefore))

| Tool (name as of 2026-10-06) | How you assign | Where you steer it | What you get |
|---|---|---|---|
| GitHub Copilot cloud agent (formerly "coding agent") | Assign a GitHub issue to Copilot; also from Linear, Jira, Slack | `@copilot` comments on the **PR** | Draft PR; one PR per task |
| Claude Code GitHub Actions (`claude-code-action`) | `@claude` comment; optional assignee or label trigger | New `@claude` comments on the issue or PR | Commits on a `claude/` branch or the PR branch |
| Claude Code on the web | Prompt at claude.ai/code, CLI, mobile | The cloud session; auto-fix reacts to PR comments and CI | Branch, then a PR |
| Claude Agent for Jira (beta) | Assign or `@mention` on a Jira work item | New `@mention` starts a new session | Draft GitHub PR |
| Cursor Cloud Agents (formerly background agents) | Delegate a Linear issue; `@cursor` on GitHub issues/PRs, Slack | `@Cursor` comment or reply in the Linear agent session | PR created automatically |
| Devin | Assign in Linear or Jira, label, `@mention`; `/devin` on a PR | Linear agent session, Jira panel, or comments on its own PRs | PR linked on the ticket |
| Jira Coding Agent (Atlassian) | Assign a work item or "Start work" | Chat panel in the agent session (not plain comments) | Draft PR (optional) |
| OpenAI Codex | Assign or `@Codex` in Linear; `@codex` on GitHub PRs | Follow-up in the Linear thread; `@codex fix …` on a PR | Summary and a chat link you turn into a PR; fixes pushed to the PR branch |

Product names changed a lot in 2025–2026, so date any comparison you rely on. GitHub now calls its agent "Copilot cloud agent", which plans and implements changes in the background. ([GitHub Copilot on GitHub.com](https://docs.github.com/en/copilot/concepts/copilot-surfaces/copilot-on-github#:~:text=Copilot%20cloud%20agent%20can%20research%20a%20repository%2C%20plan%20changes)) Cursor renamed background agents to Cloud Agents, which work on their own branch and hand off by pushing. ([Cloud Agents - Cursor](https://cursor.com/docs/cloud-agent#:~:text=work%20on%20a%20separate%20branch%2C%20then%20push%20changes%20to%20your))

**GitHub-native.** Assigning an issue to Copilot gets you a draft PR and a review request when it finishes. ([Using GitHub Copilot cloud agent on GitHub](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/use-cloud-agent-on-github#:~:text=raise%20a%20pull%20request%2C%20then%20request%20a%20review%20from%20you)) With Claude Code GitHub Actions, you mention `@claude` in an issue or PR, and it can implement changes and push commits on your own Actions runners. ([Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions#:~:text=to%20have%20Claude%20analyze%20code%2C%20implement%20changes%2C%20and%20push%20commits)) The action can also start when an issue is assigned to a chosen user or gets a chosen label, which is the closest match to "assign the ticket to the agent". ([claude-code-action usage](https://github.com/anthropics/claude-code-action/blob/main/docs/usage.md#:~:text=The%20label%20name%20that%20triggers%20the%20action%20when%20applied))

**Linear-centred.** Linear treats agents as app users: assigning an issue to an agent *delegates* it, while a human stays the owner. ([Agents in Linear](https://linear.app/docs/agents-in-linear#:~:text=Assigning%20an%20issue%20to%20an%20agent%20delegates%20the%20issue%20to)) Cursor, Devin, Codex and Copilot all plug into this model. Cursor shows live status in Linear and opens a PR when done, ([Linear - Cursor Docs](https://cursor.com/docs/integrations/linear#:~:text=show%20real%2Dtime%20status%20in%20Linear%20and%20create%20PRs%20automatically)) and Devin takes extra instructions as messages in the Linear agent session. ([Linear - Devin Docs](https://docs.devin.ai/integrations/linear#:~:text=Send%20messages%20in%20the%20agent%20session%20thread%20to%20give%20Devin)) Codex is different: it continues the same chat when you reply in the thread, but it gives you a link to create the PR rather than opening it. ([Run Codex chats from Linear issues](https://learn.chatgpt.com/docs/third-party/linear#:~:text=follow%20up%20in%20the%20thread%20to%20continue%20the%20same%20chat.))

**Jira-centred.** Jira lets you assign work items to AI agents and trigger them as work moves through your workflow. ([Collaborate on work items with AI agents - Jira](https://support.atlassian.com/jira-software-cloud/docs/collaborate-on-work-items-with-ai-agents/#:~:text=trigger%20the%20agent%20as%20work%20moves%20through%20your%20workflow)) Its output stays private in an Agents section until you publish it as a comment, which differs from GitHub and Linear where agent activity is visible to everyone. ([Collaborate on work items with AI agents - Jira](https://support.atlassian.com/jira-software-cloud/docs/collaborate-on-work-items-with-ai-agents/#:~:text=provides%20an%20output%20for%20you%20to%20review%20in%20the%20Agents)) Atlassian's own Jira Coding Agent can always open a draft PR, but you iterate in its chat panel, not in ordinary comments. ([Generate code from a work item in Jira](https://support.atlassian.com/jira-software-cloud/docs/generate-code-from-a-work-item-in-jira/#:~:text=It%20will%20always%20create%20a%20draft%20pull%20request%20on%20your)) There is also a beta Claude Agent for Jira, built on Anthropic's Claude Managed Agents, that pushes changes and opens a draft PR. ([Set up Claude Agent for Jira](https://support.atlassian.com/jira-software-cloud/docs/set-up-claude-agent-for-jira/#:~:text=push%20changes%20to%20your%20GitHub%20repo%20and%20open%20a%20draft))

**How to choose:** if your team lives in GitHub, use Copilot or `claude-code-action` and treat the PR as the conversation. If your team plans in Linear, its agent sessions give the cleanest "comment on the ticket and the agent continues" experience, and you can pick the agent behind it. Jira works, but steering happens in side panels rather than the comment thread.

## Step 2: Write the issue as a prompt

The issue is the agent's prompt, so most of your effort should go there, not into watching the run. GitHub says its agent gives better results on clear, well-scoped tasks, and asks for a problem description, acceptance criteria and the files to change. ([Get the best results from Copilot cloud agent](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results#:~:text=provides%20better%20results%20when%20assigned%20clear%2C%20well%2Dscoped%20tasks.)) Anthropic's Claude Code guide says the same thing more bluntly. ([Best practices for Claude Code](https://code.claude.com/docs/en/best-practices#:~:text=Time%20spent%20making%20the%20spec%20precise%20pays%20off%20more%20than))

A good agent issue has:

- **The problem**, and why it matters.
- **Acceptance criteria**: what "done" looks like, including tests.
- **Where to look**: files, modules or interfaces to change.
- **Out of scope**: what not to touch.
- **How to verify**: the command, test or screenshot that proves it works.
- **Boundaries**: what the agent must always do, must ask about first, and must never do.

The last item comes from Addy Osmani, who suggests three tiers of rules, such as "always run tests before commits", "ask before adding new dependencies" and "never remove a failing test without approval". ([How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/#:~:text=review%20and%20refine%20the%20AI%E2%80%99s%20spec.)) The "ask first" tier gives you checkpoints you agreed in advance, so the agent stops at them instead of guessing.

Not every task should go to an agent. GitHub suggests starting with bugs, UI tweaks, tests, docs and tech debt, and keeping broad, ambiguous, security-sensitive and learning tasks with humans. ([Get the best results from Copilot cloud agent](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results#:~:text=Initially%2C%20you%20might%20want%20to%20start%20by%20giving%20Copilot%20simpler))

## Step 3: Put checkpoints where they pay off

You want to review "some of the time". The sources agree on two checkpoints: approve a plan before code is written, and review the PR before merge.

**The plan checkpoint.** Claude Code's recommended workflow separates exploring and planning from implementing, so you don't solve the wrong problem. ([Best practices for Claude Code](https://code.claude.com/docs/en/best-practices#:~:text=Separate%20research%20and%20planning%20from%20implementation%20to%20avoid%20solving)) In plan mode, edits stay blocked until you approve, and this still applies in headless and SDK runs, so you can use it as a gate in async setups. ([Choose a permission mode](https://code.claude.com/docs/en/permission-modes#:~:text=edits%20stay%20blocked%20until%20you%20approve%20the%20plan)) Copilot has a similar flow where you iterate on a plan and only then create a PR, ([Research, plan, and iterate with Copilot cloud agent](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/research-plan-iterate#:~:text=Review%20the%20plan%20and%20iterate%20with%20Copilot%20until%20it%20matches)) and OpenAI advises asking Codex to plan first when a task is complex or ambiguous. ([Codex best practices](https://learn.chatgpt.com/guides/best-practices#:~:text=ask%20Codex%20to%20plan%20before%20it%20starts%20coding.)) Skip the plan for small tasks. Anthropic's rule of thumb is short. ([Best practices for Claude Code](https://code.claude.com/docs/en/best-practices#:~:text=If%20you%20could%20describe%20the%20diff%20in%20one%20sentence%2C%20skip))

**The PR checkpoint.** This is the gate that can't be skipped. Copilot enforces it in the product: its draft PRs must be reviewed and merged by a human. ([Risks and mitigations for Copilot cloud agent](https://docs.github.com/en/copilot/concepts/security-governance-and-network-settings/risks-and-mitigations#:~:text=Draft%20pull%20requests%20created%20by%20Copilot%20cloud%20agent%20must)) Anthropic's guidance for agents in general is that human review stays crucial even when tests pass, and that agents should pause at checkpoints or blockers. ([Building effective agents](https://www.anthropic.com/engineering/building-effective-agents#:~:text=pause%20for%20human%20feedback%20at%20checkpoints%20or%20when%20encountering%20blockers.))

**What lets you look less often.** Two things.

1. **A check the agent can run itself.** With tests, a build or a screenshot to check against, the agent can fix its own mistakes. Without one, you become the loop. Anthropic calls this the difference between a session you watch and one you walk away from. ([Best practices for Claude Code](https://code.claude.com/docs/en/best-practices#:~:text=the%20difference%20between%20a%20session%20you%20watch%20and%20one)) Ask the agent to post the evidence (test output, screenshots) in the PR, since reviewing evidence is faster than re-running it.
2. **An AI first-pass review.** The longer an agent works alone, the more an independent check matters, for example a reviewer subagent with fresh context. ([Best practices for Claude Code](https://code.claude.com/docs/en/best-practices#:~:text=The%20longer%20Claude%20works%20unattended%2C%20the%20more%20an%20independent%20check)) Osmani puts it this way: use AI as the first-pass reviewer, not the final judge, and require tests or a demo on every PR. ([AI writes code faster. Your job is still to prove it works.](https://addyosmani.com/blog/code-review-ai/#:~:text=Use%20AI%20as%20first%2Dpass%20reviewer%2C%20not%20final%20arbiter.))

**How much autonomy that is.** In the five-level framework by Feng, McDonald and Zhang, this setup sits around levels 3 and 4: the agent plans and works over long stretches and comes back mainly for blockers. The authors stress that more autonomy is a design choice, not automatically better. ([Levels of Autonomy for AI Agents](https://knightcolumbia.org/content/levels-of-autonomy-for-ai-agents-1#:~:text=more%20autonomy%20does%20not%20simply%20mean%20a%20better%20agent.)) Anthropic's usage data points the same way: good oversight means being able to step in when it matters, not approving every action. ([Measuring AI agent autonomy in practice](https://www.anthropic.com/research/measuring-agent-autonomy#:~:text=Effective%20oversight%20of%20agents%20requires%20more%20than%20putting%20a%20human))

**Your real bottleneck is review.** Simon Willison notes that with parallel agents, review speed is the limit, and that code that started from your own spec is much cheaper to review. ([Embracing the parallel coding agent lifestyle](https://simonwillison.net/2025/Oct/5/parallel-coding-agents/#:~:text=Code%20that%20started%20from%20your%20own%20specification%20is%20a%20lot)) Keep tasks PR-sized. Copilot enforces this anyway: one PR per task and at most 59 minutes per session. ([About Copilot cloud agent](https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-cloud-agent#:~:text=Each%20Copilot%20cloud%20agent%20session%20has%20a%20maximum%20execution%20time))

## Step 4: Give each task its own memory

No product documents a "notes" field on the ticket itself. Instead, memory is split in two:

| Layer | What it holds | Where it lives |
|---|---|---|
| **Project memory** | Conventions, commands, architecture | `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, Cursor rules |
| **Task memory** | Plan, progress, decisions, open questions | The PR or issue thread, the agent session, or a per-task progress file on the branch |

**Project memory** is a set of files the agent reads at the start of every run. AGENTS.md is a tool-neutral version that many agents support. ([AGENTS.md](https://agents.md/#:~:text=Think%20of%20AGENTS.md%20as%20a%20README%20for%20agents)) Claude Code also keeps an auto memory that it writes itself, but both kinds are per project, and each session still starts with a fresh context. ([How Claude remembers your project](https://code.claude.com/docs/en/memory#:~:text=Each%20Claude%20Code%20session%20begins%20with%20a%20fresh%20context%20window.))

**Task memory** depends on the tool:

- **Copilot:** the PR is the memory. It remembers context from earlier sessions on the same PR, ([Asking Copilot to make changes to an existing pull request](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/make-changes-to-an-existing-pr#:~:text=Copilot%20remembers%20context%20from%20previous%20sessions%20on%20the%20same%20pull)) and every commit links to its session log.
- **Claude Code GitHub Actions:** Claude keeps one comment on the issue or PR and updates it as it works, with checkboxes for progress. ([Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions#:~:text=Claude%20replies%20in%20a%20comment%20on%20the%20same%20issue%20or)) ([anthropics/claude-code-action](https://github.com/anthropics/claude-code-action#:~:text=Visual%20progress%20indicators%20with%20checkboxes%20that%20dynamically%20update))
- **Linear:** the agent session on the issue holds the activity log, and Devin syncs its to-do list to Linear's plan view.

If you build your own setup, copy Anthropic's pattern for long-running agents. Keep a progress file plus git history, and have every session start by reading them. ([Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents#:~:text=Read%20the%20git%20logs%20and%20progress%20files%20to%20get%20up)) End each session in a clean state, so the next session, or you, can pick it up. ([Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents#:~:text=leaving%20the%20environment%20in%20a%20clean%20state%20at%20the%20end)) Keep the task checklist in JSON rather than Markdown, because the model is less likely to overwrite it carelessly. ([Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents#:~:text=less%20likely%20to%20inappropriately%20change%20or%20overwrite%20JSON%20files)) Anthropic calls this "structured note-taking": notes written outside the context window and read back later. ([Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents#:~:text=the%20agent%20regularly%20writes%20notes%20persisted%20to%20memory%20outside)) The Claude API's memory tool does this as a file store you control, so you can map it to one folder per issue. ([Memory tool - Claude API](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool#:~:text=Claude%20automatically%20checks%20its%20memory%20directory%20before%20starting%20a))

A practical layout for a self-built setup: one branch per issue, and on it a `.agent/notes/<issue>.md` progress log and a `.agent/tasks/<issue>.json` checklist. Plus the thread itself. The agent reads all three at the start of each run and updates them before it hands back.

## Step 5: Wire the feedback loop

This is the part that surprises people. In most setups the agent does **not** pick up exactly where it stopped. Each comment starts a new run, which rebuilds its context from the thread and the branch.

**How Claude Code GitHub Actions does it.** The reference workflow listens to issue comments, PR review comments, issue events (opened, assigned, labeled) and submitted reviews. Every new run fetches the whole PR or issue, including comments. ([claude-code-action usage](https://github.com/anthropics/claude-code-action/blob/main/docs/usage.md#:~:text=Claude%20will%20see%20the%20full%20PR%20context%2C%20including%20any%20comments.)) It doesn't resume the earlier session in memory. The action does output a session ID for `--resume`, but on fresh CI runners the session files are gone, because headless sessions are stored on the machine. ([Run Claude Code programmatically](https://code.claude.com/docs/en/headless#:~:text=with%20a%20session%20ID%20to%20continue%20a%20specific%20conversation)) So the thread and the branch are your memory.

Watch for these four limits:

1. **Comments added during a run are skipped.** The action drops comments made after the trigger, to block content injected after an authorised request. ([claude-code-action fetcher.ts](https://github.com/anthropics/claude-code-action/blob/main/src/github/data/fetcher.ts#:~:text=Filters%20comments%20to%20only%20include%20those%20that%20existed%20in%20their)) Mention `@claude` again to start a new run.
2. **Bot comments don't wake it.** Events created with the workflow's own `GITHUB_TOKEN` don't start new workflow runs, so another workflow can't post "@claude" to chain runs unless it uses an app token. ([claude-code-action FAQ](https://github.com/anthropics/claude-code-action/blob/main/docs/faq.md#:~:text=cannot%20trigger%20subsequent%20GitHub%20Actions%20workflows))
3. **New workflows only fire from the default branch.** An `issue_comment` workflow does nothing until it is merged to `main`. ([Events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#:~:text=This%20event%20will%20only%20trigger%20a%20workflow%20run%20if%20the))
4. **Concurrency choices drop or race runs.** With no concurrency group, two quick comments start two runs that may fight over one branch. With a group, GitHub keeps at most one run pending and cancels older pending runs, so a comment can be lost. ([Control the concurrency of workflows and jobs](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency#:~:text=there%20can%20be%20at%20most%20one%20running%20job%20or%20workflow)) Pick one deliberately. A group per issue or PR is usually right, as long as people batch their comments.

**How Copilot does it.** Each `@copilot` comment on the PR starts a new session, which carries over context from earlier sessions on that PR. ([Asking Copilot to make changes to an existing pull request](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/make-changes-to-an-existing-pr#:~:text=Copilot%20remembers%20context%20from%20previous%20sessions%20on%20the%20same%20pull)) Only people with write access are heard. ([Asking Copilot to make changes to an existing pull request](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/make-changes-to-an-existing-pr#:~:text=Copilot%20only%20responds%20to%20comments%20from%20people%20who%20have%20write)) Batch your review: Copilot starts on each comment as soon as you submit it, so use "Start a review" rather than single comments. You can also send several review comments to it with "Add to batch". ([Asking Copilot to make changes to an existing pull request](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/make-changes-to-an-existing-pr#:~:text=To%20delegate%20multiple%20comments%2C%20click))

**How Linear does it.** Linear is the closest to a real resume. A follow-up from you arrives as a `prompted` webhook on the *same* agent session, and the agent is expected to add it to its existing history. ([Developing the Agent Interaction - Linear](https://linear.app/developers/agent-interaction#:~:text=A%20user%20sent%20a%20new%20message%20into%20an%20existing%20Agent)) The integrator has to keep that history, and Linear's deadlines are tight. Your webhook must answer within 5 seconds, so acknowledge at once and do the work in a queue. ([Developing the Agent Interaction - Linear](https://linear.app/developers/agent-interaction#:~:text=You%20must%20return%20a%20response%20from%20your%20webhook%20receiver%20within)) You can also send a stop signal to halt the agent mid-task. ([Signals - Linear](https://linear.app/developers/agent-signals#:~:text=The%20stop%20signal%20instructs%20the%20agent%20to%20halt%20work%20immediately.))

**Claude Code on the web** has an auto-fix mode that watches a PR and responds to CI failures and review comments. If a comment is ambiguous or architecturally significant, it asks you before acting. ([Use Claude Code in the cloud](https://code.claude.com/docs/en/claude-code-on-the-web#:~:text=Claude%20can%20watch%20a%20pull%20request%20and%20automatically%20respond%20to))

## Step 6: Lock it down

Issue and comment text is untrusted input, and an agent that reads it holds repo credentials. Simon Willison's "lethal trifecta" is the risk to keep in mind: private data, untrusted content and a way to send data out. ([The lethal trifecta for AI agents](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/#:~:text=Exposure%20to%20untrusted%20content)) It has happened: a malicious public GitHub issue hijacked an agent into leaking private repo data through a PR. ([GitHub MCP Exploited](https://invariantlabs.ai/blog/mcp-github-vulnerability#:~:text=agent%20via%20a%20malicious%20GitHub%20Issue))

The checklist:

- **Limit who can trigger the agent.** Both Copilot and `claude-code-action` accept only users with write access by default. ([claude-code-action security](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md#:~:text=The%20action%20can%20only%20be%20triggered%20by%20users%20with%20write)) Copilot goes further: comments from users without write access never reach the agent. ([Risks and mitigations for Copilot cloud agent](https://docs.github.com/en/copilot/concepts/security-governance-and-network-settings/risks-and-mitigations#:~:text=Comments%20from%20users%20without%20write%20access%20are%20never%20presented%20to)) Be careful with `claude-code-action`'s escape hatches. Allowed bots skip the permission check entirely. ([claude-code-action security](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md#:~:text=Allowed%20bots%20are%20not%20checked%20for%20repository%20permissions))
- **Limit network access.** Copilot has a default-on firewall, but it covers only commands the agent runs through its Bash tool. ([Customizing the firewall for Copilot cloud agent](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-the-firewall#:~:text=The%20firewall%20only%20applies%20to%20processes%20started%20by%20the%20agent)) `claude-code-action` has no built-in firewall, so set up Claude Code's sandbox with an allowlist of domains yourself. ([Sandboxing - Claude Code](https://code.claude.com/docs/en/sandboxing#:~:text=checks%20each%20host%20against%20your%20allowed%20domains))
- **Use short-lived tokens with least privilege.** Prefer a custom GitHub App over the shared official one if you want the smallest set of permissions. Store keys as secrets, give the workflow only the permissions it needs, and review before merging. ([Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions#:~:text=Grant%20the%20workflow%20only%20the%20permissions%20it%20needs%2C%20and%20review))
- **Make human review a platform rule, not a habit.** Copilot enforces draft PRs, blocks the requester from approving, and holds CI until a human approves. With `claude-code-action`, Claude doesn't open PRs on its own, ([claude-code-action security](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md#:~:text=Claude%20does%20not%20create%20pull%20requests%20automatically)) but its "own branch only, no force-push" limits are instructions in its system prompt, not platform controls. ([claude-code-action FAQ](https://github.com/anthropics/claude-code-action/blob/main/docs/faq.md)) Add branch protection and required reviews yourself.

## Build or adopt?

**Adopt** (Copilot, Cursor, Devin, Codex, Jira agents) if you want platform-enforced safety, a polished session UI and no infrastructure work. **Build** on Claude Code GitHub Actions if you want control over the prompt, the model and the memory layout, and are happy to own security.

Building it yourself is quick: run `/install-github-app`, or install the app, add a secret and copy the example workflow. Either way you need repo admin rights. ([Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions#:~:text=For%20either%20path%2C%20you%20need%20admin%20access%20to%20the%20repository)) You can sign in with an API key, or with an OAuth token from a Claude Pro, Max, Team or Enterprise plan. ([Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions#:~:text=available%20on%20Pro%2C%20Max%2C%20Team%2C%20and%20Enterprise%20plans)) Teams on Bedrock or Vertex can use OIDC instead. One catch: in private org repos you can't assign an issue to Claude, because it isn't an org member, so use a label trigger instead. ([claude-code-action FAQ](https://github.com/anthropics/claude-code-action/blob/main/docs/faq.md#:~:text=you%20can%20only%20assign%20to%20users%20in%20your%20own%20organization))

**Cost** (prices as of 2026-10-06; check before relying on them):

- **DIY:** each run uses GitHub Actions minutes plus model tokens, or your Claude subscription quota if you use OAuth. ([Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions#:~:text=Each%20run%20consumes%20two%20kinds%20of%20resources)) Actions minutes are free for public repos and self-hosted runners. ([GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions#:~:text=GitHub%20Actions%20usage%20is%20free%20for%20self%2Dhosted%20runners%20and)) Cap spend with `--max-turns`, job timeouts and concurrency limits.
- **Copilot:** moved to usage-based "AI credits" on 2026-06-01, and long agent sessions on frontier models cost more. ([Copilot usage-based billing for individuals](https://docs.github.com/en/copilot/concepts/billing-and-usage/individuals/billing#:~:text=A%20long%20Copilot%20cloud%20agent%20session%20using%20a%20frontier%20model)) Business is $19 per user per month with pooled credits. ([Copilot seats and billing cycles](https://docs.github.com/en/copilot/concepts/billing-and-usage/organizations-and-enterprises/seats-and-billing-cycles#:~:text=Copilot%20Business%20at%20%2419%20USD%20per%20user%20per%20month)) The cloud agent also uses Actions minutes, so you pay the same two costs as DIY, bundled.
- **Devin:** self-serve plans moved to quotas plus on-demand credits, while Enterprise is still billed in ACUs. ([Devin self-serve plans](https://docs.devin.ai/admin/billing/self-serve#:~:text=On%2Ddemand%20credits%20are%20the%20same%20dollar%20value%20as%20the))
- **Codex:** cloud features come with ChatGPT plans. API-key access has no GitHub cloud integration. ([Codex pricing](https://developers.openai.com/codex/pricing#:~:text=No%20cloud%2Dbased%20features%20%28GitHub%20code%20review%2C%20Slack%2C%20etc.%29))

## Where the evidence is thin

- **Pricing and product names change monthly.** Every claim above was checked on 2026-10-06. Several products have been renamed or marked "legacy" in the past year, including Codex's GitHub cloud chats.
- **Copilot's PR-description checklist** was described at launch in 2025, but today's docs only describe session logs. Don't depend on it.
- **`claude-code-action` permissions:** its docs say the official app asks for broad permissions, including workflows, while its FAQ says it lacks workflow write access. Use a custom app if this matters.
- **Rate limits:** none of the docs gave numbers for how often agents can be triggered.
- The autonomy-levels framework comes from an academic paper, not from tool makers, so treat it as a lens, not a standard.

## Sources

- [GitHub Copilot on GitHub.com](https://docs.github.com/en/copilot/concepts/copilot-surfaces/copilot-on-github) — What Copilot cloud agent is and its surfaces
- [Using GitHub Copilot cloud agent on GitHub](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/use-cloud-agent-on-github) — Assigning issues to Copilot and how it reports back
- [Asking Copilot to make changes to an existing pull request](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/make-changes-to-an-existing-pr) — @copilot feedback, sessions, batching
- [About Copilot cloud agent](https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-cloud-agent) — Limits: session time, one PR per task
- [Get the best results from Copilot cloud agent](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results) — Writing issues for the agent; which tasks to give it
- [Research, plan, and iterate with Copilot cloud agent](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/research-plan-iterate) — Plan-first flow before a PR
- [Risks and mitigations for Copilot cloud agent](https://docs.github.com/en/copilot/concepts/security-governance-and-network-settings/risks-and-mitigations) — Platform-enforced review and trigger rules
- [Customizing the firewall for Copilot cloud agent](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-the-firewall) — Egress firewall scope
- [Copilot usage-based billing for individuals](https://docs.github.com/en/copilot/concepts/billing-and-usage/individuals/billing) — AI credits pricing
- [Copilot seats and billing cycles](https://docs.github.com/en/copilot/concepts/billing-and-usage/organizations-and-enterprises/seats-and-billing-cycles) — Business and Enterprise pricing
- [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions) — Actions minutes and free quotas
- [Events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows) — issue_comment and other event rules
- [Control the concurrency of workflows and jobs](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency) — Concurrency groups and cancelled pending runs
- [Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions) — Setup, auth, cost and security for claude-code-action
- [claude-code-action usage](https://github.com/anthropics/claude-code-action/blob/main/docs/usage.md) — Triggers, inputs and context
- [claude-code-action FAQ](https://github.com/anthropics/claude-code-action/blob/main/docs/faq.md) — Known limits and behaviours
- [claude-code-action security](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md) — Who can trigger, prompt injection, PR policy
- [claude-code-action fetcher.ts](https://github.com/anthropics/claude-code-action/blob/main/src/github/data/fetcher.ts) — How the action filters comments by trigger time
- [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action) — Project README
- [Use Claude Code in the cloud](https://code.claude.com/docs/en/claude-code-on-the-web) — Cloud sessions and PR auto-fix
- [Run Claude Code programmatically](https://code.claude.com/docs/en/headless) — Headless mode and session resume
- [How Claude remembers your project](https://code.claude.com/docs/en/memory) — CLAUDE.md and auto memory
- [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices) — Plan, verify, review guidance
- [Choose a permission mode](https://code.claude.com/docs/en/permission-modes) — Plan mode and autonomy modes
- [Sandboxing - Claude Code](https://code.claude.com/docs/en/sandboxing) — Network allowlists
- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — Progress files and clean handoffs
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — Structured note-taking
- [Memory tool - Claude API](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool) — File-based agent memory you control
- [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) — Checkpoints and human review for agents
- [Measuring AI agent autonomy in practice](https://www.anthropic.com/research/measuring-agent-autonomy) — How people oversee agents in practice
- [AGENTS.md](https://agents.md/) — Tool-neutral agent instructions file
- [Agents in Linear](https://linear.app/docs/agents-in-linear) — Delegating issues to agents
- [Developing the Agent Interaction - Linear](https://linear.app/developers/agent-interaction) — Agent sessions, webhooks, deadlines
- [Signals - Linear](https://linear.app/developers/agent-signals) — Stop and other signals
- [Cloud Agents - Cursor](https://cursor.com/docs/cloud-agent) — Cursor's async agents
- [Linear - Cursor Docs](https://cursor.com/docs/integrations/linear) — Delegating Linear issues to Cursor
- [Linear - Devin Docs](https://docs.devin.ai/integrations/linear) — Devin in Linear agent sessions
- [Devin self-serve plans](https://docs.devin.ai/admin/billing/self-serve) — Devin pricing model
- [Collaborate on work items with AI agents - Jira](https://support.atlassian.com/jira-software-cloud/docs/collaborate-on-work-items-with-ai-agents/) — Assigning and triggering agents in Jira
- [Generate code from a work item in Jira](https://support.atlassian.com/jira-software-cloud/docs/generate-code-from-a-work-item-in-jira/) — Jira Coding Agent
- [Set up Claude Agent for Jira](https://support.atlassian.com/jira-software-cloud/docs/set-up-claude-agent-for-jira/) — Claude in Jira (beta)
- [Run Codex chats from Linear issues](https://learn.chatgpt.com/docs/third-party/linear) — Codex in Linear
- [Codex best practices](https://learn.chatgpt.com/guides/best-practices) — Planning and AGENTS.md for Codex
- [Codex pricing](https://developers.openai.com/codex/pricing) — Codex plans and cloud features
- [Levels of Autonomy for AI Agents](https://knightcolumbia.org/content/levels-of-autonomy-for-ai-agents-1) — Five-level autonomy framework (Feng et al.)
- [Embracing the parallel coding agent lifestyle](https://simonwillison.net/2025/Oct/5/parallel-coding-agents/) — Review as the bottleneck
- [The lethal trifecta for AI agents](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/) — Prompt injection risk model
- [GitHub MCP Exploited](https://invariantlabs.ai/blog/mcp-github-vulnerability) — Real issue-based prompt injection attack
- [How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/) — Specs and boundaries for agents
- [AI writes code faster. Your job is still to prove it works.](https://addyosmani.com/blog/code-review-ai/) — Reviewing AI-written PRs
