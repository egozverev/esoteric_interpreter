%{
	#include <string>
	#include <iostream>
	#define YYSTYPE std::string
	void yyerror(const char *s);
	# include "parser.tab.h"
%}

id 	[_a-zA-Z][_a-zA-Z0-9]{0,30} 
num 	[0-9]+

%%
"HAI"		{return START;}
"KTHXBYE"	{return END;}
"I HAS A"	{return DECL_FST;}
"ITZ" 		{return DECL_SND;}
"R" 		{return ASSIGN;}
{id} 		{yylval = yytext; return ID; /* used {abbreviation} def*/} 
{num}		{yylval = yytext; return INTERER; }
[ \t\n]   	{ /* ignore white space */ }
.		{ yyerror("Mystery character \n"); }
%%
