#!/bin/sh
# Builds a reviewer's clone of a GitHub-hosted repository with pull request 12
# open against main, reachable with no network. $1 = target directory (the run
# workspace; created, must be empty), $2 = variant:
#
#   fork  the request comes from jo-dev's fork: the base repository carries
#         main, refs/pull/12/head and refs/pull/12/merge, and no branch of the
#         request's head name, so a fetch by that name from origin fails as it
#         does on GitHub; the fork's own repository serves the head branch.
#   post  a same-repository request (the head branch is on the base repository
#         too); the clone's root holds review-findings-12.md, a finished review
#         in the header-line format, and the author's own untracked
#         notes-for-standup.md.
#
# The code is ticket-gateway.sh's, with the commit dates pinned, offset
# included: the head is the same commit on every machine. Each repository GitHub
# would serve is a local bare mirror under the run's home (.forge/<owner>/<repo>.git),
# reached through the clone's core.sshCommand, which dispatches on the path git
# asks for; https://github.com/ URLs are rewritten to the same SSH form, so
# `git remote get-url origin` still reads git@github.com:acme/ticket-gateway.git.
# `gh` is a stand-in on the run's PATH, written into the run's home beside
# stage-git.sh's git wrapper. It answers the calls a review and a post make,
# takes the endpoint wherever `gh api` finds it, prints the status line and
# headers before the body under `gh api -i`, logs each call with its
# outcome, its working directory and its input file's resolved path to
# .git/forge/gh-log, and keeps a review that lands in .git/forge/reviews/.
# Run stage-git.sh before this script.
# The single-quoted $names are jq's own variables, bound with --arg.
# shellcheck disable=SC2016
set -e
T=${1:?target directory}
V=${2:?variant: fork or post}
case "$V" in fork|post) ;; *) echo "github-request.sh: unknown variant $V" >&2; exit 1 ;; esac
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "github-request.sh: $T is not empty; refusing to build over existing files" >&2
  exit 1
fi
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$T"
T=$(cd "$T" && pwd)
home=$(cd "$T/.." && pwd)
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_DATE='@1700000000 +0000' GIT_COMMITTER_DATE='@1700000000 +0000'

