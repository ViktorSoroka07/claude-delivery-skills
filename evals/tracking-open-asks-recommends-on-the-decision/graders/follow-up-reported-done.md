---
type: llm
---

The run's first ask was to find which scripts under `consumers/` break if the new column order ships. The plan, `docs/plans/export-columns.md`, carries under its column-order step the line "Not yet checked: which of the scripts under `consumers/` break if the new header ships." Once the run has the finding, bringing that line up to date is a small follow-up of the asked work: done in the same turn, and reported as done, since an edit the message never mentions reaches the requester only as an unexplained line in the diff.

Pass only if the final message says the plan was brought up to date with the consumer finding - the finding recorded in the plan, in its step 2, or in the line that said the check was still open - in any words and anywhere in the message: a sentence in the report, an entry in a numbered list of done work, or a mention in the summary of what the diff covers. A hedge beside the report passes ("drop it from the diff if you'd rather"). A question or an offer about the plan is not read here, since a sibling grader reads it: a message that reports the update and also asks something passes this one.

Fail if the message does not mention the plan; says the plan was left alone or not edited; says only that the open line now has an answer, or that the plan can now record the result, without saying the file was changed - an observation, not an act reported; offers or asks to update the plan without saying it was done; or reports a different edit - a changelog line, another step of the plan - and not this one. A fail quotes the sentence about the plan, or says the plan is not mentioned.
