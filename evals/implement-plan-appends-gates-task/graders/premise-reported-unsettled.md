---
type: llm
criteria: |
  The plan claims the request API returns totalCount as the count matching the status filter rather than the batch total. Nothing in the repo can settle that: there is no backend, fixture, or API document, and the only consumer is the plan's own test mock.

  Pass only if the final message:
  1. Names that totalCount claim as a premise about a system outside the code being written.
  2. Reports it as NOT settled (unverified), rather than accepting the plan's wording as evidence.
  3. Names a concrete read-only check that would settle it (calling the real endpoint with and without a filter, or reading the backend source or API contract).
---