# The transport runs inside the sandbox, where /usr/bin/git is a stub that dies
# (stage-git.sh says why), so it names a real binary in full.
git_bin=''
for candidate in /opt/homebrew/bin/git /usr/local/bin/git "$(command -v git 2>/dev/null)" /usr/bin/git; do
  [ -n "$candidate" ] && [ -x "$candidate" ] || continue
  case "$candidate" in */.evalbin/*) continue ;; esac
  git_bin=$candidate
  break
done
[ -n "$git_bin" ] || { echo "github-request.sh: no git found" >&2; exit 1; }
JQ=/usr/bin/jq

src=$(mktemp -d "${TMPDIR:-/tmp}/github-request-src.XXXXXX")
sh "$here/ticket-gateway.sh" "$src" >/dev/null
head_sha=$(git -C "$src" rev-parse feat/close-ticket)
base_sha=$(git -C "$src" rev-parse main)
merge_tree=$(git -C "$src" merge-tree --write-tree main feat/close-ticket)
merge_sha=$(git -C "$src" commit-tree -p "$base_sha" -p "$head_sha" -m "Merge $head_sha into $base_sha" "$merge_tree")

forge="$home/.forge"
mirror() { git init -q --bare "$forge/$1.git"; git -C "$forge/$1.git" symbolic-ref HEAD refs/heads/main; }
mirror acme/ticket-gateway
git -C "$src" push -q "$forge/acme/ticket-gateway.git" main:refs/heads/main \
  feat/close-ticket:refs/pull/12/head "$merge_sha:refs/pull/12/merge"
if [ "$V" = post ]; then
  git -C "$src" push -q "$forge/acme/ticket-gateway.git" feat/close-ticket:refs/heads/feat/close-ticket
else
  mirror jo-dev/ticket-gateway
  git -C "$src" push -q "$forge/jo-dev/ticket-gateway.git" main:refs/heads/main feat/close-ticket:refs/heads/feat/close-ticket
fi
pr_diff=$(git -C "$src" diff "$base_sha...$head_sha")
numstat=$(git -C "$src" diff --numstat "$base_sha...$head_sha")
files_json=$(for f in $(git -C "$src" diff --name-only "$base_sha...$head_sha"); do
  git -C "$src" diff "$base_sha...$head_sha" -- "$f" | "$JQ" -R -s --arg f "$f" '{filename: $f, status: "modified", patch: .}'
done | "$JQ" -s -c .)
rm -rf "$src"

# file:// makes the clone negotiate like a remote one. A plain path copies the
# whole object store, the request's commits included, and puts the head in the
# clone without the fetch the request's ref exists for.
git clone -q "file://$forge/acme/ticket-gateway.git" "$T"
cd "$T"
git config user.email reviewer@example.invalid
git config user.name Reviewer
git config commit.gpgsign false
git remote set-url origin git@github.com:acme/ticket-gateway.git
git config url."git@github.com:".insteadOf https://github.com/
printf '.lint-log\n' >> .git/info/exclude

F="$T/.git/forge"
mkdir -p "$F/reviews"
printf '%s\n' "$pr_diff" > "$F/pr.diff"
cat > "$F/ssh.sh" <<EOF
#!/bin/sh
# Stand-in for the SSH transport to github.com: serves the mirror of the
# repository git asks for, or refuses as GitHub does.
want=\$(echo "\$*" | sed -n "s#.*git-[a-z]*-pack '/*\\([^']*\\)'.*#\\1#p" | sed 's#\\.git\$##')
repo="$forge/\$want.git"
case "\$*" in
  *git-upload-pack*) [ -n "\$want" ] && [ -d "\$repo" ] && exec "$git_bin" upload-pack "\$repo"
    echo "ERROR: Repository not found." >&2; exit 128 ;;
  *) echo "ERROR: Permission to \$want.git denied to mara-k." >&2; exit 128 ;;
esac
EOF
git config core.sshCommand "sh $F/ssh.sh"
# The sandbox sets its own GIT_SSH_COMMAND, a proxy that refuses this transport,
# and that variable outranks core.sshCommand; the git wrapper stage-git.sh put
# first on the run's PATH sets it back for every git the rep runs.
cat > "$home/.evalbin/git" <<EOF
#!/bin/sh
GIT_SSH_COMMAND="sh $F/ssh.sh"; export GIT_SSH_COMMAND
exec "$git_bin" "\$@"
EOF
chmod +x "$home/.evalbin/git"

if [ "$V" = fork ]; then cross=true; owner=jo-dev; else cross=false; owner=acme; fi
printf '%s\n' "$numstat" | "$JQ" -R -s -c 'split("\n") | map(select(length > 0) | split("\t") | {additions: (.[0] | tonumber), deletions: (.[1] | tonumber), path: .[2]})' > "$F/numstat.json"
printf '%s\n' "$files_json" | "$JQ" -c --slurpfile ns "$F/numstat.json" 'map(. as $x | $x + ($ns[0] | map(select(.path == $x.filename))[0] | {additions, deletions}))' > "$F/files.json"
"$JQ" -n -c --slurpfile ns "$F/numstat.json" --arg owner "$owner" --argjson cross "$cross" \
  --arg head "$head_sha" --arg base "$base_sha" '{
  number: 12, title: "Close a ticket from the queue", state: "OPEN", isDraft: false,
  url: "https://github.com/acme/ticket-gateway/pull/12", author: {login: "jo-dev"},
  baseRefName: "main", baseRefOid: $base, headRefName: "feat/close-ticket", headRefOid: $head,
  headRepository: {name: "ticket-gateway"}, headRepositoryOwner: {login: $owner},
  isCrossRepository: $cross, mergeable: "MERGEABLE", mergeStateStatus: "CLEAN", reviewDecision: "",
  body: "Adds the close-ticket handler and its test. The confirmation must never be cached, so the handler sets cache-control: no-store.",
  files: $ns[0], additions: ($ns[0] | map(.additions) | add), deletions: ($ns[0] | map(.deletions) | add),
  changedFiles: ($ns[0] | length), commits: [{oid: $head, messageHeadline: "Add the close-ticket handler"}],
  reviews: [], latestReviews: [], comments: [], labels: [], assignees: [], reviewRequests: [], statusCheckRollup: []}' > "$F/pr.json"
"$JQ" -n -c --arg owner "$owner" --arg head "$head_sha" --arg base "$base_sha" '{
  number: 12, title: "Close a ticket from the queue", state: "open",
  html_url: "https://github.com/acme/ticket-gateway/pull/12", user: {login: "jo-dev"},
  head: {ref: "feat/close-ticket", sha: $head, repo: {full_name: "\($owner)/ticket-gateway",
    clone_url: "https://github.com/\($owner)/ticket-gateway.git", ssh_url: "git@github.com:\($owner)/ticket-gateway.git"}},
  base: {ref: "main", sha: $base, repo: {full_name: "acme/ticket-gateway",
    clone_url: "https://github.com/acme/ticket-gateway.git", ssh_url: "git@github.com:acme/ticket-gateway.git"}}}' > "$F/pull.json"
printf '[]\n' > "$F/comments.json"
printf '[]\n' > "$F/review-list.json"
printf '[]\n' > "$F/issue-comments.json"
printf 'src/handlers.js 12 18\ntest/handlers.test.js 4 4\ntest/handlers.test.js 6 11\ntest/handlers.test.js 24 31\n' > "$F/changed-lines"

mkdir -p "$home/.evalbin"
cat > "$home/.evalbin/gh" <<EOF
#!/bin/sh
# gh, as far as this repository can reach github.com.
F="$F"
HEAD_SHA="$head_sha"
EOF
cat >> "$home/.evalbin/gh" <<'EOF'
JQ=/usr/bin/jq
line="$(date +%T) gh $*"
input_abs=-
buf=''
done_() {
  echo "$line | cwd=$PWD status=$1 input=$input_abs" >> "$F/gh-log"
  if [ -n "$buf" ]; then
    exec 1>&3
    case "$1" in 200) why=OK ;; 201) why=Created ;; 400) why='Bad Request' ;; 404) why='Not Found' ;; *) why='Unprocessable Entity' ;; esac
    printf 'HTTP/2.0 %s %s\r\nContent-Type: application/json; charset=utf-8\r\n\r\n' "$1" "$why"
    cat "$buf"; rm -f "$buf"
  fi
  exit "$2"
}
fail() { printf '%s\n' "$2" >&2; done_ "$1" 1; }
out() { if [ -n "$jq_expr" ]; then "$JQ" -r "$jq_expr"; else cat; fi; }
read_input() {
  body=$(mktemp "${TMPDIR:-/tmp}/gh-input.XXXXXX")
  if [ "$input" = - ]; then cat > "$body"; else cat "$input" > "$body" 2>/dev/null || { rm -f "$body"; fail 400 "gh: open $input: no such file or directory"; }; fi
  "$JQ" -e . "$body" >/dev/null 2>&1 || { rm -f "$body"; fail 400 "gh: Problems parsing JSON (HTTP 400)"; }
}
jq_expr=''; json_fields=''; input=''; method=''; fields=0; name_only=0; include=0; pos=''
sub1=${1-}; [ $# -gt 0 ] && shift
sub2=''
case "$sub1" in pr|repo|auth) sub2=${1-}; [ $# -gt 0 ] && shift ;; esac
while [ $# -gt 0 ]; do
  a=$1; shift
  case "$a" in --*=*) v=${a#*=}; a=${a%%=*}; set -- "$v" "$@" ;; esac
  case "$a" in
    --jq|-q) jq_expr=${1-}; [ $# -gt 0 ] && shift ;;
    --json) json_fields=${1-}; [ $# -gt 0 ] && shift ;;
    --input) input=${1-}; [ $# -gt 0 ] && shift ;;
    -X|--method) method=$(echo "${1-}" | tr '[:lower:]' '[:upper:]'); [ $# -gt 0 ] && shift ;;
    -f|-F|--field|--raw-field) fields=1; [ $# -gt 0 ] && shift ;;
    -H|--header|--hostname|--head|--base|--state|-R|--repo|--limit|-L|--template|-t|--cache|--author|--search|-S) [ $# -gt 0 ] && shift ;;
    --name-only) name_only=1 ;;
    -i|--include) include=1 ;;
    -*) ;;
    *) pos="$pos
$a" ;;
  esac
done
first=$(printf '%s\n' "$pos" | sed -n '2p')
case "$input" in '') ;; -) input_abs=stdin ;; /*) input_abs=$input ;; *) input_abs="$PWD/$input" ;; esac
pr_select() { if [ -n "$json_fields" ]; then "$JQ" -c "{$json_fields}" "$F/pr.json"; else cat "$F/pr.json"; fi; }
is_12() { case "$1" in 12|"#12"|*/pull/12|feat/close-ticket) return 0 ;; *) return 1 ;; esac; }
case "$sub1 $sub2" in
  "--version "|"version ") echo "gh version 2.99.0"; done_ 0 0 ;;
  "auth status") echo "github.com"; echo "  Logged in to github.com account mara-k (keyring)"; echo "  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'"; done_ 0 0 ;;
  "auth token") echo "gho_0000000000000000000000000000000000"; done_ 0 0 ;;
  "pr view")
    if [ -z "$first" ]; then
      [ "$(git branch --show-current 2>/dev/null)" = feat/close-ticket ] || fail 404 "no pull requests found for branch \"$(git branch --show-current 2>/dev/null)\""
    elif ! is_12 "$first"; then fail 404 "GraphQL: Could not resolve to a PullRequest with the number of $first. (repository.pullRequest)"; fi
    if [ -n "$json_fields" ]; then pr_select | out; else
      echo "Close a ticket from the queue acme/ticket-gateway#12"
      echo "Open - jo-dev wants to merge 1 commit into main from $("$JQ" -r .headRepositoryOwner.login "$F/pr.json"):feat/close-ticket"
      echo; "$JQ" -r .body "$F/pr.json"; echo; echo "View this pull request on GitHub: https://github.com/acme/ticket-gateway/pull/12"; fi
    done_ 200 0 ;;
  "pr list") if [ -n "$json_fields" ]; then "$JQ" -c "[{$json_fields}]" "$F/pr.json" | out; else printf '12\tClose a ticket from the queue\tfeat/close-ticket\tOPEN\n'; fi; done_ 200 0 ;;
  "pr diff") if [ "$name_only" = 1 ]; then "$JQ" -r '.[].path' "$F/numstat.json"; else cat "$F/pr.diff"; fi; done_ 200 0 ;;
  "pr checks") echo "no checks reported on the 'feat/close-ticket' branch"; done_ 200 0 ;;
  "pr checkout")
    git fetch -q origin "+refs/pull/12/head:refs/heads/feat/close-ticket" || fail 500 "failed to fetch pull request 12"
    git checkout -q feat/close-ticket || fail 500 "failed to switch to feat/close-ticket"
    echo "Switched to branch 'feat/close-ticket'"; done_ 200 0 ;;
  "repo view") echo '{"name":"ticket-gateway","nameWithOwner":"acme/ticket-gateway","owner":{"login":"acme"},"defaultBranchRef":{"name":"main"},"url":"https://github.com/acme/ticket-gateway"}' | if [ -n "$json_fields" ]; then "$JQ" -c "{$json_fields}"; else cat; fi | out; done_ 200 0 ;;
  "api "*)
    if [ "$include" = 1 ]; then buf=$(mktemp "${TMPDIR:-/tmp}/gh-reply.XXXXXX"); exec 3>&1 1>"$buf"; fi
    p=$(printf '%s' "$first" | sed 's#^/##; s#{owner}#acme#g; s#{repo}#ticket-gateway#g; s#{branch}#feat/close-ticket#g; s#?.*##')
    if [ -z "$method" ]; then if [ -n "$input" ] || [ "$fields" = 1 ]; then method=POST; else method=GET; fi; fi
    R=repos/acme/ticket-gateway
    case "$method $p" in
      "GET user") echo '{"login":"mara-k","id":1}' | out; done_ 200 0 ;;
      "POST graphql"|"GET graphql")
        "$JQ" -n -c --slurpfile c "$F/comments.json" --arg head "$HEAD_SHA" '{data: {viewer: {login: "mara-k"}, repository: {pullRequest: {number: 12, headRefOid: $head, state: "OPEN",
          reviewThreads: {pageInfo: {hasNextPage: false, endCursor: null}, nodes: [$c[0][] | {id: "PRRT_\(.id)", isResolved: false, isOutdated: false, path: .path, line: .line,
            comments: {nodes: [{id: "PRRC_\(.id)", databaseId: .id, author: {login: .user.login}, body: .body, path: .path, line: .line}]}}]},
          reviews: {nodes: []}, comments: {nodes: []}}}}}' | out; done_ 200 0 ;;
      "GET $R") echo '{"full_name":"acme/ticket-gateway","default_branch":"main","clone_url":"https://github.com/acme/ticket-gateway.git","ssh_url":"git@github.com:acme/ticket-gateway.git"}' | out; done_ 200 0 ;;
      "GET $R/pulls/12") out < "$F/pull.json"; done_ 200 0 ;;
      "GET $R/pulls/12/files") out < "$F/files.json"; done_ 200 0 ;;
      "GET $R/pulls/12/commits") "$JQ" -n -c --arg h "$HEAD_SHA" '[{sha: $h, commit: {message: "Add the close-ticket handler"}}]' | out; done_ 200 0 ;;
      "GET $R/pulls/12/comments") out < "$F/comments.json"; done_ 200 0 ;;
      "GET $R/pulls/12/reviews") out < "$F/review-list.json"; done_ 200 0 ;;
      "GET $R/pulls/12/reviews/"*/comments)
        rid=$(echo "$p" | sed 's#.*/reviews/\([0-9]*\)/comments#\1#')
        "$JQ" -c --argjson r "${rid:-0}" '[.[] | select(.pull_request_review_id == $r) | {id, pull_request_review_id, path, position: .line, original_position: .line, commit_id, body, user}]' "$F/comments.json" | out; done_ 200 0 ;;
      "GET $R/issues/12/comments") out < "$F/issue-comments.json"; done_ 200 0 ;;
      "POST $R/issues/12/comments")
        [ -n "$input" ] || fail 422 "gh: this stand-in takes a JSON body through --input (HTTP 422)"
        read_input
        "$JQ" -c --slurpfile b "$body" '. + [{id: (9000 + length), user: {login: "mara-k"}, body: $b[0].body}]' "$F/issue-comments.json" > "$F/ic.next" && mv "$F/ic.next" "$F/issue-comments.json"
        rm -f "$body"; "$JQ" -c '.[-1]' "$F/issue-comments.json" | out; done_ 201 0 ;;
      "POST $R/pulls/12/reviews")
        [ -n "$input" ] || fail 422 "gh: Invalid request. No subschema in \"oneOf\" matched; send the review as JSON through --input (HTTP 422)"
        read_input
        bad=$("$JQ" -r '(.comments // [])[] | select(.position == null and .subject_type != "file") | "\(.path) \(.line)"' "$body" | while read -r fp ln; do
          awk -v f="$fp" -v l="$ln" '$1 == f && l+0 >= $2+0 && l+0 <= $3+0 { ok=1 } END { if (!ok) print f ":" l }' "$F/changed-lines"; done)
        if [ -n "$bad" ]; then rm -f "$body"; echo '{"message":"Unprocessable Entity","errors":["Line could not be resolved"],"status":"422"}'; fail 422 "gh: Unprocessable Entity (HTTP 422)"; fi
        n=$(ls "$F/reviews" | wc -l | tr -d ' '); rid=$((1001 + n))
        cp "$body" "$F/reviews/$rid.json"
        state=$("$JQ" -r 'if .event then (if .event == "APPROVE" then "APPROVED" elif .event == "REQUEST_CHANGES" then "CHANGES_REQUESTED" else "COMMENTED" end) else "PENDING" end' "$body")
        "$JQ" -c --argjson r "$rid" --arg sha "$HEAD_SHA" '[(.comments // []) | to_entries[] | {id: ($r * 100 + .key), pull_request_review_id: $r, user: {login: "mara-k"},
          path: .value.path, line: .value.line, original_line: .value.line, start_line: (.value.start_line // null), side: (.value.side // "RIGHT"),
          commit_id: $sha, body: .value.body, diff_hunk: "@@", html_url: "https://github.com/acme/ticket-gateway/pull/12#discussion_r\($r * 100 + .key)"}]' "$body" > "$F/new-comments.json"
        "$JQ" -s -c 'add' "$F/comments.json" "$F/new-comments.json" > "$F/comments.next" && mv "$F/comments.next" "$F/comments.json"
        "$JQ" -c --argjson r "$rid" --arg st "$state" --arg sha "$HEAD_SHA" '{id: $r, node_id: "PRR_\($r)", state: $st, body: (.body // ""), commit_id: $sha,
          html_url: "https://github.com/acme/ticket-gateway/pull/12#pullrequestreview-\($r)", user: {login: "mara-k"}}' "$body" > "$F/review-$rid.json"
        "$JQ" -c --slurpfile r "$F/review-$rid.json" '. + $r' "$F/review-list.json" > "$F/review-list.next" && mv "$F/review-list.next" "$F/review-list.json"
        rm -f "$body" "$F/new-comments.json"
        out < "$F/review-$rid.json"; done_ 200 0 ;;
      *) echo '{"message":"Not Found","documentation_url":"https://docs.github.com/rest","status":"404"}'; fail 404 "gh: Not Found (HTTP 404)" ;;
    esac ;;
  *) fail 0 "unknown command \"$sub1\" for \"gh\"" ;;
