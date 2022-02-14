# Local variable implementation for TurboForth V1.3
This library provides an advanced local variables implementation for TurboForth.

## Declaration of Locals

### Using LOCALS{

The word `LOCALS{` is used to begin the definition of a list of local variables. Definition of locals is terminated with `}` as in the following example:

```
: computeArea ( w h -- area)
  LOCALS{ height width } 
  SET height   SET width
  height width * ;
```

In this example, two local variables are declared: height and width. The order in which local variables are declared is not important, since, unlike other local variable implementations, the locals do not have to be initialiased from the data stack (though you can do that if you want to - see the next section). Note that local variables are referenced in your code by their names. Naming a local variable in a colon definition causes its *value* (not its address) to be pushed to the stack. Local variables (in this implementation) work very similiarly to VALUEs.

### Storing Data in your Local Variables
Data is stored into your local variables from the data stack, with the words `SET` and `+SET`. `SET` and `+SET` are analogous to `TO` and `+TO` which are used with VALUEs.

Example:

```
: TEST ( n4 n3 n2 n1 -- ) 
  LOCALS{ A B C D }

  SET D  SET C  SET B  SET A
  A . B . C . D .
;
1 2 3 4 TEST
1 2 3 4 ok:0
```

As can be seen:
* the local variables are populated _manually_ from the data passed in on the stack via the use of `SET`. This is behavior is different from traditional Forth locals implementation, which load local variables from the stack (though that behaviour is supported, see below).
* The data is removed from the stack as the local variables are loaded, as one would expect.

Note that, as shown in the stack signature, n1 was on the top of the stack when TEST was invoked, this was loaded into the local variable `D` with the phrase `SET D`, n2 was loaded into `C`, n3 into `B` and n4 into `A`.

#### Accessing the Local Variables
Once your data has been stored in local variables, it can be accessed in any random order, simply by name; no stack juggling or use of the return stack is required.

In the example above, all four local variables are loaded from the data on the stack passed into TEST. However, (unlike most Forth local variable implementations) they don't have to be. Here's an example:

```
: diagonal ( ch -- )
  locals{ x y }
  10 0 do
    x y gotoxy  dup emit
    i set x
    i set y
  loop drop ;
```

Here, x and y are defined as locals but are used as pure locals, never taking a value from the stack.

## Declaring Stack Locals

Local variables may also be loaded automatically from data on the stack. To do this, the word `{` is used to define a stack comment using normal Forth nomenclature. Local varaiables will be created that match the names on the left-hand side of the `--` demarkation in the stack comment, and they will be populated with data from the stack, as follows:

```
: bounds { start count -- end start }
  start count +  \ push end
  start          \ push start
```

At runtime, `start` and `count` are initialised from the stack.

Notes:

* The input side of the stack comment are defined as local variables. The output side (after the -- symbol) are _not_ declared. They are purely comments.
* The -- symbol, and closing } character in the stack comment are *required*. The locals parser looks for them to end locals parsing.


