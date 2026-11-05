---
id: forall
index: 6
title: "For all"
learning_goals:
  - "A universal statement `∀ n → P n` is a dependent function."
  - "Predicates are functions into `Set`."
hints:
  - text: "The goal is a pair. Select the hole and press **Refine** with an empty box to get `? , ?`, then do the same in each new hole. Each becomes a `λ n → ?`."
  - text: "In the first new hole the goal is `P n`, and the context has `h : (n₁ : ℕ) → P n₁ × Q n₁`. `h n` is a pair: project out the part you want."
  - text: "`∀-× h = (λ n → proj₁ (h n)) , (λ n → proj₂ (h n))`."
---
Here's something new in the statement: `P Q : ℕ → Set`. A function from numbers to
*types*. Since a type is a proposition, that is a function that takes a number and gives
back a statement about it. For example, `λ n → n ≡ 2` takes `3` to the statement
`3 ≡ 2`. A function like this is called a **predicate**.

You've seen `∀` since the Tutorial, and it is a function here too, with one twist. In
`∀ n → P n` the *type* of the result depends on the *value* of the argument: given `3`
it returns a proof of `P 3`. That's called a **dependent function**.

The statement says that if every number satisfies both `P` and `Q`, then every number
satisfies `P`, and every number satisfies `Q`. Read the parentheses carefully: the
hypothesis is one function that returns pairs, and the goal is a pair of functions.

Build the outside first, and let **Refine** with an empty box write each layer for you.

<!-- @conclusion -->
`ℕ → Set` is the type of predicates on `ℕ`. Replace `ℕ` by strings and a predicate is
exactly what theory of computation calls a *language*, which is where this world's last
level is headed.
