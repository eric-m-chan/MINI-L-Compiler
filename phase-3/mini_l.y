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
extern int row;
extern int col;
extern FILE * yyin;

struct symbol {
	/* name of the symbol */
	std::string name;
	/* type of the symbol */
	std::string type;

	/* Constructors */
	symbol();
	symbol(std::string name, std::string type);
};

symbol::symbol() {

}

symbol::symbol(std::string name, std::string type) {
	this->name = name;
	this->type = type;	
}

template <typename T>
std::string to_string(T value)
{
	std::ostringstream os ;
	os << value ;
	return os.str() ;
}

std::vector<std::string> full_program;
std::vector<std::string> statements;

std::vector<std::string> functions_list;
std::vector<std::string> params_list;

std::vector< std::vector<std::string> > if_labels;
std::vector< std::vector<std::string> > loop_labels;


std::vector<symbol> symbol_table;
std::vector<symbol> ops_table;

uint tempCounter = 0;
uint labelCounter = 0;
uint paramCounter = 0;
/* used to differentiate between param and local declarations */
bool isParam = false;
/* set to true if there is an error */
bool isError = false;


/* Finds index of a symbol via name in symbol table */
uint find_index_ST(std::string symName) {
	for (uint i = 0; i < symbol_table.size(); i++) {
		if (symbol_table[i].name == symName) {
			return i;
		}
	}
	return 0;
}

/* Checks if an identifier has been used */
bool identifier_declared(std::string identifier) {
	for (uint i = 0; i < symbol_table.size(); i++) {
		if (identifier == symbol_table[i].name) {
			return true;
		}
	}
	for (uint i = 0; i < functions_list.size(); i++) {
		if (identifier == functions_list[i]) {
			return true;
		}
	}
	for (uint i = 0; i < params_list.size(); i++) {
		if (identifier == params_list[i]) {
			return true;
		}
	}
	return false;
}

/* Checks if a function has been defined */
bool function_defined(std::string function) {
	for (uint i = 0; i < functions_list.size(); i++) {
		if (function == functions_list[i]) {
			return true;
		}
	}
	return false;
}


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

%type <str_val> ident varbranch exprop multexprop decbranch2 stmtbranch21
%type <int_val> number termbranch1


%%

prog_start:	/* empty */				{
		}
		| function prog_start			{
		}
		;

function:	function_name SEMICOLON begin_params declarations end_params BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY stmtloop END_BODY	{	
			for (uint i = 0; i < symbol_table.size(); i++) {
				if (symbol_table[i].type == "INTEGER") {
					full_program.push_back(". " + symbol_table[i].name);
				}
				else {
					full_program.push_back(". [] " + symbol_table[i].name + ", " + symbol_table[i].type);
				}
			}
			
			for (uint i = 0; i < statements.size(); i++) {
				full_program.push_back(statements[i]);
			}
			
			/* clear all stacks for next function */
			symbol_table.clear();
			ops_table.clear();
			params_list.clear();
			statements.clear();

			full_program.push_back("endfunc");
		}
		;

function_name:	FUNCTION ident				{
			/* proxy function name to put it on stack to retain function names */
		
			/* add function name to list of functions */
                	functions_list.push_back($2);
                	/* add function declaration to program */
                	full_program.push_back(std::string("func ") + $2);
		}
		;

begin_params:	BEGIN_PARAMS				{
			/* used to differentiate between param declarations and local declarations */
			isParam = true;
		}

end_params:	END_PARAMS				{
			isParam = false;
			while (!params_list.empty()) {
                                statements.push_back("= " + params_list.back() + ", $" + to_string(paramCounter++));
                                params_list.pop_back();
                        }
		}

declarations:	/* empty */				{
		}
		| decbranch1 declarations		{
		}
		;
decbranch1:	ident COMMA decbranch1		 	{
			if (identifier_declared($1)) {
				printf("Error line %d: symbol \"%s\" is previously declared.\n", row, $1);
				isError = true;
			}
			if (isParam) {
				params_list.push_back($1);
			}
			symbol newSymbol($1, "INTEGER");
			symbol_table.push_back(newSymbol);
		}
		| ident COLON decbranch2 INTEGER SEMICOLON 	{
			if (identifier_declared($1)) {
				printf("Error line %d: symbol \"%s\" is previously declared.\n", row, $1);
				isError = true;
			}
			if (isParam) {
				params_list.push_back($1);
			}
			/* no array branch */
			if (strcmp($3, "EMPTY") == 0) {
				symbol newSymbol($1, "INTEGER");
				symbol_table.push_back(newSymbol);
			} /* there is an array branch */
			else {
				//computed in decbranch2 itself
			}
		}
