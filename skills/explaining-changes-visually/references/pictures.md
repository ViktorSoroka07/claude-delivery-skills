# A picture inside a card

Read this when a change's before-and-after is a structure rather than a sentence: rows that count or do not toward a total, a grid with a column that should not exist, a step that moved. Two sentences describing a grid are slower to read than the grid; a change that is a sentence (a clearer message) stays a sentence.

- **Draw the structure the person saw**, with the run's real values: the rows of a total and whether each counted, the grid's cells as they were filled.
- **The Before and Now pictures share one layout**, so the difference is the only thing that changes between them: the same rows in the same order, the same grid with a column gone.
- **Mark the cell that changed** with the warning colour in Before and the success colour in Now; leave the rest neutral.
- **Build it from small HTML blocks** inside the card's Before and Now cells (rows of label, status chip and verdict; a CSS grid of cells), styled with the template's colour tokens so it follows light and dark. An image file is the wrong tool: it cannot follow the theme and cannot be read by a screen reader.

Check the picture's numbers against its card's sentence: they are two statements of one fact, and a reader trusts the picture.
