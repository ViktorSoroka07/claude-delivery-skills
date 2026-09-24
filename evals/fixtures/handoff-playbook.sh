#!/bin/sh
# Builds the eval fixture for maintaining-project-memory's landing sweep: a
# small team-playbook repository whose handoff skill owns a list - what a
# hand-over note carries, three items - and whose three other files each
# enumerate the same three: the skill's own checklist further down, the
# README's line on the skill, and CLAUDE.md's short form, the copy every
# session loads first. The case's prompt adds a fourth item and names only the
# owner section, so every other copy a run leaves alone reads as complete
# while wrong.
#
# None of the four copies uses a word for undoing a change (roll back, revert,
# undo, back out): the case's fourth item is the rollback, and its graders
# read those words as the item landed.
# $1 = target directory (created; must not exist or be empty).
# $2 = variant, optional: "unnamed" writes CLAUDE.md's short form naming the
#      subject only as the note you leave when work changes hands, with no
#      "hand-over", no "handoff" and no path, so a search for the subject's
#      name misses it and only one for the old items' own words reaches it.
#
# Invented content throughout - a team and a service that never existed.
set -e
T=${1:?target directory}
V=${2:-}
case "$V" in
  ''|unnamed) ;;
  *) echo "handoff-playbook.sh: unknown variant '$V'" >&2; exit 1 ;;
esac
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "handoff-playbook.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/skills/handoff" "$T/skills/standup" "$T/skills/incident-notes"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > README.md <<'EOF'
# team-playbook

How the ledger-sync team works: the skills our sessions load, and the
conventions every contributor follows.

## Skills

- **standup** - writes the daily update: what moved since yesterday, what is
  blocked, and what is next. See [skills/standup/SKILL.md](skills/standup/SKILL.md).
- **handoff** - writes the note you leave when work changes hands: what was
  done and where it landed, what is still open and who owns it, and how to
  check the current state. See [skills/handoff/SKILL.md](skills/handoff/SKILL.md).
- **incident-notes** - keeps the running log during an incident and turns it
  into the summary afterwards. See
  [skills/incident-notes/SKILL.md](skills/incident-notes/SKILL.md).

## Changing a skill

Open a pull request against `main`; one reviewer from the team approves it.
EOF

if [ "$V" = unnamed ]; then
cat > CLAUDE.md <<'EOF'
# Working in team-playbook

- Skills live under `skills/<name>/SKILL.md`; each owns its own rule, and a
  change to a rule is made there first.
- Keep every skill under 150 lines; a skill that grows past that is split.
- The note you leave when work changes hands carries what was done and where
  it landed, what is still open and who owns it, and how to check the current
  state.
- Dates in notes are absolute - the day, month and year - never "yesterday".
EOF
else
cat > CLAUDE.md <<'EOF'
# Working in team-playbook

- Skills live under `skills/<name>/SKILL.md`; each owns its own rule, and a
  change to a rule is made there first.
- Keep every skill under 150 lines; a skill that grows past that is split.
- Hand-over notes carry what was done and where it landed, what is still open
  and who owns it, and how to check the current state (full rule:
  `skills/handoff/SKILL.md`).
- Dates in notes are absolute - the day, month and year - never "yesterday".
EOF
fi

cat > skills/handoff/SKILL.md <<'EOF'
---
name: handoff
description: Use when work changes hands - leaving a task for a teammate, going on leave, ending a shift on a live migration - to write the note the next person starts from.
---

# Handoff

The next person has the note and nothing else: not your terminal, not your
memory of why. Write it so they can act on it without asking you.

## What a hand-over note carries

1. **What was done** - each change, and where it landed: the commit, the
   pull request, the deploy.
2. **What is still open** - every unfinished item, with who owns it now.
3. **How to check the current state** - the command or dashboard that shows
   it, and what healthy looks like.

## Writing it

- Lead with the state, not the story. The history of how you got here goes
  last, if at all.
- Name people and systems exactly. "The sync job" is three different jobs on
  this team.
- Date everything absolutely; the note is read days later.
- Put the note where the work lives: the ticket, or the pull request if there
  is no ticket.

## Before you send

- [ ] Every change is listed with where it landed.
- [ ] Every open item names its owner.
- [ ] The note says how to check the current state.
- [ ] Nothing in it needs you there to explain it.
EOF

cat > skills/standup/SKILL.md <<'EOF'
---
name: standup
description: Use when writing the daily standup update for the team channel.
---

# Standup

Three lines, in this order: what moved since yesterday, what is blocked and
on whom, what is next. Link the ticket for each line. Skip a line only when
it is empty, and say so ("nothing blocked").
EOF

cat > skills/incident-notes/SKILL.md <<'EOF'
---
name: incident-notes
description: Use during an incident to keep the running log, and after it to write the summary.
---

# Incident notes

During the incident, log each action with its time (UTC) and who took it,
one line each, in the incident channel's pinned thread. Afterwards, turn the
log into a summary: impact, timeline, cause, and the follow-up tickets.
EOF

git add -A
git commit -q -m "Start the team playbook with three skills"
echo "built handoff-playbook fixture in $T"
