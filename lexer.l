%{
	#include <string>
	#include <iostream>
	#define YYSTYPE std::string
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
"WIN"		{return WIN;}
"FAIL"		{return FAIL;}
"SUM OF"	{return ADD;}
"DIFF OF"	{return SUB;}
"PRODUKT"	{return MULT;}
"QUOSHUNT"	{return DIV;}
"MOD OF"	{return MOD;}
"BIGGR OF"	{return MAXX;}
"SMALLR OF"	{return MINN;}
"AN"		{return BINAR;/*connection between two operands*/} 
{id} 		{yylval = yytext; return ID; /* used {abbreviation} def*/} 
{float}		{yylval = yytext; return FLOAT; }
{num}		{yylval = yytext; return INTEGER; }
\".+\"		{yylval = yytext; yylval.erase(yylval.begin()); yylval.pop_back(); return STRING; }
[ \t\n]   	{ /* ignore white space */ }
.		{ yyerror("Mystery character \n"); }
%%
