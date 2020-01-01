%{
	#include <stdio.h>
	#include <map>
	#include <set>
	#include <string>
	#define YYSTYPE std::string
	int yylex();
	std::map <std::string, int> int_values;
	std::set <std::string> null_values; 
	void yyerror(const char *s) {
		fprintf(stderr, "error: %s\n", s);
	}
%}

%token START
%token DECL_FST
%token DECL_SND
%token ASSIGN
%token STRING
%token INTERER
%token FLOAT
%token BOOL 
%token NOOB
%token END
%token ID
%token PRINT

%%
program: START commands END;
commands: /* nothing */
 | commands command

command: definition;

definition: DECL_FST ID {null_values.insert($2);}


%%


int main() {
	return yyparse();
}



