%{
	#include <string>
	#include <iostream>
	#include <variant>
	#include <map>
	struct None{
	};
	std::ostream& operator<< (std::ostream &out, const None& none);
	using Value = std::variant<int, std::string, double, bool, None>;
	using Values = std::map<std::string, Value>;
	#define YYSTYPE Value
	void yyerror(const char *s);


	# include "parser.tab.h"
%}

id 	[_a-zA-Z][_a-zA-Z0-9]{0,30} 
float	[0-9]+.[0-9]+
num 	[0-9]+

%%
"HAI"		{return START;}
"KTHXBYE"	{return END;}
"I HAVE A"	{return DECL_FST;}
"ITZ" 		{return DECL_SND;}
"R" 		{return ASSIGN;}
"VISIBLE"	{return PRINT;}
"WIN"		{yylval = true; return WIN;}
"FAIL"		{yylval = false; return FAIL;}
"O RLY?"	{return IF_BEGIN;}
"YA RLY" 	{return TRUE_BRANCH;}
"NO WAI"	{return FALSE_BRANCH;}
"OIC"		{return IF_END;}
"SUM OF"	{return ADD;}
"DIFF OF"	{return SUB;}
"PRODUKT"	{return MULT;}
"QUOSHUNT"	{return DIV;}
"MOD OF"	{return MOD;}
"BIGGR OF"	{return MAXX;}
"SMALLR OF"	{return MINN;}
"BOTH OF"	{return AND;}
"EITHER OF"	{return OR;}
"WON OF"	{return XOR;}
"NOT"		{return NOT;}
"AN"		{return BINAR;/*connection between two operands*/} 
{id} 		{yylval = std::string(yytext);return ID; /* used {abbreviation} def*/} 
{float}		{yylval = atof(yytext); return FLOAT; }
{num}		{yylval = atoi(yytext); return INTEGER; }

\"[^"]*\"		{yylval = std::string(yytext); std::get<1>(yylval).erase(std::get<1>(yylval).begin()); std::get<1>(yylval).pop_back(); return STRING; }
[ \t\n]   	{ /* ignore white space */ }
.		{ yyerror("recognition error \n"); }
%%
