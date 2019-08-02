# parser-sed-thing

This project was a programming challenge issued to my by a buddy of
mine, https://github.com/jamesdbrock/ .

The overall goal was to create a sed-like string matching function
that would use a parser function to scan through a string and select
all parts of the string that match the parser as a 'Right' value,
while returning non-matching strings as 'Left' values.

One of the goals was to use a parser function from a parser combinator
library in place of a regular expression. He did not specify a parser
combinator library, so I chose [Attoparsec]( https://hackage.haskell.org/package/attoparsec-0.13.2.2/docs/Data-Attoparsec-Text-Lazy.html ).

I use `cabal new-build` to build this project, and once built thusly,
you can test the `sed`-like function in a GHCi session by running
`cabal new-repl`. Here is an example session:

```
λ pureSed double "look at number 1.414"
[Left "look at number ",Right ("1.414",1.414)]

λ pureSed double "look at number 1.414 it is quite nice"
[Left "look at number ",Right ("1.414",1.414),Left " it is quite nice"]

λ pureSed double "look at number 1.414 it is quite nice 4e0"
[Left "look at number ",Right ("1.414",1.414),Left " it is quite nice ",Right ("4e0",4.0)]

λ pureSed double ".3e3 look at number 1.414 it is quite nice 4e0"
[Left ".",Right ("3e3",3000.0),Left " look at number ",Right ("1.414",1.414),Left " it is quite nice ",Right ("4e0",4.0)]

λ pureSed double "0.3e3 look at number 1.414 it is quite nice 4e0"
[Right ("0.3e3",300.0),Left " look at number ",Right ("1.414",1.414),Left " it is quite nice ",Right ("4e0 ",4.0)]

λ pureSed double "0.3e3 1.414 4e0"
[Right ("0.3e3",300.0),Left " ",Right ("1.414",1.414),Left " ",Right ("4e0",4.0)]
```

**BE WARNED:** Efficient string matching was NOT a goal of this
challenge.