decbranch2:     /* empty */                             {
			$$ = "EMPTY";
		}
                | ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF     {
			if ($3 <= 0) {
				printf("Error line %d: invalid array specifier \"%s\".\n", row, $3);
				isError = true;
			}
			else {
				symbol newSymbol(to_string($3), "INTEGER");
				symbol_table.push_back(newSymbol);
			}
		}
                ;

statements:     stmtbranch1                             {
		}
                | stmtbranch2                           {
		}
                | stmtbranch3                           {
		}
                | stmtbranch4                           {
		}
                | stmtbranch5                           {
		}
                | stmtbranch6                           {
		}
                | stmtbranch7                           {
		}
                | stmtbranch8                           {
		}
                | stmtbranch9                           {
		}
                ;

stmtloop:       statements SEMICOLON stmtloop           {
		}
                | statements SEMICOLON                  {
		}
                ;

stmtbranch1:    var ASSIGN expr                         {
			symbol assign_from = ops_table.back();
			ops_table.pop_back();
			symbol assign_to = ops_table.back();
			ops_table.pop_back();

			if (assign_to.type == "INTEGER") {
				statements.push_back("= " + assign_to.name + ", " + assign_from.name);
			}
			else {
				statements.push_back("[]= " + assign_to.name + ", " + assign_from.name);
			}
		}
		;
stmtbranch2:    if_boolexpr THEN stmtloop stmtbranch21 ENDIF    {
			// no else statement 
                        if (strcmp($4, "EMPTY") == 0) {
                                statements.push_back(": " + if_labels.back()[1]);
                                if_labels.pop_back();
                        } // there is an else statement 
                        else {
                                statements.push_back(": " + if_labels.back()[2]);
                                if_labels.pop_back();   
                        }
		}
                ;

if_boolexpr:	IF boolexpr 				{
			/* proxy if_boolexpr to this so it is on stack earlier */
			std::vector<std::string> labels;
			labels.push_back("L" + to_string(labelCounter++));
                        labels.push_back("L" + to_string(labelCounter++));
                        labels.push_back("L" + to_string(labelCounter++));
                        if_labels.push_back(labels);

                        statements.push_back("?:= " + labels[0] + ", " + ops_table.back().name);
                        ops_table.pop_back();
                        
                        statements.push_back(":= " + labels[1]);
                        statements.push_back(": " + labels[0]);
		}
		;
stmtbranch21:   /* empty */                             {
			$$ = "EMPTY";
		}
                | ELSE stmtloop                         {
			statements.push_back(":= " + if_labels.back()[2]);
			statements.push_back(": " + if_labels.back()[1]);	
		}
                ;
stmtbranch3:    while_boolexpr BEGINLOOP stmtloop ENDLOOP {
			statements.push_back("?:= " + loop_labels.back()[2] + ", " + ops_table.back().name);
			ops_table.pop_back();
			statements.push_back(":= " + loop_labels.back()[3]);
			statements.push_back(": " + loop_labels.back()[2]);
			loop_labels.pop_back();
		}
                ;
while_boolexpr:	WHILE boolexpr				{
			/* proxy while_boolexpr so it is on stack earlier*/
			std::vector<std::string> labels;
			labels.push_back("WHILE");
			labels.push_back("L" + to_string(labelCounter++));
			labels.push_back("L" + to_string(labelCounter++));
			labels.push_back("L" + to_string(labelCounter++));
			loop_labels.push_back(labels);
			statements.push_back(": " + labels[1]);

			statements.push_back("?:= " + loop_labels.back()[2] + ", " + ops_table.back().name);
			ops_table.pop_back();
			statements.push_back(":= " + loop_labels.back()[3]);
			statements.push_back(": " + loop_labels.back()[2]);
		}

