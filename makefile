quotes: src/pratico.flex
	mkdir -p out/
	flex -o out/lex.yy.c src/pratico.flex
	cc -o out/wikiquotes lex.yy.c `pkg-config --cflags --libs glib-2.0` -lglib-2.0

clean: out/a.out out/lex.yy.c
	rm -r out