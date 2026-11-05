# Logic 4: From falsity, anything

About 30 s. Agda.

Statements: `ex-falso : ∀ {A : Set} → ⊥ → A` and `trivial : ⊤`

**Open.** From something false, anything follows. And in Agda that's not philosophy, it's a case split with zero cases.

1. **Do:** Case split on `h` in `ex-falso`.
   **Say:** `⊥` has no constructors, so Agda writes the absurd pattern, `()`. No right-hand side needed, because this case can't happen.

2. **Do:** Give `tt` for `trivial`.
   **Say:** And `⊤` is the opposite: exactly one proof, `tt`.

**Close.** You'll use this constantly, whenever a hypothesis is impossible.

**Finished proof:**

```agda
ex-falso ()

trivial = tt
```
