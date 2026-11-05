# Tutorial 8: sym and trans

About 45 s. Agda.

Statement: `flip-chain : ∀ {x y z : ℕ} → y ≡ x → y ≡ z → x ≡ z`

**Open.** Two more lemmas, and a small exercise in reading types. The question is just which equation goes where.

1. **Do:** Show `sym` and `trans` in the inventory.
   **Say:** `sym` flips an equation. `trans` chains two when the middle matches.

2. **Do:** Read `p` and `q` in the context.
   **Say:** I have `y ≡ x` and `y ≡ z`. I want `x ≡ z`. So `p` points the wrong way.

3. **Do:** Refine with `trans`, filling `sym p` and `q`.
   **Say:** Flip `p` to get `x ≡ y`, then chain it with `q`. Refine opens a hole per argument.

**Close.** Long chains of `trans` get unreadable fast. Next world has notation for exactly that.

**Finished proof:**

```agda
flip-chain p q = trans (sym p) q
```
