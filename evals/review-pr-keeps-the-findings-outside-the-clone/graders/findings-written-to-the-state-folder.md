---
type: tool_used
tool: Write
input_match: "\"file_path\"\\s*:\\s*\"/[^\"]*/\\.local/state/delivery-skills/review-pr/git\\.example\\.org/acme/ticket-gateway/branch-feat-close-ticket/r1-[0-9a-f]{7}\\.md\""
min: 1
---

The findings go to one folder outside the clone, keyed by the remote's host and path lowercased (`git@git.example.org:Acme/Ticket-Gateway.git` keys as `git.example.org/acme/ticket-gateway`), then by the branch, since no request exists, then by round and reviewed commit. The run is granted the Write tool under `~/.local/state`, so a rep that follows the rule writes there with it. A `file_exists` grader cannot see outside the workspace (task 69's second probe), so this grades the write call, and the file itself is read by hand from the kept run's home. A rep that writes the file with the shell instead fails here and passes the Bash companion; read the two together.
