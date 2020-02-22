/* This code requires the flex tool. This code is intended to be used
with a parser. Compile using the following:

flex mini_l.lex

*/

%{
#include "heading.h"
int row = 0;
int col = 0;
%}

DIGIT           [0-9]
ALPHA           [a-zA-Z]
IDENTIFIER      {ALPHA}(({ALPHA}|{DIGIT}|_)*({ALPHA}|{DIGIT}))?
ALLNUMBERS      ^[\+\-]?{DIGIT}*(\.{DIGIT}*)?(E[\+\-]?{DIGIT}*)?$
NATNUMBER       {DIGIT}*
INVIDENTN       {DIGIT}(({ALPHA}|{DIGIT}|_)*({ALPHA}|{DIGIT}))?
INVIDENTUB      _({ALPHA}|{DIGIT}|_)*
INVIDENTUE      ({ALPHA}|{DIGIT}|_)*_

%%
function                return(FUNCTION);                       col += yyleng;
beginparams             return(BEGIN_PARAMS);                   col += yyleng;
endparams               return(END_PARAMS);                     col += yyleng;
beginlocals             return(BEGIN_LOCALS);                   col += yyleng;
endlocals               return(END_LOCALS);                     col += yyleng;
beginbody               return(BEGIN_BODY);                     col += yyleng;
endbody                 return(END_BODY);                       col += yyleng;
integer                 return(INTEGER);                        col += yyleng;
array                   return(ARRAY);                          col += yyleng;
of                      return(OF);                             col += yyleng;
if                      return(IF);                             col += yyleng;
then                    return(THEN);                           col += yyleng;
endif                   return(ENDIF);                          col += yyleng;
else                    return(ELSE);                           col += yyleng;
while                   return(WHILE);                          col += yyleng;
do                      return(DO);                             col += yyleng;
beginloop               return(BEGINLOOP);                      col += yyleng;
endloop                 return(ENDLOOP);                        col += yyleng;
continue                return(CONTINUE);                       col += yyleng;
read                    return(READ);                           col += yyleng;
write                   return(WRITE);                          col += yyleng;
and                     return(AND);                            col += yyleng;
or                      return(OR);                             col += yyleng;
not                     return(NOT);                            col += yyleng;
true                    return(TRUE);                           col += yyleng;
false                   return(FALSE);                          col += yyleng;
return                  return(RETURN);                         col += yyleng;

\-                      return(SUB);                            col += yyleng;
\+                      return(ADD);                            col += yyleng;
\*                      return(MULT);                           col += yyleng;
\/                      return(DIV);                            col += yyleng;
\%                      return(MOD);                            col += yyleng;
\=\=                    return(EQ);                             col += yyleng;
\<\>                    return(NEQ);                            col += yyleng;
\<                      return(LT);                             col += yyleng;
\>                      return(GT);                             col += yyleng;
\<\=                    return(LTE);                            col += yyleng;
\>\=                    return(GTE);                            col += yyleng;

\;                      return(SEMICOLON);                      col += yyleng;
\:                      return(COLON);                          col += yyleng;
\,                      return(COMMA);                          col += yyleng;
\(                      return(L_PAREN);                        col += yyleng;
\)                      return(R_PAREN);                        col += yyleng;
\[                      return(L_SQUARE_BRACKET);               col += yyleng;
\]                      return(R_SQUARE_BRACKET);               col += yyleng;
\:\=                    return(ASSIGN);                         col += yyleng;

{NATNUMBER}             yylval.int_val = atoi(yytext); return(NUMBER); col += yyleng;
{IDENTIFIER}            yylval.str_val = strdup(yytext); return(IDENT);  col += yyleng;
[\n\t\r]                row++; col = 0;
" "                                                             col += yyleng;
##.*$

{INVIDENTN}             printf("Error at row %d, column %d : identifier \"%s\" must begin with a letter\n", row, col, yytext);
{INVIDENTUB}            printf("Error at row %d, column %d : identifier \"%s\" cannot begin with an underscore\n", row, col, yytext);
{INVIDENTUE}            printf("Error at row %d, column %d : identifier \"%s\" cannot end with an underscore\n", row, col, yytext);
.                       printf("%s%s%s\n", "Error: unrecognized symbol \"", yytext, "\"");
%%

/*
main()
{
  yylex();
}

*/
