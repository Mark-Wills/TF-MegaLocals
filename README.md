# Local variable implementation for TurboForth V1.3
This library provides an advanced local variables implementation for TurboForth.

Local variables are divided into two categories:

* Named inputs - these are named local variables that are _initialised_ from the stack. Even though they are initialised from the stack, you can still write to them and change them. 
* Local variables - these are named local varaibles are not initialised from the stack - they are initialised to 0 and you can use them as true local variables.

## Named Inputs

The word `{` is used to begin the definition of a list of local variables. Definition of locals is terminated with `}`. It is designed to serve as both a locals declaration, and stack comment simultaneously. See the following example:

```
: computeArea { width height -- area }
  width height * ;
```

The locals are populated from the stack and can then be referred to by name. It should be noted that a local variable, having been initialised from the stack, can be changed at any time using `SET`:

## Storing Data in your Local Variables
Data is normally stored into your local variables from the data stack. However, It should be noted that a local variable, having been initialised from the stack, can be changed at any time using with the words `SET` and `+SET`. 

`SET` and `+SET` are analogous to `TO` and `+TO` which are used with VALUEs.

Example:

```
: TEST { a b c d -- } 
  1 +set a
  2 +set b
  3 +set c
  4 +set d
  a . b . c . d .
;
1 2 3 4 TEST
2 4 6 8 ok:0
```



Here, x and y are defined as locals but are used as pure locals, never taking a value from the stack.

## Declaring Stack Locals

Local variables may also be loaded automatically from data on the stack. To do this, the word `{` is used to define a stack comment using normal Forth nomenclature. Local varaiables will be created that match the names on the left-hand side of the `--` demarkation in the stack comment, and they will be populated with data from the stack, as follows:

```
: bounds { start count -- end start }
  start count +  \ push end
  start          \ push start
;
```

At runtime, `start` and `count` are initialised from the stack.

Notes:

* The input side of the stack comment are defined as local variables. The output side (after the -- symbol) are _not_ declared. They are purely comments.
* The -- symbol, and closing } character in the stack comment are *required*. The locals parser looks for them to end locals parsing. If your definition does push any result(s) to the stack then use a normal -- } closing sequence as one would for any stack signature/comment that does not push results. E.g. `a[!] { value index -- }`.


