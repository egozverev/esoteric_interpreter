%{
	#include <algorithm>
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
		#include "defs.h"
	};
	struct sub_from_first {
		// bad but not that bad solution
		void operator() (int& x, int& y) {
			x -= y;
		}
		void operator() (std::string& x, std::string& y) {		}
		void operator() (double& x, double& y) {
			x -= y;
		}
		#include "defs.h"
	};
	struct mult_first {
		// bad but not that bad solution
		void operator() (int& x, int& y) {
			x *= y;
		}
		void operator() (std::string& x, std::string& y) {}
		void operator() (double& x, double& y) {
			x *= y;
		}
		#include "defs.h"
	};

	struct div_first {
		// bad but not that bad solution
		void operator() (int& x, int& y) {
			x /= y;
		}
		void operator() (std::string& x, std::string& y) {}
		void operator() (double& x, double& y) {
			x /= y;
		}
		#include "defs.h"
	};
	struct mod_first {
		// bad but not that bad solution
		void operator() (int& x, int& y) {
			x %= y;
		}
		void operator() (std::string& x, std::string& y) {}
		void operator() (double& x, double& y) {}
		#include "defs.h"
	};
	struct max_to_first {
		// bad but not that bad solution
		void operator() (int& x, int& y) {
			x = std::max(x, y);
		}
		void operator() (std::string& x, std::string& y) {}
		void operator() (double& x, double& y) {
			x = std::max(x, y);
		}
		#include "defs.h"
	};
	struct min_to_first {
		// bad but not that bad solution
		void operator() (int& x, int& y) {
			x = std::min(x, y);
		}
		void operator() (std::string& x, std::string& y) {}
		void operator() (double& x, double& y) {
			x = std::min(x, y);
		}
		#include "defs.h"
	};
	struct and_to_first {
		// bad but not that bad solution
		void operator() (bool& x, bool& y) {
			x = x && y;
		}
		#include "defs_logic.h"
	};
	struct or_to_first {
		// bad but not that bad solution
		void operator() (bool& x, bool& y) {
			x = x || y;
		}
		#include "defs_logic.h"
	};
	struct xor_to_first {
		// bad but not that bad solution
		void operator() (bool& x, bool& y) {
			x = (x != y);
		}
		#include "defs_logic.h"
	};
	struct not_first {
		// bad but not that bad solution
		void operator() (bool& x) {
			x = !x;
		}
		void operator() (int& x) {}
		void operator() (std::string& x) {}
		void operator() (double& x) {}
		void operator() (None& x) {}
	};

	


	
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
%token AND
%token OR
%token XOR
%token NOT
%token IF_BEGIN
%token TRUE_BRANCH
%token FALSE_BRANCH
%token IF_END
%token TRASH
%%
program: START commands END {return 0;};
commands: /* nothing */
	| commands command
	| WIN IF_BEGIN TRUE_BRANCH commands FALSE_BRANCH commands IF_END {}
;
command: definition
	| print
	| assignment
; 


type: INTEGER | STRING | FLOAT;
definition: DECL_FST ID {
		if(check_redeclaration(values, std::get<1>($2))){
			values.emplace(std::get<1>($2), None());
		}
	}
	| DECL_FST ID DECL_SND general_exp {	
		if(check_redeclaration(values, std::get<1>($2))){

			values.emplace(std::get<1>($2), $4);
		}
	}
	;
print: PRINT ID {
	print_val(values, std::get<1>($2));
	}
	| PRINT general_exp{
		print_exp($2);
	}
	;
