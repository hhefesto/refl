# Tutorial 1: Meet in the middle

About 1 min 15 s. Agda.

Statement: `two-plus-two-by-hand : 2 + 2 ≡ 4`

**Open.** Two plus two is four. We're going to prove it by hand, because that shows you what the checker is doing every time you use it.

1. **Do:** Show the template and point at the two holes.
   **Say:** The left side walks down and the right side walks up. My job is to make them meet.

2. **Do:** Fill the first hole with `suc (suc 1 + 1)`.
   **Say:** Addition recurses on its second argument, so `suc 1 + suc 1` becomes `suc (suc 1 + 1)`. The `suc` moves outside.

3. **Do:** Fill the second hole with `suc (suc 2)`.
   **Say:** And four, walked up from the other end, is `suc (suc 2)`. Now the two ends read the same number.

4. **Do:** Press Check.
   **Say:** No errors. Every `≡⟨⟩` step needed no justification, because the checker can confirm each one by computing.

**Close.** That's the whole idea of the game: an equation is proved when both sides reach the same term. Next level, we make the checker do this walk for us.

**Finished proof:**

```agda
two-plus-two-by-hand =
  begin
    2 + 2           ≡⟨⟩
    suc 1 + suc 1   ≡⟨⟩
    suc (suc 1 + 1) ≡⟨⟩
    suc (suc 2)     ≡⟨⟩
    suc 3           ≡⟨⟩
    4               ∎
```
