---
id: suc-times
index: 3
title: "suc-*"
learning_goals:
  - "An inductive step that needs a rearrangement lemma from the inventory."
  - "Sections on the right: `(_+ x)`."
unlocks:
  lemmas:
    - name: "suc-*"
      agda: "suc-*"
      lean: "succ_mul"
hints:
  - text: "**Case split** on `y` and read the `suc` clause's **Goal**: `suc (suc x * y + x) ≡ suc (x * y + x + y)`. Both sides start with `suc`, so `cong suc` gets you inside. Inside, `suc x * y` is what the recursive call talks about."
  - text: "Under `cong suc`, the recursive call becomes `cong (_+ x) (suc-* x y)`, which leaves `x * y + y + x ≡ x * y + x + y`. Those are the same three terms in a different order, and you have a lemma for that."
  - text: "`suc-* x zero = refl`, and `suc-* x (suc y) = cong suc (trans (cong (_+ x) (suc-* x y)) (+-right-comm (x * y) y x))`."
---
`suc x * y ≡ x * y + y`. Multiplying by one more means adding one more copy of `y`.
It's the partner of `suc-+`, and you will need it for commutativity in the next
level.

**Case split** on `y` and read the **Goal** in the `suc` clause. This goal is the
longest so far, so go through it in order:

1. Both sides begin with `suc`. Take that off first.
2. On the left, there is a `suc x * y` inside a sum. The recursive call tells you
   what that equals, but it only says so about `suc x * y` on its own. Use a section
   to apply it inside the sum: `(_+ x)` means `λ w → w + x`.
3. After that, compare the two sides. This is the first inductive step where the
   induction hypothesis isn't enough: the two sides are the same sum in a different
   order.

Nesting `trans` and `cong` gets confusing here, so feel free to write the inner part
as a `begin` block in parentheses. `≡-Reasoning` is already open in this level.

<!-- @conclusion -->
This is what most inductive steps in arithmetic look like: use the hypothesis, then
rearrange. `begin` blocks earn their keep from here on.