assignment: 
	ID ASSIGN general_exp {
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
	| SUB exp BINAR exp{
		if($2.index() != $4.index() || $2.index() >= 3 || $2.index() == 1){
			yyerror("incompatible types");
		}
		else{
			Value new_val = $2;
			std::visit(sub_from_first(), new_val, $4);  
			$$ = new_val;
		}
	}
	| SUB ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			if(fst.index() != snd.index() || fst.index() >= 3 || fst.index() == 1){
				yyerror("incompatible types");
			}
			else{
				Value new_val = fst;
				std::visit(sub_from_first(), new_val, snd); 
				$$ = new_val;
			}
		}
		
	}
	| MULT exp BINAR exp{
		if($2.index() != $4.index() || $2.index() >= 3 || $2.index() == 1){
			yyerror("incompatible types");
		}
		else{
			Value new_val = $2;
			std::visit(mult_first(), new_val, $4);
			$$ = new_val;
		}
	}
	| MULT ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			if(fst.index() != snd.index() || fst.index() >= 3 || fst.index() == 1){
				yyerror("incompatible types");
			}
			else{
				Value new_val = fst;
				std::visit(mult_first(), new_val, snd);
				$$ = new_val;
			}
		}
		
	}
	| DIV exp BINAR exp{
		if($2.index() != $4.index() || $2.index() >= 3 || $2.index() == 1){
			yyerror("incompatible types");
		}
		else{
			Value new_val = $2;
			std::visit(div_first(), new_val, $4); 
			$$ = new_val;
		}
	}
	| DIV ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			if(fst.index() != snd.index() || fst.index() >= 3 || fst.index() == 1){
				yyerror("incompatible types");
			}
			else{
				Value new_val = fst;
				std::visit(div_first(), new_val, snd); 
				$$ = new_val;
			}
		}
		
	}
	| MOD exp BINAR exp{
		if($2.index() != $4.index() || $2.index() > 0){
			yyerror("incompatible types");
		}
		else{
			Value new_val = $2;
			std::visit(mod_first(), new_val, $4);  
			$$ = new_val;
		}
	}
	| MOD ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			if(fst.index() != snd.index() || fst.index() > 0){
				yyerror("incompatible types");
			}
			else{
				Value new_val = fst;
				std::visit(mod_first(), new_val, snd); 
				$$ = new_val;
			}
		}
		
	}
	| MAXX exp BINAR exp{
		if($2.index() != $4.index() || $2.index() >= 3 || $2.index() == 1){
			yyerror("incompatible types");
		}
		else{
			Value new_val = $2;
			std::visit(max_to_first(), new_val, $4);
			$$ = new_val;
		}
	}
	| MAXX ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			if(fst.index() != snd.index() || fst.index() >= 3 || fst.index() == 1){
				yyerror("incompatible types");
			}
			else{
				Value new_val = fst;
				std::visit(max_to_first(), new_val, snd); 
				$$ = new_val;
			}
		}
		
	}
	| MINN exp BINAR exp{
		if($2.index() != $4.index() || $2.index() >= 3 || $2.index() == 1){
			yyerror("incompatible types");
		}
		else{
			Value new_val = $2;
			std::visit(min_to_first(), new_val, $4); 
			$$ = new_val;
		}
	}
	| MINN ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			if(fst.index() != snd.index() || fst.index() >= 3 || fst.index() == 1){
				yyerror("incompatible types");
			}
			else{
				Value new_val = fst;
				std::visit(min_to_first(), new_val, snd); 
				$$ = new_val;
			}
		}
		
	}
 
;



bool_exp: WIN | FAIL
	| AND bool_exp BINAR bool_exp{
		Value new_val = $2;
		std::visit(and_to_first(), new_val, $4);
		$$ = new_val;

	}
	| AND ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			Value new_val = fst;
			std::visit(and_to_first(), new_val, snd); 
			$$ = new_val;

		}
		
	}
	| OR bool_exp BINAR bool_exp{
		Value new_val = $2;
		std::visit(or_to_first(), new_val, $4);
		$$ = new_val;

	}
	| OR ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			Value new_val = fst;
			std::visit(or_to_first(), new_val, snd); 
			$$ = new_val;

		}
		
	}
	| XOR bool_exp BINAR bool_exp{
		Value new_val = $2;
		std::visit(xor_to_first(), new_val, $4);
		$$ = new_val;

	}
	| XOR ID BINAR ID{
		if(check_declaration(values, std::get<1>($2)) && check_declaration(values, std::get<1>($4))){
			Value& fst = values[std::get<1>($2)];
			Value& snd = values[std::get<1>($4)];
			Value new_val = fst;
			std::visit(xor_to_first(), new_val, snd); 
			$$ = new_val;

		}
		
	}
	| NOT bool_exp{
		Value new_val = $2;
		std::visit(not_first(), new_val);
		$$ = new_val;

	}
	| NOT ID{
		if(check_declaration(values, std::get<1>($2))){
			Value& fst = values[std::get<1>($2)];
			Value new_val = fst;
			std::visit(not_first(), new_val); 
			$$ = new_val;

		}
		
	}

;



general_exp: exp | bool_exp
;
	 
%%


int main() { 
	return yyparse();
}



