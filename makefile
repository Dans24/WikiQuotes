quotes: src/pratico.flex
	mkdir -p out/
	flex -o out/lex.yy.c src/pratico.flex
	cc -o out/a.out out/lex.yy.c

clean: out/a.out out/lex.yy.c
	rm -r out