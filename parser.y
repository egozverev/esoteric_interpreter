%{
	#include <iostream>
	#include <map>
	#include <set>
	#include <string>
	#include <cstdlib>
	#include <variant>
	struct None{
	};
	std::ostream& operator<< (std::ostream &out, const None& none){ out << "none"; return out;}
	using Value = std::variant<int, std::string, double, bool, None>;
	using Values = std::map<std::string, Value>;
	#define YYSTYPE Value
	
	int yylex();
	Values values;
	void yyerror(const char *s) {
		fprintf(stderr, "error: %s\n", s);
	}
	
	bool check_def(const Values& values,const std::string& name){
		return values.find(name) == values.end();
	}

	bool check_redeclaration(const Values& values, const std::string& name){
		if(!check_def(values, name)){
			yyerror("redeclaration error");
			return false;
		}
		return true;
	}
	bool check_declaration(const Values& values, const std::string& name){
		if(check_def(values, name)){
			yyerror("variable was not declared");
			return false;
		}
		return true;
	}
	
	bool free_name(Values& values, const std::string& name){
		auto it = values.find(name);
		if(it != values.end()){
			values.erase(it);
			return true;
		}
		return false;
	}
	void print_exp(const Value& val){
		auto PrintVisitor = [](const auto& elem) { std::cout << elem << "\n"; }; 
		// lamba function whil will be applied to the cur element
		std::visit(PrintVisitor, val);
	}
	bool print_val(const Values& values, const std::string& name){

		auto it = values.find(name);
		if( it != values.end()){
			print_exp((*it).second);
			return true;
		}
		return false;
	}
	struct add_to_first {
		// bad but not that bad solution
		void operator() (int& x, int& y) {
			x += y;
		}
		void operator() (std::string& x, std::string& y) {
			x += y;
		}
		void operator() (double& x, double& y) {
			x += y;
		}
		void operator() (None&, None&) {}
		void operator() (bool&, bool&) {}
		#include "defs.h"

	};


	/*Value add(const Value& arg1, const Value& arg2){
		int index = arg1.index();
		int index2 = arg2.index();
		if(index != index2 || index > 2){
			yyerror("incompatible type");
			return None();
		}
		Value x = 5;
		return (std::visit(get_value(), x));// + std::visit(get_value(), arg2));
		return 0;
		
	}*/


	
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
;
command: definition
	| print
	| assignment; 
type: INTEGER | STRING | WIN | FAIL | FLOAT;
definition: DECL_FST ID {
		if(check_redeclaration(values, std::get<1>($2))){
			values.emplace(std::get<1>($2), None());
		}
	}
	| DECL_FST ID DECL_SND exp {	
		if(check_redeclaration(values, std::get<1>($2))){

			values.emplace(std::get<1>($2), $4);
		}
	}
	;
print: PRINT ID {
	print_val(values, std::get<1>($2));
	}
	| PRINT exp{
		print_exp($2);
	}
	;
assignment: 
	ID ASSIGN exp {
		if(check_declaration(values, std::get<1>($1))){
			free_name(values, std::get<1>($1));
			values.emplace(std::get<1>($1), $3);
		}
	}
	| ID ASSIGN ID{
		if(check_declaration(values, std::get<1>($1)) && check_declaration(values, std::get<1>($3))){
			$1 = $3;
		}
	}
	;
exp: type
	| ADD exp BINAR exp{
		if($2.index() != $4.index() || $2.index() >= 3){
			yyerror("incompatible types");
		}
		else{
			Value new_val = $2;
			std::visit(add_to_first(), new_val, $4); // try to add them 
			$$ = new_val;
		}
	}
	| ADD ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			if(fst.index() != snd.index() || fst.index() >= 3){
				yyerror("incompatible types");
			}
			else{
				Value new_val = fst;
				std::visit(add_to_first(), new_val, snd); // try to add them 
				$$ = new_val;
			}
		}
		
	}
 

; 
%%


int main() { 
	return yyparse();
}



