/* This code requires the flex tool. Steps to compile and run:

1. 	flex lexer.lex
2. 	gcc lex.yy.c -lfl
3. 	./a.out

to pipe an input file to ./a.out:
./a.out < input.txt

to pipe an input file to ./a.out and into an output file:
./a.out < input.txt > output.txt
*/

%{
int row = 0;
int col = 0;
%}

DIGIT		[0-9]
ALPHA   	[a-zA-Z]
IDENTIFIER 	{ALPHA}(({ALPHA}|{DIGIT}|_)*({ALPHA}|{DIGIT}))?
ALLNUMBERS 	^[\+\-]?{DIGIT}*(\.{DIGIT}*)?(E[\+\-]?{DIGIT}*)?$
NATNUMBER	{DIGIT}*
INVIDENTN	{DIGIT}(({ALPHA}|{DIGIT}|_)*({ALPHA}|{DIGIT}))?
INVIDENTUB	_({ALPHA}|{DIGIT}|_)*
INVIDENTUE	({ALPHA}|{DIGIT}|_)*_

%%
function		printf("%s\n", "FUNCTION");		col += yyleng;
beginparams		printf("%s\n", "BEGIN_PARAMS"); 	col += yyleng;
endparams		printf("%s\n", "END_PARAMS");   	col += yyleng;
beginlocals		printf("%s\n", "BEGIN_LOCALS");		col += yyleng;
endlocals		printf("%s\n", "END_LOCALS"); 		col += yyleng;
beginbody		printf("%s\n", "BEGIN_BODY"); 		col += yyleng;
endbody			printf("%s\n", "END_BODY"); 		col += yyleng;
integer			printf("%s\n", "INTEGER"); 		col += yyleng;
array			printf("%s\n", "ARRAY"); 		col += yyleng;
of			printf("%s\n", "OF"); 			col += yyleng;
if			printf("%s\n", "IF"); 			col += yyleng;
then			printf("%s\n", "THEN"); 		col += yyleng;
endif			printf("%s\n", "ENDIF"); 		col += yyleng;
else			printf("%s\n", "ELSE"); 		col += yyleng;
while			printf("%s\n", "WHILE"); 		col += yyleng;
do			printf("%s\n", "DO"); 			col += yyleng;
beginloop		printf("%s\n", "BEGINLOOP"); 		col += yyleng;
endloop			printf("%s\n", "ENDLOOP"); 		col += yyleng;
continue		printf("%s\n", "CONTINUE"); 		col += yyleng;
read			printf("%s\n", "READ"); 		col += yyleng;
write			printf("%s\n", "WRITE"); 		col += yyleng;
and			printf("%s\n", "AND"); 			col += yyleng;
or			printf("%s\n", "OR"); 			col += yyleng;
not			printf("%s\n", "NOT");		 	col += yyleng;
true			printf("%s\n", "TRUE"); 		col += yyleng;
false			printf("%s\n", "FALSE"); 		col += yyleng;
return			printf("%s\n", "RETURN"); 		col += yyleng;

\-			printf("%s\n", "SUB"); 			col += yyleng;
\+			printf("%s\n", "ADD"); 			col += yyleng;
\*			printf("%s\n", "MULT");			col += yyleng;
\/			printf("%s\n", "DIV"); 			col += yyleng;
\%			printf("%s\n", "MOD"); 			col += yyleng;

\=\=			printf("%s\n", "EQ"); 			col += yyleng;
\<\>			printf("%s\n", "NEQ"); 			col += yyleng;
\<			printf("%s\n", "LT"); 			col += yyleng;
\>			printf("%s\n", "GT"); 			col += yyleng;
\<\=			printf("%s\n", "LTE"); 			col += yyleng;
\>\=			printf("%s\n", "GTE"); 			col += yyleng;

\;			printf("%s\n", "SEMICOLON"); 		col += yyleng;
\:			printf("%s\n", "COLON"); 		col += yyleng;
\,			printf("%s\n", "COMMA"); 		col += yyleng;
\(			printf("%s\n", "L_PAREN"); 		col += yyleng;
\)			printf("%s\n", "R_PAREN"); 		col += yyleng;
\[			printf("%s\n", "L_SQUARE_BRACKET"); 	col += yyleng;
\]			printf("%s\n", "R_SQUARE_BRACKET"); 	col += yyleng;
\:\=			printf("%s\n", "ASSIGN"); 		col += yyleng;

{NATNUMBER}		printf("%s %s\n", "NUMBER", yytext); 	col += yyleng;
{IDENTIFIER}		printf("%s %s\n", "IDENT", yytext); 	col += yyleng;
[\n\t\r] 		row++; col = 0;
" "								col += yyleng;
##.*$			

{INVIDENTN}		printf("Error at row %d, column %d : identifier \"%s\" must begin with a letter\n", row, col, yytext);  
{INVIDENTUB}		printf("Error at row %d, column %d : identifier \"%s\" cannot begin with an underscore\n", row, col, yytext);
{INVIDENTUE}		printf("Error at row %d, column %d : identifier \"%s\" cannot end with an underscore\n", row, col, yytext);
.			printf("%s%s%s\n", "Error: unrecognized symbol \"", yytext, "\""); 
%%

main()
{
  yylex();
}