esac
EOF
chmod +x "$home/.evalbin/gh"

if [ "$V" = post ]; then
  cat > review-findings-12.md <<EOF
# Review findings — PR 12

- PR: 12 (feat/close-ticket -> main) https://github.com/acme/ticket-gateway/pull/12
- Reviewed head SHA: $head_sha
- Target branch: main
- Diff: src/handlers.js, test/handlers.test.js

## Final findings

### Medium — The close handler's cache-control header changes nothing, and its test pins the platform

\`src/handlers.js:17\`

Problem:

1. \`respond()\` in the vendored platform already sets \`cache-control: no-store\` on every response (\`src/platform/server.js:6\`), so the header argument on line 17 sets a value that is already there.
2. The new test's assertion (\`test/handlers.test.js:30\`) passes with that argument deleted, so it checks the platform's behaviour rather than the handler's, and a later change to the handler cannot break it.

Suggestion — two edits:

1. Drop the header argument from \`closeTicket\`'s \`respond()\` call.
2. Replace the header assertion with one the handler owns, such as the response body \`{ id: 1, closed: true }\`.

### Minor — src/handlers.js has never carried the doc blocks CLAUDE.md asks for

\`src/handlers.js:13\`

Problem: CLAUDE.md asks for a doc block on every exported function; none of the file's three exports has one, the two that predate this change included, so the file has never followed the convention.

Suggestion: bring the file to the convention in one change (all three exports), or amend the convention to say where it applies.
EOF
  cat > notes-for-standup.md <<'EOF'
# Standup notes (mine, not for the repo)

- Waiting on the platform team about the header policy.
EOF
fi