stmtbranch4:    do_loop stmtloop ENDLOOP WHILE boolexpr {
			statements.push_back(": " + loop_labels.back()[2]);
			statements.push_back("?:= " + loop_labels.back()[1] + ", " + ops_table.back().name);

			ops_table.pop_back();
			loop_labels.pop_back();
		}
                ;
do_loop:	DO BEGINLOOP				{
			/* proxy do loop so it is on stack earlier */
			
			std::vector<std::string> labels;
			labels.push_back("DOWHILE");
			labels.push_back("L" + to_string(labelCounter++));
			labels.push_back("L" + to_string(labelCounter++));

			loop_labels.push_back(labels);
			statements.push_back(": " + labels[1]);
		}
		;
stmtbranch5:    FOR varassign SEMICOLON boolexpr SEMICOLON stmtbranch1 BEGINLOOP stmtloop ENDLOOP   {	
		

		}
                ;
varassign:	var ASSIGN number			{
			/* proxy var assignment so it is earlier on stack */
			symbol assign_from = ops_table.back();
                        ops_table.pop_back();
                        symbol assign_to = ops_table.back();
                        ops_table.pop_back();

                        if (assign_to.type == "INTEGER") {
                                statements.push_back("= " + assign_to.name + ", " + assign_from.name);
                        }
                        else {
                                statements.push_back("[]= " + assign_to.name + ", " + assign_from.name);
                        }


		}
		;
stmtbranch6:    READ stmtbranch61                       {	
		}
                ;
stmtbranch61:   var COMMA stmtbranch61                  {
			symbol newSymbol = ops_table.back();
                        ops_table.pop_back();
                        if(newSymbol.type == "INTEGER") {
                                statements.push_back(".< " + newSymbol.name);
                        }
                        else {
                                statements.push_back(".[]< " + newSymbol.name);
                        }
		}
                | var                                   {
			symbol newSymbol = ops_table.back();
                        ops_table.pop_back();
                        if(newSymbol.type == "INTEGER") {
                                statements.push_back(".< " + newSymbol.name);
                        }
                        else {
                                statements.push_back(".[]< " + newSymbol.name);
                        }
		}
                ;
stmtbranch7:    WRITE stmtbranch71                      {
		}
                ;
stmtbranch71:   var COMMA stmtbranch71                  {
			symbol newSymbol = ops_table.back();
			ops_table.pop_back();
			if (newSymbol.type == "INTEGER") {
				statements.push_back(".> " + newSymbol.name);
			}
			else {
				statements.push_back(".[]> " + newSymbol.name);
			}
		}
                | var                                   {
			symbol newSymbol = ops_table.back();
			ops_table.pop_back();
			if (newSymbol.type == "INTEGER") {
				statements.push_back(".> " + newSymbol.name);
			}
			else {
				statements.push_back(".[]> " + newSymbol.name);
			}
		}
                ;
stmtbranch8:    CONTINUE                                {
			if (loop_labels.empty()) {
				printf("Error line %d: continue statement not within a loop.\n", row);
				isError = true;
			}
			else {
				std::string loop_type = loop_labels.back()[0];
				if(loop_type == "WHILE") {
					statements.push_back(":= " + loop_labels.back()[1]);
				}
				else {
					statements.push_back(":= " + loop_labels.back()[2]);
				}
			}
		}
                ;
stmtbranch9:    RETURN expr                             {
			statements.push_back("ret " + ops_table.back().name);
			ops_table.pop_back();	
		}
                ;

boolexpr:       relandexpr boolbranch                   {
		}
		;
boolbranch:     /* empty */                             {
		}
                | OR relandexpr boolbranch              {
			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
			symbol_table.push_back(newSymbol);

			std::string op2 = ops_table.back().name;
			ops_table.pop_back();

			std::string op1 = ops_table.back().name;
			ops_table.pop_back();

			statements.push_back("|| " + newSymbol.name + ", " + op1 + ", " + op2);
			ops_table.push_back(newSymbol);
		}
                ;

relandexpr:     relexpr raebranch                       {
		}
                ;
