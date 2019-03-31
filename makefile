quotes: src/pratico.flex
	mkdir -p out/
	flex -o out/lex.yy.c src/pratico.flex
	cc -o out/wikiquotes out/lex.yy.c `pkg-config --cflags --libs glib-2.0` -lglib-2.0

install: out/wikiquotes
	 sudo mv out/wikiquotes /usr/local/bin/wikiquotes

clean: out/a.out out/lex.yy.c
	rm -r out
