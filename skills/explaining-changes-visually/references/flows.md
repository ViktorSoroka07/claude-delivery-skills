# A flow that changes by case

Read this when the same request plays out differently by case: before and after the change, or the cases the change distinguishes (one part times out, one part is missing). A paragraph per case makes the reader hold every case in mind to compare them; a flow that redraws keeps every part in place, so the only thing that moves is what changed.

## What it shows

- **A column per part** the request passes through, the person's screen first.
- **An arrow per message** between parts, and **a note per decision** a part makes.
- **Colour carries the verdict:** the warning colour for a step that goes wrong or misleads, the success colour for what the change makes true, neutral for everything else. A part a case never reaches is dimmed.
- **A button per case** above the flow and **one caption per case** under the buttons, saying in a sentence what that case shows.

## Building it

The template's flow section holds the buttons, the caption and a data block; [`../seq.js`](../seq.js) draws from that data, so a page fills in data and never draws by hand. Paste `seq.js` into the script tag that asks for it.

- `SEQ_COLS`: one `{ id, name, sub }` per part. A label longer than about 18 characters overflows its box.
- `SEQ_CASES`: one entry per button, keyed by the button's `data-case`, each `{ cap, steps, dim }`. A step is an arrow `{ from, to, text, kind, res }` or a note `{ at, note, kind }`; `to` and `at` take one id or a list, `text` and `note` one line or a list of lines, `kind` is `"bad"` or `"ok"`, `res: true` draws a dashed reply, `dim` lists the columns the case greys out.
- Keep a case to the steps that differ plus the ones that set them up, about five or six; a long case reads as a log, not a story.

Click every button before handing the page over: each case draws, its caption changes, and no label leaves its box or column.
