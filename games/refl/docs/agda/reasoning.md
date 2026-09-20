A chain of terms, written out so the intermediate steps are visible:

```agda
open ≡-Reasoning

proof =
  begin
    a ≡⟨⟩       -- a and b compute to the same thing
    b ≡⟨ p ⟩    -- p : b ≡ c, a real proof for a step that does not
    c ∎
```

`begin` opens the chain, `∎` closes it on the last term, and between two lines
you write either `≡⟨⟩` or `≡⟨ p ⟩`.

`≡⟨⟩` carries no proof: it claims only that the two terms around it are
**definitionally equal**, which the checker verifies by computing. It is not
limited to one reduction step — you may travel as far between two lines as
computation can reach, so a chain may show as much or as little of the walk as
you like. `≡⟨ p ⟩` is for steps computation cannot make on its own, where `p`
is a proof that the line above equals the line below.

These are ordinary functions in `Refl.Eq`: `begin_` and `_≡⟨⟩_` pass along
the proof, `_≡⟨_⟩_` combines proofs with `trans`, and `_∎` supplies reflexivity.
The standard library's
`Relation.Binary.PropositionalEquality` exports the same names.
