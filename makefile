# we call "make" with no arguments.
run: parser.y lexer.l
	bison -d parser.y --verbose
	flex lexer.l
	g++ -c lex.yy.c parser.tab.c
	g++ -o parser lex.yy.o parser.tab.o -ll -ly

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h lex.yy.c parser.tab.o lex.yy.o parser.output