raebranch:      /* empty */                             {
		}
                | AND relexpr raebranch                 {
			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
                        symbol_table.push_back(newSymbol);

                        std::string op2 = ops_table.back().name;
                        ops_table.pop_back();

                        std::string op1 = ops_table.back().name;
                        ops_table.pop_back();

                        statements.push_back("&& " + newSymbol.name + ", " + op1 + ", " + op2);
                        ops_table.push_back(newSymbol);	
		}
                ;


relexpr:        NOT relexpr                             {
			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
                        symbol_table.push_back(newSymbol);

                        std::string op1 = ops_table.back().name;
                        ops_table.pop_back();

                        statements.push_back("! " + newSymbol.name + ", " + op1);
                        ops_table.push_back(newSymbol);
	
		}
                | expr comp expr                        {
			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
                        symbol_table.push_back(newSymbol);

                        std::string op2 = ops_table.back().name;
                        ops_table.pop_back();

			std::string comp = ops_table.back().name;
			ops_table.pop_back();

                        std::string op1 = ops_table.back().name;
                        ops_table.pop_back();

                        statements.push_back(comp + " " + newSymbol.name + ", " + op1 + ", " + op2);
                        ops_table.push_back(newSymbol);

		}
                | TRUE                                  {
			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
                        symbol_table.push_back(newSymbol);
                        
			statements.push_back("= " + newSymbol.name + ", 1");
                        ops_table.push_back(newSymbol);

		}
                | FALSE                                 {
			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
                        symbol_table.push_back(newSymbol);

                        statements.push_back("= " + newSymbol.name + ", 0");
                        ops_table.push_back(newSymbol);

		}
                | L_PAREN boolexpr R_PAREN              {
		}
                ;


comp:           EQ                                      {
			symbol newSymbol("==", "NONE");
			ops_table.push_back(newSymbol);
		}
                | NEQ                                   {
                        symbol newSymbol("!=", "NONE");
                        ops_table.push_back(newSymbol);
		}
                | LT                                    {
                        symbol newSymbol("<", "NONE");
                        ops_table.push_back(newSymbol);
		}
                | GT                                    {
                        symbol newSymbol(">", "NONE");
                        ops_table.push_back(newSymbol);
		}
                | LTE                                   {
                        symbol newSymbol("<=", "NONE");
                        ops_table.push_back(newSymbol);
		}
                | GTE                                   {
                        symbol newSymbol(">=", "NONE");
                        ops_table.push_back(newSymbol);
		}
                ;

expr:           multexpr exprbranch                     {
		}
                ;
exprbranch:     /* empty */                             {
		}
                | exprop multexpr exprbranch            {
			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
			symbol_table.push_back(newSymbol);

			std::string op2 = ops_table.back().name;
			ops_table.pop_back();
			std::string op1 = ops_table.back().name;
			ops_table.pop_back();
			/* operation was addition */
			if (strcmp($1, "ADD") == 0) {
				statements.push_back("+ " + newSymbol.name + ", " + op1 + ", " + op2);	
			} /* operation was subtraction */
			else if (strcmp($1, "SUB") == 0) {
				statements.push_back("- " + newSymbol.name + ", " + op1 + ", " + op2);
			}
			else {
				printf("Error line %d: \"%s\" is not a valid operator.\n", row, $1);
				isError = true;
			}
			
			ops_table.push_back(newSymbol);
		}
                ;
exprop:         ADD                                     {
			$$ = "ADD";
		}
                | SUB                                   {
			$$ = "SUB";
		}
                ;


multexpr:       term multexprbranch                     {
		}
                ;
multexprbranch: /* empty */                             {
		}
                | multexprop term multexprbranch        {
			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
			symbol_table.push_back(newSymbol);

			std::string op2 = ops_table.back().name;
			ops_table.pop_back();
			std::string op1 = ops_table.back().name;
			ops_table.pop_back();
			/* operation was multiplication */
			if (strcmp($1, "MULT")	== 0) {
				statements.push_back("* " + newSymbol.name + ", " + op1 + ", " + op2);
			}
			else if (strcmp($1, "DIV") == 0) {
				statements.push_back("/ " + newSymbol.name + ", " + op1 + ", " + op2);
			}
			else if (strcmp($1, "MOD") == 0) {
				statements.push_back("% " + newSymbol.name + ", " + op1 + ", " + op2);
			}
			else {
				printf("Error line %d: \"%s\" is not a valid operator.\n", row, $1);
				isError = true;
			}
			
			ops_table.push_back(newSymbol);
		}
                ;
