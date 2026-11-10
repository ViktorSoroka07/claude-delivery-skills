---
type: regex
target: last_message
pattern: "^\\|(?:[^|\\n]*\\|)*?[^|\\n]{41,}\\|"
flags: m
match: not_contains
---

A terminal draws a markdown table as a grid only while every row fits in four wrapped lines; one row that needs five turns the whole table into stacked label-value records, and a five-column closing table in a pane of about ninety columns gives each cell about fourteen. So no cell of any table in the final message holds more than forty characters, which keeps a row at three lines there. A message with no table passes with no cell read, so this row is read beside `waiting-items-in-a-numbered-table`.
