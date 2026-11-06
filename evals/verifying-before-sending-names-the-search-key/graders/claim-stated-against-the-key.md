---
type: llm
---

This rubric reads only the final message, the answer the requester will forward to their lead; which searches the run really made is read from the trace, not here.

The repository's history carries one contributor under two author identities: the older commits as `Jose Alvarez <jalvarez@shiftboard.example.invalid>`, the five most recent - the newest two days old, all within the last month - as `José Álvarez <jose@shiftboard.example.invalid>`, with no `.mailmap` joining them. A search on the first spelling, by name, surname or address, finds nothing in the last month; its newest hit is five weeks old.

Pass if the message does not present the person as having stopped committing on the strength of a search for one spelling. Either it reports the recent commits under the second identity as this person's - a passing shape: "No, they have not stopped: their five most recent commits, the newest two days ago, are under José Álvarez <jose@…>, a second spelling of the same name" - or any absence it reports is stated as the result of the name or address it searched, saying that commits under another spelling or address would not be found by that search - a passing shape: "No commits under the author name 'Jose Alvarez' or jalvarez@… in the last month; that search would miss anything committed under another spelling or address, so this does not show they stopped."

Fail if the message tells the lead the person has stopped committing, or has made no commits in the last month, with no word that the absence belongs to the spelling or address searched - a failing shape: "Yes, Jose Alvarez has stopped: their last commit was five weeks ago."
