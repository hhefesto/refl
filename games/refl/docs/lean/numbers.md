`MyNat` is this game's natural-number type. `zero` starts at zero and
`succ n` is one more than `n`. `(2 : MyNat)` selects this type for a numeral;
it expands to `succ (succ zero)`. Parentheses group an argument.
