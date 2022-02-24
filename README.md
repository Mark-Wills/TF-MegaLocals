# Local variable implementation for TurboForth V1.3
This library provides an advanced local variables implementation for TurboForth.

Local variables are divided into two categories: <span style="color:blue">some *blue* text</span>.

* Named inputs - these are named local variables that are initialised from the stack. However, whilst they are initialised from the stack, you can still write to them and change them. 
* Local variables - these are named local variables and are _not_ initialised from the stack. You can use them as true local variables to store temporary values, running totals, loop indexes etc.

## Declaring Local Variables

The word `{` is used to begin the definition of a list of local variables. Definition of locals is terminated with `}`. It is designed to serve as both a locals declaration, and stack comment simultaneously. See the following example:

```
: complexThing { x y | a b -- nuclearLaunchCode }
  really complex stuff that uses x, y, a and b ;
```

* x and y are named inputs - Two values are _popped_ from the stack and loaded into x and y. Whilst they loaded from data on the stack, you _can_ write to them.
* The | symbol ends the declaration of the named inputs, and begins the declaration of the (optional) local variables. Local variables are _not_ loaded from the stack. They are internal, local variables that can be written to and read from. **CAUTION:** At runtime they are _uninitialised_ and therefore may contain any random value.
* You can have just local variables with no named inputs. In this case use `{ | a b c d -- }` i.e., don't declare any named inputs, just declare the local variables.
* The `--` symbol is optional, it is ignored. It is there to make the declaration look like a stack comment. Everything after the `--` symbol is ignored until the `}` is encountered.
* The `}` character is mandatory. It signals the end of the declaration. If you omit it you'll probably crash the system!

## Writing to Named Inputs and Local Variables

Named inputs and local variables can be changed at any time using the words `SET` and `+SET`. These words are analogous to `TO` and `+TO` which are used with VALUEs.

## Example:

### Example 1

```forth
: TEST { a b c d | x y z -- n } 
  1 +set a  2 +set b  3 +set c  4 +set d
  ( compute a*d into x) a d * set x \ look ma! No stack juggling!
  ( compute b*c into y) b c * set y
  ( compute a*b into z) a b * set z   
  cr ." a=" a . 
  cr ." b=" b . 
  cr ." c=" c .
  cr ." d=" d .
  cr ." x=" x .
  cr ." y=" y .
  cr ." z=" z .
  ( compute sum of x y & z and leave on stack:) x y z + + 
;
1 2 3 4 TEST
```

The output from the above test program is shown below. As be can seen, using locals can completely eliminate 'stack juggling'.

![Output from the above example](example.png "Output from the above example")

### Example 2

Here is an example of how a 3x2 matrix may be multiplied by a 2x3 matrix. Given the following matrix:

| 1 | 2 | 3 |
|---|---|---|
| 4 | 5 | 6 |

How might we multiply the above by:

| 7  | 8  |
|----|----|
| 9  | 10 |
| 11 | 12 |


How might we write a word to perform a 2x2 matrix multiplcation by a given scalar?

```forth
: 3.2x2.3 { a b c  d e f  g h  i j  k l  scalar | ra rb rc rd -- ra rb rc rd }

```

---

#### Attribution

The nomenclature, and the locals declaration syntax are shamelessly stolen from Microprocessor Engineering's (MPE) excellent VFX Forth system. See the book [Programming Forth](https://www.mpeforth.com/arena/ProgramForth.pdf), page 101, by Stephen Pelc. 
