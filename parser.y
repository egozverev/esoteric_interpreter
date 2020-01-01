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
	template <class T>
	bool is_missing(const std::map<std::string, T>& values,const std::string& name){
		return values.find(name) == values.end();
	}
	bool is_missing(const std::set <std::string>& values, const std::string name){
		return values.find(name) == values.end();
	}
	bool check_def(const std::string& name){
		return is_missing(int_values, name) && is_missing(str_values, name) &&
		is_missing(float_values, name) && is_missing(bool_values, name) && is_missing(null_values, name);

	}
	bool check_redeclaration(const std::string& name){
		if(!check_def(name)){
			yyerror("redeclaration error\n");
			return false;
		}
		return true;
	}
	bool check_declaration(const std::string& name){
		if(check_def(name)){
			yyerror("variable was not declared\n");
			return false;
		}
		return true;
	}
	template<class T>
	bool try_erase(T& values, const std::string& name){
		auto it = values.find(name);
		if(it != values.end()){
			values.erase(it);
			return true;
		}
		return false;
	}
	template<class T> 
	bool try_print(const T& values, const std::string& name){
		auto it = values.find(name);
		if( it != values.end()){
			std::cout << (*it).second << "\n";
			return true;
		}
		return false;
	}
	bool try_print(const std::set <std::string>& values, const std::string name){
		if(values.find(name) != values.end()){
			std::cout << "none\n";
			return true;
		}
		return false;
	}
	/*template<class T> 
	bool check_aff(T& values, const std::string& name){
		// check affiliation -  if name exists in values
		return values.find(name) != values.end();
	}*/
	void free_name(const std::string& name){
		if(try_erase(int_values, name) || try_erase(str_values, name) ||
			try_erase(float_values, name) || try_erase(bool_values, name) || try_erase(null_values, name)){
			return; // hack to avoid empty erases	
		}

	}
	void print_val(const std::string& name){
		if(try_print(int_values, name) || try_print(str_values, name) ||
			try_print(float_values, name) || try_print(bool_values, name) || try_print(null_values, name)){
			return; // hack to avoid empty tries	
		}
	}
%}

%token START
%token DECL_FST
%token DECL_SND
%token ASSIGN
%token STRING
%token INTEGER
%token FLOAT
%token WIN
%token FAIL 
%token NOOB
%token END
%token ID
%token PRINT
%token ADD
%token SUB
%token MULT
%token DIV
%token MOD
%token MAXX
%token MINN
%token BINAR

%%
program: START commands END {return 0;};
commands: /* nothing */
 | commands command

command: definition
	| print
	| assignment;

definition: DECL_FST ID {
		if(check_redeclaration($2)){
			null_values.emplace($2);
		}
	}
	| DECL_FST ID DECL_SND INTEGER {	
		if(check_redeclaration($2)){
			int val = stoi($4);
			int_values.emplace($2, val);
		}
	}
	| DECL_FST ID DECL_SND STRING {
		if(check_redeclaration($2)){
			str_values.emplace($2, $4);
		}
	}
	| DECL_FST ID DECL_SND WIN {
		if(check_redeclaration($2)){
			bool_values.emplace($2, true);
		}
	}
	| DECL_FST ID DECL_SND FAIL {
		if(check_redeclaration($2)){
			bool_values.emplace($2, false);
		}
	}
	| DECL_FST ID DECL_SND FLOAT {
		if(check_redeclaration($2)){
			float_values.emplace($2, stod($4));
		}
	}
	;

print: PRINT ID {
	print_val($2);
	}
	;
assignment: 
	ID ASSIGN INTEGER {
		if(check_declaration($1)){
			free_name($1);
			int_values.emplace($1, stoi($3));
		}
	}
	| ID ASSIGN STRING{
		if(check_declaration($1)){
			free_name($1);
			str_values.emplace($1, $3);
		}
	}
	| ID ASSIGN WIN{
		if(check_declaration($1)){
			free_name($1);
			bool_values.emplace($1, true);
		}
	}
	| ID ASSIGN FAIL{
		if(check_declaration($1)){
			free_name($1);
			bool_values.emplace($1, false);
		}
	}
	| ID ASSIGN FLOAT{
		if(check_declaration($1)){
			free_name($1);
			float_values.emplace($1, stod($3));
		}
	}
	;
/*var: INTEGER | FLOAT;
arithmetics: var| BOOL |*/ 
%%


int main() {
	return yyparse();
}



