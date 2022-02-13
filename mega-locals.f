\ Local Variables for TurboForth by Mark Wills.

\ Version 1.1 - 19th August 2015. Machine code enhancements.
\ Version 1.2 - 22nd March 2017.  Bug fix. See below.
\ Version 1.3 - 13th Feb 2022.    Stack signatures (using { and }) define the locals.
\                                 E.g. bounds { start count -- end_addr start_addr }
\                                 Locals processing stops at first occurence of -- or }
\
\ Bug fixes:
\ Version 1.2:
\  * locals? was not set to false by ; after compilation of a definition that
\    contains locals. Changes made to ; LOCALS{ and allotLocals.


\ An implementation of local variables.
\
\ Not ANS compatible.
\
\ Local variables are declared with the word LOCALS{ followed by a list
\ of variable names, followed by a closing }
\
\ For example:
\   TEST ( -- ) locals{ a b c } ... ... ... ;
\ The local variables are initialised to 0 upon creation.
\
\ Locals are referenced in code with their names.
\
\ Locals may be written to with SET and +SET. E.g.
\ : TEST ( x y z -- ) locals{ a b c } set c   set b   set a ;
\
\ The above example initialises the local variables a, b and c from the
\ data on the data stack. Z goes to c, y to b, and x to a.
\
\ Here is another example:
\ : TEST ( x y z -- z(x+y) )
\   locals{ x y z } set z  set y  set x
\   x y + z * ;
\
\ Where recursion is used with a definition that contains locals, each
\ instance of the definition shall inherit its own set of new locals.\

\ Locals consume no dictionary space at all. Their names are temporarily
\ hashed during compilation only. After that their names are not required.
\ The hash table is set to the end of RAM (see dictAddr). There is
\ room for 14 locals per definition as currently set.
\ The locals stack sits immediately above the hash table and grows
\ towards lower memory addresses (the hash table grows to higher addresses).
\
\ Enhancement for V1.3:
\ Locals may be defined using stack comment notation, using { and } instead
\ of ( and ). At run-time, they will be automatically populated from the stack.
\
\ Example:
\ : bounds { start length -- end start } start length +  start ;
\
\ You MUST include -- and you MUST close your comment with } otherwise - crash!
\
\ if your word returns nothing, then record that in the stack comment as normal:
\ : someWord { tom dick -- }
\   some code here ;
\
\ This library takes 948 bytes.

0 VALUE locals?             \ true if a colon-def has locals
0 VALUE localCount          \ number of locals in a colon def
0 VALUE localOffset
$FFE0 VALUE dictAddr        \ address of start of local dictionary
$A006 @ VALUE FINDV         \ save contents of FIND vector
VARIABLE _LS                \ top of local stack pointer
dictAddr _LS !              \ set local stack pointer

HEX 
CODE: (allotLocals) C073 0A11 A801 _LS , ;CODE                                      
CODE: @local C020 _LS , A033 0644 C510 ;CODE                                 
CODE: (SET) C020 _LS , A033 C434 ;CODE                                      
CODE: (+SET) C020 _LS , A033 A434 ;CODE                                      
DECIMAL

: allotLocals ( n -- ) \ compile run-time code to allot n locals
    COMPILE (allotLocals) , ; \ n goes inline 

: >HASH ( c-addr len -- u)
	\ hashes a string using the CRC-16 algorithm
	$FFFF             \ initial CRC16
	-ROT              \ move it out of the way
	OVER + SWAP DO    \ for each byte in the string
		I C@ XOR        \ xor with CRC16
		8 0 DO          \ for 8 bits in the byte
			DUP 1 AND   \ note the LSB prior to shift
			SWAP 1 >>   \ shift the CRC16
			SWAP IF 
				$A001 XOR \ if LSB was 1 then apply polynomial
			THEN  
		LOOP
	LOOP ;

: (LOCAL) ( addr len -- )
    ?DUP IF \ is a local. Add to fleeting locals dictionary:
        >HASH               \ hash the variable name
        dictAddr localCount CELLS + ! \ store hash in local dictionary
        1 +TO localCount    \ increment number of locals
    ELSE \ end of locals list
        DROP
        localCount negate allotLocals
    THEN ;

: --? ( c-addr len -- flag )
	2 <> if drop TRUE exit then
	dup c@ ascii - xor  swap 1+ c@ ascii - xor or  0= if  
		span @ >in @ do
			1 >in +!  tib @ i + v@ ascii } = if leave then 
		loop
	then FALSE ;

: LOCALS{ ( "name...name }" -- )
    0 TO localCount
    TRUE TO locals?
    BEGIN
        BL WORD  2dup --?
    WHILE               \ while } or -- is not detected
        (LOCAL)         \ add local variable to locals dictionary
    REPEAT
    2DROP  0 0 (LOCAL)  \ end local dictionary processing
; IMMEDIATE

: { ( "name...name }" -- )
    [compile] LOCALS{
    0  localCount 1- DO COMPILE (SET)  I 2* ,  -1 +LOOP ; IMMEDIATE
    
: compileLocal ( -- ) COMPILE @local localOffset 1- CELLS , ;

: findLocal ( addr len - offset+1|0)
    \ search locals dictionary for word and return offset into
    \ locals stack+1 if found or 0 if not found
    >HASH 0 SWAP
    localCount 0 DO
        dictAddr I CELLS + @ OVER = IF
            SWAP DROP I 1+ SWAP LEAVE
        THEN
    LOOP  DROP 
    DUP TO localOffset ;

: localNotFound ( --)
    CR ." Error: Local not found."
    FALSE to locals? ABORT ;

: doSET ( xt "local" value -- )
    BL WORD findLocal IF
        , ( xt )
        localOffset 1- CELLS , ( in-line offset )
    ELSE
        localNotFound
    THEN ;
   
: SET  ( "local" value --) ['] (SET) doSet ; IMMEDIATE
    
: +SET ( "local" value --) ['] (+SET) doSet ; IMMEDIATE

: ; locals? IF localCount allotLocals FALSE TO locals? THEN 
  [COMPILE] ; ; IMMEDIATE

0 value _addr   0 value _len
: _FIND ( addr len -- cfa flag )
    2DUP  TO _len  TO _addr
    FINDV EXECUTE DUP 0= IF
        STATE @ IF
            locals? IF
                2DROP _addr _len findLocal IF
                    ['] compileLocal 1
                ELSE
                    0 0
                THEN
            THEN
        THEN
    THEN ;


' _FIND $A006 ! \ re-vector FIND to use our FIND first

\ Test: define BOUNDS using locals
\ : bounds { start len -- end start } 
\  start len +  start ;
\ 100 25 bounds  ( should push 125 100 )
