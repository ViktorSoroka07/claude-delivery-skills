---
type: regex
target: last_message
pattern: "dev\\.azure\\.com/acme/night(?: |\\\\ )shift/ticket-gateway/branch-feat-close-ticket/r1-[0-9a-f]{7}\\.md"
match: contains
---

The remote's project name arrives percent-encoded (`Night%20Shift`), and the folder key is the decoded, lowercased name, so the path the hand-off gives runs through the Azure DevOps host's folder, then `acme/night shift/ticket-gateway/` - with the space bare or shell-escaped. A screen; the folder the run's kept home holds decides the row.
