To refute `e : {0n == 1n+n : Nat}`, rewrite through a discriminator that sends the two constructors to different types: `%Equal.sym(Nat, 0n, 1n+n, e) : disc(_)`, then `Unit{}`.
