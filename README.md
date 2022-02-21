# Local variable implementation for TurboForth V1.3
This library provides an advanced local variables implementation for TurboForth.

Local variables are divided into two categories:

* Named inputs - these are named local variables that are initialised from the stack. However, whilst they are initialised from the stack, you can still write to them and change them. 
* Local variables - these are named local varaibles are _not_ initialised from the stack - they are initialised to 0 and you can use them as true local variables to store temporary values, running totals, loop indexes etc.

## Declaring Local Variables

The word `{` is used to begin the definition of a list of local variables. Definition of locals is terminated with `}`. It is designed to serve as both a locals declaration, and stack comment simultaneously. See the following example:

```
: complexThing { x y | a b -- area }
  really complex stuff that uses x, y, a and b;
```

* x and y are named inputs - they are loaded with whatever is on the stack when the word executes;
* The | symbol ends the declaration of the named inputs, and begins the declaration of the (optional) local variables;
* You can have just local variables with no named inputs. In this case use { | a b c d -- } i.e., don't declare any named inputs, just declare the local variables;
* The -- symbol is optional, it is ignored. It is there to make the declaration look like a stack comment. Everything after the -- symbol is ignored until the } is encountered;
* The } character is mandatory. It signals the end of the declaration.

## Writing to Named Inputs and Local Variables

Named inputs and local variablescan be changed at any time using the words `SET` and `+SET`. These words are analogous to `TO` and `+TO` which are used with VALUEs.

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

---

#### Attribution

The nomenclature, and the locals declaration syntax are shamelessly stolen from Microprocessor Engineering's (MPE) excellent VFX Forth system. See the book [Programming Forth(https://www.mpeforth.com/arena/ProgramForth.pdf)], page 101, by Stephen Pelc. 
