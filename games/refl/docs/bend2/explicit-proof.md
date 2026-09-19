`(proof : Type)` annotates a proof with the type it must have:

```bend
({==} : {Zero{} == Zero{} : Nat})
```

The outer colon gives the proof's type. The inner `: Nat` says the equality's
endpoints are natural numbers. Parentheses group the whole annotation.
`{==}` supplies the reflexivity proof; the equality type is the surrounding
`{Zero{} == Zero{} : Nat}`. A `def name():` begins an indented definition
with no arguments, supplying the proof for the `law` of the same name.
