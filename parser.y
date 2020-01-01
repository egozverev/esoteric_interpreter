%{
	#include <iostream>
	#include <map>
	#include <set>
	#include <string>
	#include <cstdlib>
	#include <variant>
	struct None{
	};
	std::ostream& operator<< (std::ostream &out, const None& none){ out << "none"; }
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

	bool print_val(const Values& values, const std::string& name){
		auto PrintVisitor = [](const auto& elem) { std::cout << elem << "\n"; }; 
		// lamba function whil will be applied to the cur element
		auto it = values.find(name);
		if( it != values.end()){
			int index = ((*it).second).index();
			std::visit(PrintVisitor, (*it).second);			
			return true;
		}
		return false;
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
	| DECL_FST ID DECL_SND type {	
		if(check_redeclaration(values, std::get<1>($2))){

			values.emplace(std::get<1>($2), $4);
		}
	}
	;
print: PRINT ID {
	print_val(values, std::get<1>($2));
	}
	;
assignment: 
	ID ASSIGN type {
		if(check_declaration(values, std::get<1>($1))){
			free_name(values, std::get<1>($1));
			values.emplace(std::get<1>($1), $3);
		}
	}
	;
/*var: INTEGER | FLOAT;
arithmetics: var| BOOL |*/ 
%%


int main() {
	return yyparse();
}



