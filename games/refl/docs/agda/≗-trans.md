`≗-trans`

Pointwise equality talks about values at each input, without assuming function extensionality.

```agda
cong-app : ∀ {A B : Set} {f g : A → B} → f ≡ g → ∀ x → f x ≡ g x

infix 4 _≗_
_≗_ : ∀ {A B : Set} → (A → B) → (A → B) → Set
f ≗ g = ∀ x → f x ≡ g x

≗-trans : ∀ {A B : Set} {f g h : A → B} → f ≗ g → g ≗ h → f ≗ h
```

Use the lemma by supplying arguments in the order of its type. See the lesson's worked example for the proof technique.
