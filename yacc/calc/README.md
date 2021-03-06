# calc

calcはflex, bisonを使って構文解析中に計算を行い、結果を返します。

## Lexical Syntax

```
space    ::= (' ' | '\t')
DOUBLE   ::= (('1'|...|'9') ('0'|...|'9')* | '0') ('.' ('0'|...|'9') ('0'|...|'9')*)?
paren    ::= '(' | ')'
operator ::= '+' | '-' | '*' | '/'
```

## Operator Precedence

assoc | operators
----- | ---------
left  | '+' '-'
left  | '*' '/'

## Context-free Syntax

```
program       ::= expr
expr          ::= expr '+' expr
                | expr '-' expr
                | expr '*' expr
                | expr '/' expr
                | primary
primary       ::= DOUBLE
                | '(' expr ')'
```
