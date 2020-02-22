/* MINI_L Parser - This code requires the bison tool.
Steps to compile and run:

required: heading.h main.cc mini_l.lex Makefile
(Makefile will call flex mini_l.lex)

1. make

To run with an input file input.min:
2. ./mini_l < input.min

*/


%{
#include "heading.h"
void yyerror(char* s) {
	fprintf (stderr, "%s\n", s);
}
int yylex(void);
%}

%union{
int             int_val;
char*        	str_val;
}

%start prog_start

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF
%token IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE RETURN
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET
%token TRUE FALSE
%left  SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE
%right NOT
%left  AND OR
%right ASSIGN
%token <int_val> NUMBER
%token <str_val> IDENT



%%

prog_start:	/* empty */				{printf("prog_start -> epsilon\n");}
		| function prog_start			{printf("prog_start -> function prog_start\n");}
		;

function:	FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY stmtloop END_BODY	{printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS\n");}
		;


declarations:	/* empty */				{printf("declarations -> epsilon\n");}
		| decbranch1 declarations		{printf("declarations -> decbranch1 SEMICOLON declarations\n");}
		;
decbranch1:	ident COMMA decbranch1		 	{printf("decbranch1 -> ident COMMA decbranch1\n");}
		| ident COLON decbranch2 INTEGER SEMICOLON 	{printf("decbranch1 -> ident COLON decbranch2 INTEGER SEMICOLON\n");}
decbranch2:     /* empty */                             {printf("decbranch2 -> epsilon\n");}
                | ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF     {printf("decbranch2 -> ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF\n");}
                ;

statements:     stmtbranch1                             {printf("statements -> stmtbranch1\n");}
                | stmtbranch2                           {printf("statements -> stmtbranch2\n");}
                | stmtbranch3                           {printf("statements -> stmtbranch3\n");}
                | stmtbranch4                           {printf("statements -> stmtbranch4\n");}
                | stmtbranch5                           {printf("statements -> stmtbranch5\n");}
                | stmtbranch6                           {printf("statements -> stmtbranch6\n");}
                | stmtbranch7                           {printf("statements -> stmtbranch7\n");}
                | stmtbranch8                           {printf("statements -> stmtbranch8\n");}
                | stmtbranch9                           {printf("statements -> stmtbranch9\n");}
                ;

stmtloop:       statements SEMICOLON stmtloop           {printf("stmtloop -> statements SEMICOLON stmtloop\n");}
                | statements SEMICOLON                  {printf("stmtloop -> statements SEMICOLON\n");}
                ;

stmtbranch1:    var ASSIGN expr                         {printf("stmtbranch1 -> var ASSIGN expr\n");}

stmtbranch2:    IF boolexpr THEN stmtloop stmtbranch21 ENDIF    {printf("stmtbranch2 -> IF boolexpr THEN stmtloop stmtbranch21 ENDIF\n");}
                ;
stmtbranch21:   /* empty */                             {printf("stmtbranch21 -> epsilon\n");}
                | ELSE stmtloop                         {printf("stmtbranch21 -> ELSE stmtloop\n");}
                ;
stmtbranch3:    WHILE boolexpr BEGINLOOP stmtloop ENDLOOP {printf("stmtbranch3 -> WHILE boolexpr BEGINLOOP stmtloop ENDLOOP\n");}
                ;
stmtbranch4:    DO BEGINLOOP stmtloop ENDLOOP WHILE boolexpr {printf("stmtbranch4 -> DO BEGINLOOP stmtloop ENDLOOP WHILE boolexpr\n");}
                ;
stmtbranch5:    FOR var ASSIGN number SEMICOLON boolexpr SEMICOLON var ASSIGN expr BEGINLOOP stmtloop ENDLOOP   {printf("stmtbranch5 -> FOR var ASSIGN number SEMICOLON boolexpr SEMICOLON var ASSIGN expr BEGINLOOP stmtloop ENDLOOP\n");}
                ;
stmtbranch6:    READ stmtbranch61                       {printf("stmtbranch6 -> READ stmtbranch61\n");}
                ;
stmtbranch61:   var COMMA stmtbranch61                  {printf("stmtbranch61 -> var COMMA stmtbranch61\n");}
                | var                                   {printf("stmtbranch61 -> var\n");}
                ;
stmtbranch7:    WRITE stmtbranch71                      {printf("stmtbranch7 -> WRITE stmtbranch71\n");}
                ;
stmtbranch71:   var COMMA stmtbranch71                  {printf("stmtbranch71 -> var COMMA stmtbranch71\n");}
                | var                                   {printf("stmtbranch71 -> var\n");}
                ;
stmtbranch8:    CONTINUE                                {printf("stmtbranch8 -> CONTINUE\n");}
                ;
stmtbranch9:    RETURN expr                             {printf("stmtbranch9 -> RETURN expr\n");}
                ;

boolexpr:       relandexpr boolbranch                   {printf("boolexpr -> relandexpr boolbranch\n");}
                | L_PAREN boolexpr R_PAREN		{printf("boolexpr -> L_PAREN boolexpr R_PAREN\n");}
		;
boolbranch:     /* empty */                             {printf("boolbranch -> epsilon\n");}
                | OR relandexpr boolbranch              {printf("boolbranch -> OR relandexpr boolbranch\n");}
                ;

relandexpr:     relexpr raebranch                       {printf("relandexpr -> relexpr raebranch\n");}
                ;
raebranch:      /* empty */                             {printf("raebranch -> epsilon\n");}
                | AND relexpr raebranch                 {printf("raebranch -> AND relexpr raebranch\n");}
                ;


relexpr:        NOT relexpr                             {printf("relexpr -> NOT relexpr\n");}
                | expr comp expr                        {printf("relexpr -> expr comp expr\n");}
                | TRUE                                  {printf("relexpr -> TRUE\n");}
                | FALSE                                 {printf("relexpr -> FALSE\n");}
                | L_PAREN boolexpr R_PAREN              {printf("relexpr -> L_PAREN boolexpr R_PAREN\n");}
                ;


comp:           EQ                                      {printf("comp -> EQ\n");}
                | NEQ                                   {printf("comp -> NEQ\n");}
                | LT                                    {printf("comp -> LT\n");}
                | GT                                    {printf("comp -> GT\n");}
                | LTE                                   {printf("comp -> LTE\n");}
                | GTE                                   {printf("comp -> GTE\n");}
                ;

expr:           multexpr exprbranch                     {printf("expr -> multexpr exprbranch\n");}
                ;
exprbranch:     /* empty */                             {printf("exprbranch -> epsilon\n");}
                | exprop multexpr exprbranch            {printf("exprbranch -> exprop multexpr exprbranch\n");}
                ;
exprop:         ADD                                     {printf("exprop -> ADD\n");}
                | SUB                                   {printf("exprop -> SUB\n");}
                ;


multexpr:       term multexprbranch                     {printf("multexpr -> term multexprbranch\n");}
                ;
multexprbranch: /* empty */                             {printf("multexprbranch -> epsilon\n");}
                | multexprop term multexprbranch        {printf("multexprbranch -> multexprop term multexprbranch\n");}
                ;
multexprop:     MULT                                    {printf("multexprop -> MULT\n");}
                | DIV                                   {printf("multexprop -> DIV\n");}
                | MOD                                   {printf("multexprop -> MOD\n");}
                ;


term:           termbranch1                             {printf("term -> termbranch1\n");}
                | termbranch2                           {printf("term -> termbranch2\n");}
                ;
termbranch1:    SUB termbranch1                         {printf("termbranch1 -> SUB termbranch1\n");}
                | var                                   {printf("termbranch1 -> var\n");}
                | number                                {printf("termbranch1 -> number\n");}
                | L_PAREN expr R_PAREN                  {printf("termbranch1 -> L_PAREN expr R_PAREN\n");}
                ;
termbranch2:    ident L_PAREN termbranch21 R_PAREN      {printf("termbranch2 -> ident L_PAREN termbranch21 R_PAREN\n");}
                ;
termbranch21:   /* empty */                             {printf("termbranch21 -> epsilon\n");}
                | termbranch22                          {printf("termbranch21 -> termbranch22\n");}
                ;
termbranch22:   expr                                    {printf("termbranch21 -> expr\n");}
                | expr COMMA termbranch21               {printf("termbranch21 -> expr COMMA termbranch 22\n");}
                ;

var:            ident varbranch                         {printf("var -> ident varbranch\n");}
                ;
varbranch:      /* EMPTY */                             {printf("varbranch -> epsilon\n");}
                | L_SQUARE_BRACKET expr R_SQUARE_BRACKET {printf("varbranch -> L_SQUARE_BRACKET expr R_SQUARE_BRACKET\n");}
                ;


ident:		IDENT					{printf("ident -> IDENT %s\n", $1);}
		;
number:		NUMBER					{printf("number -> NUMBER%d\n", $1);}
		;
%%

