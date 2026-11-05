# Equality 1: Matching on refl

About 1 min 30 s. Agda.

Statement: `cong′ : ∀ {A B : Set} (f : A → B) {x y : A} → x ≡ y → f x ≡ f y`

**Open.** Equality World. We've been using `cong` and `sym` and `trans` as tools. Today we open the box and see what they're made of.

1. **Do:** Show the definition of `_≡_`.
   **Say:** It's a data type with one constructor, `refl`. And what do you do with a value of a data type? You case split on it.

2. **Do:** Select the hole and press Goal.
   **Say:** The goal is `f x ≡ f y`, and in the context there's `p : x ≡ y`, with two different variables.

3. **Do:** Case split on `p`, then press Check and Goal.
   **Say:** `p` has to be `refl`, and `refl` only proves a thing equal to itself. So Agda concludes that `y` is `x`. The goal is now `f x ≡ f x`.

4. **Do:** Give `refl`.
   **Say:** And that's `cong`. One line. The real one is forbidden in this level, just to make the point.

**Close.** That's the secret of equality: matching on `refl` tells Agda that the two sides are the same. `sym`, `trans` and `subst` are all a single line of this.

**Finished proof:**

```agda
cong′ f refl = refl
```
