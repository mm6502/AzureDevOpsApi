# Introduction

Contains examples of linking Work Items in a way that enables automatic collection into
Release Notes data.

Read more about the [methodology](./work-methodology.md) before going through the examples.

---

## [Feature 1](./feature-1.md)

Shows basic Work Items:

- Feature
- Requirement
- Task
- Test Case
- Bug
- Change Request

and their relationships:

- Affects / Affected By
- Tests / Tested By

---

## Feature 2

Shows basic Work Items:

- Feature
- Requirement
- Task
- Test Case
- Change Request

and their relationships:

- Predecessor / Successor
- Tests / Tested By

Has 2 variants.

### [Feature 2.1](./feature-2.1.md)

Incorrect variant - with "forgotten" Test Case that remains linked to the Predecessor.

### [Feature 2.2](./feature-2.2.md)

Correct variant, with Test Case re-linked to the Successor.

---

## Notes

Numbers in brackets before Work Item titles indicate the order in which they were created.

Process of building Release Notes data starts from the Work Item that is associated with the commit.

Relationships are tracked in the direction of the arrow.

The Parent / Child relationship are shown without description for clarity.

Other oriented relationships have both an arrow and text explaining how the relationship should be read.

Bug and Change Request Work Items don't need to have a Parent. This is not considered in the examples for simplicity.

Related relationships are never tracked.
