run: parser.y lexer.l
	bison -d parser.y --verbose
	flex lexer.l
	g++ -std=c++17 -c lex.yy.c parser.tab.c
	g++ -std=c++17 -o parser lex.yy.o parser.tab.o -ll -ly

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h lex.yy.c parser.tab.o lex.yy.o parser.output

