%{
	#include <iostream>
	#include <map>
	#include <set>
	#include <string>
	#include <cstdlib>
	#define YYSTYPE std::string
	int yylex();
	std::map <std::string, int> int_values;
	std::map <std::string, std::string> str_values;
	std::map <std::string, double> float_values;
	std::map <std::string, bool> bool_values;
	std::set <std::string> null_values; 
	void yyerror(const char *s) {
		fprintf(stderr, "error: %s\n", s);
	}
	bool check_def(std::string name){
		return int_values.find(name) == int_values.end() &&
			str_values.find(name) == str_values.end() &&
			float_values.find(name) == float_values.end() &&
			bool_values.find(name) == bool_values.end() &&
			null_values.find(name) == null_values.end();
	}
%}

%token START
%token DECL_FST
%token DECL_SND
%token ASSIGN
%token STRING
%token INTEGER
%token FLOAT
%token BOOL 
%token NOOB
%token END
%token ID
%token PRINT

%%
program: START commands END {return 0;};
commands: /* nothing */
 | commands command

command: definition
	| print;

definition: DECL_FST ID {null_values.insert($2);}
	| DECL_FST ID DECL_SND INTEGER {	
		if(!check_def($2)){
			yyerror("redeclaration error");		
		}
		int val = stoi($4);
		int_values.emplace($2, val);
	}
	| DECL_FST ID DECL_SND STRING {
		if(!check_def($2)){
					yyerror("redeclaration error");		
				}
		str_values.emplace($2, $4.substr(1, $4.size() - 2));
	}

print: PRINT ID {
	if(auto it = int_values.find($2) != int_values.end()){
		std::cout << int_values[$2] << "\n";
	}
	else if(auto it = str_values.find($2) != str_values.end()){
		std::cout << str_values[$2] << "\n";
	}
	else if(auto it = float_values.find($2) != float_values.end()){
		std::cout << float_values[$2] << "\n";
	}
	else if(auto it = bool_values.find($2) != bool_values.end()){
		std::cout << (int_values[$2] ? "WIN" : "FAIL") << "\n";
	}
	else if(auto it = null_values.find($2) != null_values.end()){
		std::cout << "null\n";
	}
	else {
		yyerror("wrong name");
	}
	}
%%


int main() {
	return yyparse();
}



