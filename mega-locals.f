\ Local Variables for TurboForth Version 1.3 by Mark Wills.

\ Locals may be defined using stack comment notation, using { and } instead
\ of ( and ). At run-time, they will be automatically populated from the stack.

\ Example:
\ : bounds { start length -- end start } start length +  start ;

\ You MUST close your comment with } otherwise - crash!

\ If your word returns nothing, then record that in the stack comment as normal:

\ : someWord { tom dick -- }
\   some code here ;

\ Where recursion is used with a definition that contains locals, each
\ instance of the definition shall inherit its own set of new locals.

\ Locals consume no dictionary space at all. Their names are temporarily
\ hashed during compilation only. After that their names are not required.
\ The hash table is set to the end of RAM (see dictAddr). There is room 
\ for a combination of 14 named inputs and locals per definition.

\ The locals stack sits immediately above the hash table and grows
\ towards lower memory addresses (the hash table grows to higher addresses).

\ This library takes 1176 bytes.

0 VALUE locals?        \ true if a colon-def has locals
0 VALUE localCount     \ number of locals in a colon def
0 VALUE localOffset    \ index into locals stack
0 VALUE locState       \ state machine for NLOCAL
0 VALUE niCount        \ named input count
$FFD0 VALUE dictAddr   \ address of start of local dictionary
$A006 @ VALUE FINDV    \ save contents of FIND vector
VARIABLE _LS           \ top of local stack pointer
dictAddr _LS !         \ set local stack pointer

HEX 
CODE: (allot) C073 0A11  A801 _LS ,     ;CODE
CODE: @local  C020 _LS , A033 0644 C510 ;CODE
CODE: (SET)   C020 _LS , A033 C434      ;CODE
CODE: (+SET)  C020 _LS , A033 A434      ;CODE
DECIMAL

: allotLocals ( n -- ) \ compile run-time code to allot n locals
  COMPILE (allot) , ; \ n goes inline
  
: >HASH ( c-addr len -- c-addr len u)
	$FFFF -ROT OVER + SWAP DO    
  I C@ XOR  8 0 DO DUP 1 AND SWAP 1 >> SWAP IF $A001 XOR THEN LOOP LOOP ;

: (NLOCAL) ( addr len -- ) \ store hash in local dictionary
  >HASH dictAddr localCount CELLS + !  1 +TO localCount ;

: checkLoc ( addr len -- addr len flag )
  dup 1 = if \ check for |
    over c@ ascii | = if 
      2drop 1 exit
    else 
      over c@ ascii } = if 
        2drop 3 exit
      then
    then
  then 

  dup 2 = if \ check for --
    over dup 1+ c@ swap c@
    ascii - =  swap ascii - = and if 2drop 2 exit then
  then
  2drop 0 ( none of the above ) ;

: compileLocal ( -- ) COMPILE @local localOffset 1- CELLS , ;

: findLocal ( addr len - offset+1|0)
  >HASH 0 SWAP
  localCount 0 DO
      dictAddr I CELLS + @ OVER = IF
          SWAP DROP I 1+ SWAP LEAVE
      THEN
  LOOP  DROP 
  DUP TO localOffset ;

: localNotFound ( --)
  CR ." Error: Local not found."
  FALSE to locals? ABORT  999 >in ! ;

: doSET ( xt "local" value -- )
  BL WORD findLocal IF
      , ( xt )
      localOffset 1- CELLS , ( in-line offset )
  ELSE
      localNotFound
  THEN ;
   
: SET  ( "local" value --) ['] (SET) doSet ; IMMEDIATE  
: +SET ( "local" value --) ['] (+SET) doSet ; IMMEDIATE

: { ( tib:"..." -- )
  0 to locState  0 TO localCount  0 to niCount
  true to locals?
  begin 
    bl word  2dup checkLoc
    case 
      0 of 
        locState case
          0 of (NLOCAL) 1 +to niCount endof \ named input
          1 of (NLOCAL) endof               \ named local
          2 of 2drop    endof               \ --
        endcase 0
      endof
      1 of 2drop 1 to locState 0 endof
      2 of 2drop 2 to locState 0 endof
      3 of 2drop 3 to locState 1 endof \ }
    endcase
  until
  localCount negate allotLocals
  niCount if 
    0 niCount 1- DO COMPILE (SET)  I 2* ,  -1 +LOOP then
; immediate

: ; locals? IF localCount allotLocals FALSE TO locals? THEN 
  [COMPILE] ; ; IMMEDIATE

0 value _addr   0 value _len
\ New version of FIND which is capable of finding locals stored
\ in the locals hash table.
: _FIND ( addr len -- cfa flag )
  2DUP  TO _len  TO _addr
  FINDV EXECUTE DUP 0= IF \ not found
    STATE @ IF            \ compiling?
      locals? IF          \ has locals?
        2DROP _addr _len findLocal IF
          ['] compileLocal 1
        ELSE
          0 0
        THEN
      THEN
    THEN
  THEN ;

' _FIND $A006 ! \ patch the FIND vector to use our new FIND