multexprop:     MULT                                    {
			$$ = "MULT";
		}
                | DIV                                   {
			$$ = "DIV";
		}
                | MOD                                   {
			$$ = "MOD";
		}
                ;


term:           termbranch1                             {
		}
                | termbranch2                           {
		}
                ;
termbranch1:    SUB termbranch1                         {
			symbol newSymbol(to_string(-1 * $2), "INTEGER");
			ops_table.push_back(newSymbol);
		}
                | var                                   {
		}
                | number                                {
			symbol newSymbol(to_string($1), "INTEGER");
			ops_table.push_back(newSymbol);
		}
                | L_PAREN expr R_PAREN                  {printf("termbranch1 -> L_PAREN expr R_PAREN\n");}
                ;
termbranch2:    ident L_PAREN termbranch21 R_PAREN      {
			/* $1 names a function */
			if (!function_defined($1)) {
				printf("Error line %d: \"%s\" was not previously defined.\n", row, $1);
				isError = true;
			}

			symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
			symbol_table.push_back(newSymbol);

			std::string op = ops_table.back().name;
			ops_table.pop_back();

			statements.push_back("param " + op);
			statements.push_back(string("call ") + $1 + ", " + newSymbol.name);

			ops_table.push_back(newSymbol);
		}
                ;
termbranch21:   /* empty */                             {
		}
                | termbranch22                          {
		}
                ;
termbranch22:   expr                                    {
		}
                | expr COMMA termbranch22               {
		}
                ;

var:            ident varbranch                         {
			if (!identifier_declared($1)) {
				printf("Error line %d: symbol \"%s\" was not previously declared.\n", row, $1);
				isError = true;
			}
			/* ident is intended to be used as an integer */
			if (strcmp($2, "EMPTY") == 0) {
				uint index = find_index_ST($1);
				if (symbol_table[index].type != "INTEGER") {
					printf("Error line %d: used array variable \"%s\" is missing a specified index.\n", row, $1);
					isError = true;
				}
				symbol newSymbol($1, "INTEGER");
				ops_table.push_back(newSymbol);
			} /* Otherwise, ident is an array */
			else { 
				uint index = find_index_ST($1);
				if (symbol_table[index].type != "ARRAY") {
					printf("Error line %d: specified array index when ussing regular integer variable \"%s\".", row, $1);
					isError = true;
				}

				symbol newSymbol("temp_" + to_string(tempCounter++), "INTEGER");
				symbol_table.push_back(newSymbol);

				std::string array_size = ops_table.back().name;
				ops_table.pop_back();
				
				newSymbol.type = "ARRAY";
				ops_table.push_back(newSymbol);
				statements.push_back("=[] " + newSymbol.name + ", " + $1 + ", " + array_size);
			} 
		}
                ;
varbranch:      /* EMPTY */                             {
			/* mark varbranch as EMPTY */
			$$ = "EMPTY";
		}
                | L_SQUARE_BRACKET expr R_SQUARE_BRACKET {
			$$ = "ARRAY";
		}
                ;


ident:		IDENT					{
			$$ = $1;
		}
		;
number:		NUMBER					{
			$$ = $1;
		}
		;
%%

int main(int argc, char **argv) {
        if ((argc > 1) && (freopen(argv[1], "r", stdin) == NULL))
        {
                 cerr << argv[0] << ": File " << argv[1] << " cannot be opened.\n";
                 exit( 1 );
        }

        yyparse();

	bool mainExists = false;
	/* Check if main function exists */
	for (int i = 0; i < functions_list.size(); i++) {
		if (functions_list[i] == "main") {
			mainExists = true;
		}
	}

	if (!mainExists) {
		printf("Error: main function not declared.\n");
		return -1;
	}

	if (isError) {
		return -1;
	}

	std::ofstream output_file;

	output_file.open("output.mil");	

	for (int i = 0; i < full_program.size(); i++) {
		//uncomment to print instead of loading to file
		//std::cout << full_program[i] << std::endl;
		output_file << full_program[i] << std::endl;
	}
	std::cout << "=== DONE WRITING TO output.mil ===\n";
	output_file.close();

        return 0;
}

